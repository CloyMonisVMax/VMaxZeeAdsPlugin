//
//  VMaxAdsPlugin.swift

import Foundation
import VMaxAdsSDK

public class VMaxZeeAdsPlugin: NSObject {
    
    private var config: VMaxZeeAdsConfig
    private var delegate: VMaxAdsPluginDelegate
    private var metaObjects: [String: VmaxAndTimeBreakMetaInfo] = [String: VmaxAndTimeBreakMetaInfo]()
    private var vmaxAdBreak: VMaxAdBreak?
    private var vmaxAdBreakEvents: VMaxAdBreakEvents?
    private var vmaxAdBreakStatusInfo: VMaxAdBreakStateInfo?
    private var midRollDurations: Set<Int> = Set<Int>()
    private var selectedMidRoll: Int?
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
        guard let selectedMidRoll = selectedMidRoll else{
            vmLog("no cue point to start",.error)
            delegate.requestContentResume()
            return
        }
        guard helper.cuePointExist(seconds: selectedMidRoll, vmaxAdBreakStateInfo: adBreaksRendered) == false else{
            vmLog("\(selectedMidRoll) cue point already rendered",.error)
            delegate.requestContentResume()
            return
        }
        requestAdBreak(cuePoint: selectedMidRoll)
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
    
    public func stop(){
        vmLog("")
        hideLoaderView()
        self.vmaxAdBreak?.delegate = nil
        self.vmaxAdBreak?.invalidate()
        self.vmaxAdBreak = nil
    }
    
    public func playbackObserver(_ playBackTime: CMTime) {
        let currentSecond = Int(CMTimeGetSeconds(playBackTime))
        let midRollsFiltered = midRollDurations.filter(){ $0 <= currentSecond }
        vmLog("currentSecond:\(currentSecond),midRollDurations:\(midRollDurations),midRollsFiltered:\(midRollsFiltered)")
        let scratchForward = (currentSecond - lastPlayedSecond) >= 2
        if let mediaDuration = config.mediaDuration,
           currentSecond >= Int(CMTimeGetSeconds(mediaDuration)) &&
            adsScheduled.postRoll && helper.cuePointExist(seconds: VMaxAdsConstants.postroll, vmaxAdBreakStateInfo: adBreaksStarted) == false {
            requestAdBreak(cuePoint: VMaxAdsConstants.postroll)
        }else if midRollDurations.contains(currentSecond) && cueNotRendered(currentSecond) && selectedMidRoll == nil {
            selectedMidRoll = currentSecond
            if let selectedMidRoll = selectedMidRoll{
                vmLog("Found Cue Point\(selectedMidRoll)")
                delegate.requestContentPause()
            }
        }else if let maxCuePoint = midRollsFiltered.max(),let minCuePoint = midRollsFiltered.min(),
                 scratchForward && cueNotRendered(maxCuePoint) && selectedMidRoll == nil && currentSecond > minCuePoint
                {
            selectedMidRoll = maxCuePoint
            if let selectedMidRoll = selectedMidRoll{
                vmLog("Found Cue Point after scratch\(selectedMidRoll)")
                delegate.requestContentPause()
            }
        }
        if currentSecond != lastPlayedSecond{
            lastPlayedSecond = currentSecond
        }
    }
    
    public func updateVolumeChange(event: VMaxVolumeEvents, level: Float){
        vmaxAdBreak?.updateVolumeChange(event, withLevel: CGFloat(level))
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
            if let currentMidroll = selectedMidRoll {
                vmLog("currentMidroll:\(currentMidroll) done")
                self.selectedMidRoll = nil
                midRollDurations.remove(currentMidroll)
            }
        }
        adBreaksRendered.append(vmaxAdBreakStatusInfo)
        self.vmaxAdBreakStatusInfo = nil
    }
    
}

extension VMaxZeeAdsPlugin {
    
    private func preroll(){
        vmLog("adsScheduled.preRoll:\(adsScheduled.preRoll)")
        guard adsScheduled.preRoll else {
            delegate.requestContentResume()
            return
        }
        guard helper.cuePointExist(seconds: 0, vmaxAdBreakStateInfo: adBreaksRendered) == false else{
            vmLog("preroll rendered")
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
        let timeBreakMeta = metaObject.timeBreakMeta
        let vMaxAdMetaData = metaObject.vMaxAdMetaData
        if let endCardTime = timeBreakMeta.endCardTime{
            vMaxAdMetaData.endCardTime = endCardTime
        }
        vmaxAdBreak = VMaxAdBreak(vMaxMetaData: vMaxAdMetaData , viewController: viewController)
        if let overlayAdSpot = helper.getLandscapeOverlayAdSpot(vmaxAdsConfig: config) {
            vmaxAdBreak?.adSpotBanner = overlayAdSpot
        }
        vmaxAdBreakStatusInfo = VMaxAdBreakStateInfo(cuePoint: cuePoint)
        guard let vmaxAdBreak = vmaxAdBreak else{
            vmLog("vmaxAdBreak is nil")
            return
        }
        if let maxTime = timeBreakMeta.maxTime {
            vmaxAdBreak.setMaxTimeInSeconds(UInt32(maxTime))
        }
        if let expectedTime = timeBreakMeta.expectedTime {
            vmaxAdBreak.setExpectedTimeInSeconds(UInt32(expectedTime))
        }
        if let useTotalDurationForCompleteAd = timeBreakMeta.useTotalDurationForCompleteAd {
            vmaxAdBreak.useTotalDuration(forCompleteAd: useTotalDurationForCompleteAd)
        }
        if let allowCompleteAd = timeBreakMeta.allowOnlyCompleteAd {
            vmaxAdBreak.allowOnlyCompleteAd(allowCompleteAd)
        }
        if let orderByAscending = timeBreakMeta.orderByTimeAscending, orderByAscending == true{
            let zeeAdsReordering = ZeeIAdsReordering()
            vmaxAdBreak.enable(zeeAdsReordering)
        }
        if let bitrate = config.requestedBitrate, bitrate > 0{
            vmaxAdBreak.setRequestedBitrate(UInt32(bitrate))
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
            blurEffectView.alpha = 1
            playerView.addSubview(blurEffectView)
            activityView.center = CGPoint(x: playerView.frame.width/2, y: playerView.frame.height/2)
            activityView.color = UIColor.white
            playerView.addSubview(activityView)
            playerView.bringSubviewToFront(activityView)
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
    
    private func cueNotRendered(_ seconds: Int) -> Bool{
        return helper.cuePointExist(seconds: seconds, vmaxAdBreakStateInfo: adBreaksRendered) == false
    }
    
    private func cuePointsRenderedForwardScratch(_ seconds: Int) -> Bool{
        vmLog("seconds:\(seconds)")
        var response = false
        for each in adBreaksRendered{
            vmLog("each.cuePoint:\(each.cuePoint)")
            if each.cuePoint < seconds{
                response = true
                break
            }
        }
        return response
    }
    
}
