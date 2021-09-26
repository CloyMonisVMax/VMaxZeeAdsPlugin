//
//  VMaxZeeAdsPlugin.swift
//  VMaxZeeAdsPlugin
//
//  Created by Cloy Monis on 24/09/21.
//

import Foundation
import VMaxAdsSDK

public class VMaxZeeAdsPlugin: NSObject {
    
    private var config: VMaxZeeAdsConfig
    private var delegate: VMaxAdsPluginDelegate
    private var metaObjects: [String: VMaxAdMetaData] = [String: VMaxAdMetaData]()
    private var vmaxAdBreak: VMaxAdBreak?
    private var vmaxAdBreakEvents: VMaxAdBreakEvents?
    private var vmaxAdBreakStatusInfo: VMaxAdBreakStateInfo?
    private var midRollDurations: Set<Int> = Set<Int>()
    private var scheduledMidRoll: Int?
    private var adBreaksRendered: [VMaxAdBreakStateInfo] = [VMaxAdBreakStateInfo]()
    private var adBreaksStarted: [VMaxAdBreakStateInfo] = [VMaxAdBreakStateInfo]()
    private var adsScheduled = AdsScheduled()
    private var helper = VMaxAdsPluginHelper()
    private let videoLayouts = ["zee":"ZeeUIView","wocta":"WoctaUIView"]
    private var blurEffect: UIBlurEffect?
    private var blurEffectView: UIVisualEffectView?
    private var activityView: UIActivityIndicatorView?
    private var lastPlayedSecond = 0
    
    public init(config: VMaxZeeAdsConfig,delegate: VMaxAdsPluginDelegate) throws {
        self.config = config
        self.delegate = delegate
        self.vmaxAdBreakEvents = self.config.adBreakEvents
        super.init()
        vmLog("")
        try helper.validate(vmaxAdsConfig: config)
        metaObjects = try helper.parseb2b(vmaxAdsConfig: config)
        let tuple = helper.getAdsScheduled(dict: metaObjects)
        adsScheduled = tuple.0
        midRollDurations = tuple.1
        preroll()
        //addObservers()
        setupBanner()
    }
    
    deinit {
        vmLog("")
    }
    
    public func start(){
        vmLog("")
        if adsScheduled.preRoll && helper.cuePointExist(seconds: VMaxAdsConstants.preroll, vmaxAdBreakStateInfo: adBreaksRendered) == false {
            vmLog("pre roll validations",.error)
            delegate.requestContentResume()
            return
        }
        guard let scheduledMidRoll = scheduledMidRoll else{
            vmLog("no cue point to start",.error)
            delegate.requestContentResume()
            return
        }
        guard helper.cuePointExist(seconds: scheduledMidRoll, vmaxAdBreakStateInfo: adBreaksRendered) == false else{
            vmLog("\(scheduledMidRoll) cue point already rendered",.error)
            delegate.requestContentResume()
            return
        }
        requestAdBreak(cuePoint: scheduledMidRoll)
    }
    
    public func pause(){
        vmLog("")
        guard let adBreak = vmaxAdBreak else {
            vmLog("adBreak is nil")
            return
        }
        adBreak.pause()
    }
    
    public func resume(){
        vmLog("")
        guard let adBreak = vmaxAdBreak else {
            vmLog("adBreak is nil")
            return
        }
        adBreak.resume()
    }
        
    public func playbackObserver(_ playBackTime: CMTime) {
        let currentSecond = Int(CMTimeGetSeconds(playBackTime))
        let scratchForward = (currentSecond - lastPlayedSecond) >= 2
        if let mediaDuration = config.mediaDuration {
            vmLog("currentSecond:\(currentSecond),totalDuration:\(Int(CMTimeGetSeconds(mediaDuration))),lastPlayedSecond:\(lastPlayedSecond),scratchForward:\(scratchForward)")
        }
        if let mediaDuration = config.mediaDuration,
           currentSecond >= Int(CMTimeGetSeconds(mediaDuration)) &&
            adsScheduled.postRoll &&
            helper.cuePointExist(seconds: -1, vmaxAdBreakStateInfo: adBreaksStarted) == false {
            requestAdBreak(cuePoint: VMaxAdsConstants.postroll)
        }else if let midroll = self.scheduledMidRoll,
           //(currentSecond == midroll || (scratchForward && currentSecond >= midroll && currentSecond >= lastPlayedSecond)) &&
            currentSecond >= midroll &&
            helper.cuePointExist(seconds: midroll, vmaxAdBreakStateInfo: adBreaksStarted) == false{
            clearSkippedMidroll(currentSeconds: currentSecond)
            delegate.requestContentPause()
            //if let currentMidroll = scheduledMidRoll {
            //    vmLog("cue point found currentMidroll:\(currentMidroll) done")
            //    scheduledMidRoll = nil
            //    midRollDurations.remove(currentMidroll)
            //    self.scheduledMidRoll = helper.getNextMidRoll(midRollDurations: midRollDurations)
            //}
        }
        if currentSecond != lastPlayedSecond{
            lastPlayedSecond = currentSecond
        }
    }
    
}

extension VMaxZeeAdsPlugin: VMaxAdBreakEvents {
    
    public func onAdBreakRequest() {
        vmLog("onAdBreakRequest")
        vmaxAdBreakEvents?.onAdBreakRequest()
        showLoaderView()
    }
    
    public func onAdBreakReady() {
        vmLog("onAdBreakReady")
        vmaxAdBreakEvents?.onAdBreakReady()
        guard let vmaxAdBreakStatusInfo = vmaxAdBreakStatusInfo else{
            vmLog("vmaxAdBreakStatusInfo is nil")
            return
        }
        guard vmaxAdBreakStatusInfo.requested == true else {
            vmLog("vmaxAdBreakStatusInfo.requested should be true")
            return
        }
        guard let view = config.videoView else {
            vmLog("config.videoView is nil")
            return
        }
        guard let vmaxAdBreak = vmaxAdBreak else {
            vmLog("vmaxAdBreak is nil")
            return
        }
        vmaxAdBreak.play(view)
        hideLoaderView()
    }
    
    public func onAdBreakStart() {
        vmLog("onAdBreakStart")
        vmaxAdBreakEvents?.onAdBreakStart()
    }
    
    public func onAdBreakError(_ error: VMaxError) {
        vmLog("onAdBreakError:\(error)")
        afterAdBreakCompletes()
        vmaxAdBreakEvents?.onAdBreakError(error)
        hideLoaderView()
    }
    
    public func onAdBreakComplete() {
        vmLog("onAdBreakComplete")
        afterAdBreakCompletes()
        vmaxAdBreakEvents?.onAdBreakComplete()
        hideLoaderView()
    }
    
    private func afterAdBreakCompletes(){
        vmaxAdBreak?.delegate = nil
        vmaxAdBreak = nil
        guard let vmaxAdBreakStatusInfo = vmaxAdBreakStatusInfo else{
            vmLog("vmaxAdBreakStatusInfo is nil")
            return
        }
        if vmaxAdBreakStatusInfo.cuePoint != 0 && vmaxAdBreakStatusInfo.cuePoint != -1 {
            if let currentMidroll = scheduledMidRoll {
                vmLog("currentMidroll:\(currentMidroll) done")
                scheduledMidRoll = nil
                midRollDurations.remove(currentMidroll)
            }
        }
        adBreaksRendered.append(vmaxAdBreakStatusInfo)
        self.vmaxAdBreakStatusInfo = nil
        scheduledMidRoll = helper.getNextMidRoll(midRollDurations: midRollDurations)
    }
    
}

extension VMaxZeeAdsPlugin {
    
    private func preroll(){
        vmLog("adsScheduled.preRoll:\(adsScheduled.preRoll)")
        guard adsScheduled.preRoll else {
            scheduledMidRoll = helper.getNextMidRoll(midRollDurations: midRollDurations)
            delegate.requestContentResume()
            return
        }
        guard helper.cuePointExist(seconds: 0, vmaxAdBreakStateInfo: adBreaksRendered) == false else{
            vmLog("preroll rendered")
            scheduledMidRoll = helper.getNextMidRoll(midRollDurations: midRollDurations)
            delegate.requestContentResume()
            return
        }
        requestAdBreak(cuePoint: VMaxAdsConstants.preroll)
    }
    
    private func requestAdBreak(cuePoint: Int){
        vmLog("cuePoint:\(cuePoint)")
        let cuePointsRendered = adBreaksRendered.map{$0.cuePoint}
        guard cuePointsRendered.contains(cuePoint) == false else {
            vmLog("cue point \(cuePoint) already rendered")
            return
        }
        guard let metaObject = metaObjects[String(cuePoint)] else{
            vmLog("cue point:\(cuePoint) not found")
            return
        }
        guard let viewController = config.viewController else{
            vmLog("config.viewController is nil")
            return
        }
        vmaxAdBreak = VMaxAdBreak(vMaxMetaData: metaObject, viewController: viewController)
        if let overlayAdSpot = helper.getLandscapeOverlayAdSpot(vmaxAdsConfig: config) {
            vmaxAdBreak?.adSpotBanner = overlayAdSpot
        }
        vmaxAdBreakStatusInfo = VMaxAdBreakStateInfo(cuePoint: cuePoint)
        guard let vmaxAdBreak = vmaxAdBreak else{
            vmLog("vmaxAdBreak is nil")
            return
        }
        vmLog("requestAdBreak for cuePoint:\(cuePoint)")
        vmaxAdBreak.delegate = self
        if let adBreakEvents = config.adBreakEvents as? VMaxAdEvents {
            vmaxAdBreak.vmaxAdEvents = adBreakEvents
        }
        if let vmaxCompanionAdEvents = config.vmaxCompanionAdEvents{
            vmaxAdBreak.vmaxCompaionAdEvents = vmaxCompanionAdEvents
        }
        vmaxAdBreak.setLayoutInfo(videoLayouts)
        vmaxAdBreak.start()
        if let vmaxAdBreakStatusInfo = vmaxAdBreakStatusInfo{
            adBreaksStarted.append(vmaxAdBreakStatusInfo)
        }
    }
    
    private func clearSkippedMidroll(currentSeconds:Int) {
        guard let scheduledMidRoll = scheduledMidRoll else{
            vmLog("no scheduledMidRoll")
            return
        }
        guard currentSeconds > scheduledMidRoll else {
            vmLog("no cue points to skip")
            return
        }
        var midRollsSkipped = [Int]()
        for midRoll in midRollDurations{
            if midRoll < currentSeconds{
                midRollsSkipped.append(midRoll)
                vmLog("midRoll missed :\(midRoll)")
            }
        }
        midRollsSkipped.sort()
        self.scheduledMidRoll = midRollsSkipped.max()
        if let scheduledMidRoll = self.scheduledMidRoll {
            for midRoll in midRollsSkipped {
                if midRoll != scheduledMidRoll && midRoll < currentSeconds{
                    vmLog("midRoll:\(midRoll) to skip")
                    midRollDurations.remove(midRoll)
                }
            }
        }
        vmLog("scheduledMidRoll:\(String(describing: self.scheduledMidRoll))")
    }
    
    private func addObservers() {
        let sel = #selector(self.orientationChanged(notification:))
        addObserver(sel: sel, name: UIDevice.orientationDidChangeNotification)
    }
    
    private func addObserver(sel: Selector, name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
    }
    
    @objc func orientationChanged(notification: NSNotification) {
        guard let device = notification.object as? UIDevice else {
            vmLog("device is nil", .error)
            return
        }
        vmLog("device.orientation\(device.orientation.rawValue)")
        switch device.orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            rotateView(orientation: device.orientation)
        case .unknown, .faceUp, .faceDown, .portraitUpsideDown:
            vmLog("rotation not supported for current orientation", .error)
        @unknown default:
            vmLog("rotation not supported for current orientation @unknown", .error)
        }
    }
    
    private func rotateView(orientation: UIDeviceOrientation) {
        vmLog("device.orientation\(orientation.rawValue)")
        guard let customView = config.videoView,
              let parentViewController = config.viewController else {
            vmLog("customView | parentViewController is nil")
            return
        }
        let value: Int = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        switch orientation {
        case .portrait:
            UIView.animate(withDuration: 0.3) {
                customView.transform = CGAffineTransform.identity
            }
            //rotated = false
        case .landscapeLeft, .landscapeRight:
            UIView.animate(withDuration: 0.3) {
                customView.transform = CGAffineTransform(from: customView.frame, to: parentViewController.view.frame)
                parentViewController.view.bringSubviewToFront(customView)
            }
            //rotated = true
        case .unknown, .portraitUpsideDown, .faceDown, .faceUp:
            vmLog("unsupported rotation", .error)
        @unknown default:
            vmLog("default unsupported rotation", .error)
        }
    }
    
    private func setupBanner(){
        guard let viewController = config.viewController ,let bannerView = config.bannerView,let bannerAdSpot = helper.getStickyBottomAdSpot(vmaxAdsConfig: config) else {
            return
        }
        let _ = VMaxBannerAdHelper(adSpotKey: bannerAdSpot, bannerView: bannerView, viewController: viewController, delegate: config.vmaxCompanionAdEvents)
    }
    
    private func showLoaderView(){
        DispatchQueue.main.async {
            guard let playerView = self.config.videoView else{
                vmLog("videoView is nil",.error)
                return
            }
            self.blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
            self.activityView = UIActivityIndicatorView(style: .gray)
            guard let blurEffectView = self.blurEffectView, let activityView = self.activityView else{
                vmLog("blurtView is nil",.error)
                return
            }
            blurEffectView.frame = playerView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.8
            playerView.addSubview(blurEffectView)
            activityView.center = playerView.center
            playerView.addSubview(activityView)
            activityView.hidesWhenStopped = true
            activityView.startAnimating()
        }
    }
    
    private func hideLoaderView() {
        DispatchQueue.main.async {
            self.blurEffectView?.removeFromSuperview()
            self.activityView?.stopAnimating()
            self.activityView?.removeFromSuperview()
        }
    }
    
}


