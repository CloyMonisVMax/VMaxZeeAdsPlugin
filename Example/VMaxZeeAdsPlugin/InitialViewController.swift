//
//  InitialViewController.swift
//  VMaxAdsPluginSource
//
//  Created by Cloy Monis on 18/08/21.
//

import UIKit
import AVKit
import VMaxZeeAdsPlugin
import VMaxAdsSDK
let TAG = "InitialViewController"

class InitialViewController: UIViewController {

    var playerObserver: Any?
    var avPlayer: AVPlayer?
    var mediaDuration: CMTime?
    var periodicTimeObserver: ((CMTime) -> Void)?
    @IBOutlet var slider: UISlider!
    @IBOutlet var videoView: VideoView!
    @IBOutlet var bannerAdView: UIView!
    let mediaUrl = "https://alpha-zee5-media.vmax.com/v/vast/481763_1626776912699_sd.mp4"
    //let mediaUrl = "https://cfvod.kaltura.com/hls/p/2215841/sp/221584100/serveFlavor/entryId/1_w9zx2eti/v/1/ev/5/flavorId/1_,1obpcggb,3f4sp5qu,1xdbzoa6,k16ccgto,r6q0xdb6,/name/a.mp4/index.m3u8.urlset/master.m3u8"
    //let mediaUrl = "https://alpha-zee5-media.vmax.com/v/vast/481763_1626776912699_sd.mp4"
    //let mediaUrl = "https://jioads.akamaized.net/devp/v/s/vast/78853_480795_7083_hd.mp4/master.m3u8?199777.C3752663_480795_ad8c0a70_ccb=[ccb]_A-IO-3.14.7"
    //let mediaUrl = "https://alpha-zee5-media.vmax.com/v/s/vast/78466_1622718741157_sd.mp4/master.m3u8"
    //ascending
    //let mediaUrl = "https://alpha-zee5-media.vmax.com/v/s/vast/78613_a744c0e70ba48ed916e687f246d534fa.mp4/master.m3u8"
    //manipulated
    //let mediaUrl = "https://alpha-zee5-media.vmax.com/v/s/vast/78466_1622718741157_sd.mp4/master.m3u8"
    var started = false
    var plugin: VMaxZeeAdsPlugin?
    var observeToken: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func start(_ sender: Any) {
        guard started == false else {
            return
        }
        started = true
        playContentVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(TAG) viewDidDisappear")
        if isBeingDismissed{
            print("\(TAG) viewDidDisappear isBeingDismissed")
            playerObserver = nil
            plugin?.stop()
            plugin = nil
            self.avPlayer?.pause()
        }
    }
    
    func playContentVideo(){
        guard let contentURL: URL = URL(string: mediaUrl) else {
            print("\(TAG) contentURL is nil ")
            return
        }
        let avUrlAsset = AVURLAsset(url: contentURL)
        let avPlayerItem = AVPlayerItem(asset: avUrlAsset)
        avPlayer = AVPlayer(playerItem: avPlayerItem)
        videoView.player = avPlayer
        guard  let avPlayer = avPlayer else {
            print("\(TAG) avPlayerLayer is nil ")
            return
        }
        observeToken = avPlayer.observe(\.status, options: [.new, .old, .initial, .prior]) { avPlayer, _ in
            let status = avPlayer.status
            switch status {
            case .unknown:
                // playerFailed("AVPlayerItem.status unknown")
                print("\(TAG) unknown")
            case .readyToPlay:
                print("\(TAG) readyToPlay")
                self.mediaDuration = self.avPlayer?.currentItem?.asset.duration
                if let mediaDuration = self.mediaDuration{
                    let mediaDurationSeconds = CMTimeGetSeconds(mediaDuration)
                    print("\(TAG) mediaDurationSeconds:\(mediaDurationSeconds)")
                    self.startPlugin()
                    //self.avPlayer?.play()
                    //AVPlayerItemNewAccessLogEntryNotification
                    //NotificationCenter.default.addObserver(self, selector: #selector(self.avlayerItemNewAccessLogEntry(_:)), name: .AVPlayerItemNewAccessLogEntry, object: self.avPlayer?.currentItem)
                }
            case .failed:
                print("\(TAG) failed")
            @unknown default:
                print("\(TAG) default")
            }
        }
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        avPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main, using: observerAvPlayer(_:))
        slider.addTarget(self, action: #selector(sliderValueChange(_:)), for: .valueChanged)
    }
    
    @objc func avlayerItemNewAccessLogEntry(_ notification: NSNotification) {
        guard let currentItem = notification.object as? AVPlayerItem else{
            print("\(TAG) bitrate currentItem == nil")
            return
        }
        printBitrate(currentItem: currentItem)
    }
    
    func printBitrate(currentItem: AVPlayerItem){
        guard let avPlayerItemAccessLog = currentItem.accessLog() else{
            print("\(TAG) bitrate avPlayerItemAccessLog == nil")
            return
        }
        guard let avPlayerItemAccessLogEvent = avPlayerItemAccessLog.events.last else {
            print("\(TAG) bitrate avPlayerItemAccessLogEvent == nil")
            return
        }
        print("\(TAG) -----------------------------")
        print("\(TAG) indicatedBitrate \(avPlayerItemAccessLogEvent.indicatedBitrate.toSeconds)")
        print("\(TAG) switchBitrate \(avPlayerItemAccessLogEvent.switchBitrate.toSeconds)")
        print("\(TAG) observedBitrate \(avPlayerItemAccessLogEvent.observedBitrate.toSeconds)")
        print("\(TAG) observedMinBitrate \(avPlayerItemAccessLogEvent.observedMinBitrate.toSeconds)")
        print("\(TAG) observedMaxBitrate \(avPlayerItemAccessLogEvent.observedMaxBitrate.toSeconds)")
        print("\(TAG) averageVideoBitrate \(avPlayerItemAccessLogEvent.averageVideoBitrate.toSeconds)")
        print("\(TAG) averageAudioBitrate \(avPlayerItemAccessLogEvent.averageAudioBitrate.toSeconds)")
        print("\(TAG) indicatedAverageBitrate \(avPlayerItemAccessLogEvent.indicatedAverageBitrate.toSeconds)")
        print("\(TAG) observedBitrateStandardDeviation \(avPlayerItemAccessLogEvent.observedBitrateStandardDeviation.toSeconds)")
        print("\(TAG) -----------------------------")
    }
    
    func startPlugin(){
        guard let vmaxAdsConfig = getVMaxAdsConfig() else {
            print("vmaxAdsConfig is nil")
            return
        }
        do{
            plugin = try VMaxZeeAdsPlugin(config: vmaxAdsConfig,delegate: self)
        }catch let error{
            print("error:\(error)")
        }
        guard let plugin = plugin, let avPlayer = self.avPlayer else{
            print("\(TAG) plugin | avPlayer is nil ")
            return
        }
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        let playbackObserver = PlayerObserver(plugin: plugin)
        playerObserver = avPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main, using: playbackObserver.observer(_:))
    }
    
}

extension InitialViewController{
    
    func getVMaxAdsConfig() -> VMaxZeeAdsConfig? {
        guard let filePath = Bundle.main.path(forResource: "b2b", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
           let b2bJson = (try? JSONSerialization.jsonObject(with: data)) as? [AnyHashable:Any] else {
            print("\(TAG) filePath || data || b2bJson is nil ")
              return nil
        }
        guard let duration = self.mediaDuration else {
            print("\(TAG) mediaDuration is nil ")
            return nil
        }
        let config = VMaxZeeAdsConfig()
        config.b2b = b2bJson as NSDictionary
        config.videoView = videoView
        config.viewController = self
        config.adBreakEvents = self
        config.mediaDuration = duration
        config.vmaxAdEvents = self
        config.vmaxCompanionAdEvents = self
        config.bannerView = self.bannerAdView
        config.requestedBitrate = 1788
        return config
    }
    
    @objc func sliderValueChange(_ playbackSlider: UISlider){
        guard let currentItem = avPlayer?.currentItem else {
            return
        }
        let totalDuration = currentItem.duration
        let targetTime = Float(CMTimeGetSeconds(totalDuration)) * playbackSlider.value
        guard let avPlayer = self.avPlayer else {
            return
        }
        print("\(TAG) seek:\(targetTime)) totalDuration:\(CMTimeGetSeconds(totalDuration))")
        avPlayer.seek(to: CMTimeMakeWithSeconds(Float64(targetTime), 1))
    }
    
    public func observerAvPlayer(_ playBackTime: CMTime) {
        if let currentItem = avPlayer?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                // Do sth
                return;
            }
            let currentTime = currentItem.currentTime()
            //print("\(TAG) currentTime: \(CMTimeGetSeconds(playBackTime))")
            slider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        }
    }
    
}

extension Double{
    var toSeconds : Double {
        //return self / Double(1000)
        return self
    }
}

extension InitialViewController: VMaxAdsPluginDelegate{
    
    func requestContentPause() {
        print("\(TAG) requestContentPause")
        guard let avPlayer = avPlayer else {
            print("\(TAG) avPlayer is nil ")
            return
        }
        guard let plugin = plugin else {
            print("\(TAG) plugin is nil ")
            return
        }
        avPlayer.pause()
        plugin.start()
    }
    
    func requestContentResume() {
        print("\(TAG) requestContentPause")
        guard let avPlayer = avPlayer else {
            print("\(TAG) avPlayer is nil ")
            return
        }
        avPlayer.play()
    }
    
}

extension InitialViewController: VMaxAdBreakEvents{
    
    func onAdBreakRequest() {
        print("\(TAG) VMaxAdBreakEvents onAdBreakRequest")
    }
    
    func onAdBreakReady() {
        print("\(TAG) VMaxAdBreakEvents onAdBreakReady")
    }
    
    func onAdBreakStart() {
        print("\(TAG) VMaxAdBreakEvents onAdBreakStart")
    }
    
    func onAdBreakError(_ error: VMaxError) {
        print("\(TAG) VMaxAdBreakEvents onAdBreakError:\(error)")
        guard let avPlayer = avPlayer else {
            print("\(TAG) avPlayer is nil ")
            return
        }
        print("\(TAG) avPlayer.play")
        avPlayer.play()
    }
    
    func onAdBreakComplete() {
        print("\(TAG) VMaxAdBreakEvents onAdBreakComplete")
        guard let avPlayer = avPlayer else {
            print("\(TAG) avPlayer is nil ")
            return
        }
        print("\(TAG) avPlayer.play")
        avPlayer.play()
    }
    
}

extension InitialViewController: VMaxAdEvents{
    
    func onAdInit() {
        print("\(TAG) VMaxAdEvents onAdInit")
    }
    
    func onAdReady(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdReady vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
        print("test")
    }
    
    func onAdError(_ vmaxAdInfo: VmaxAdInfo, error: Error) {
        print("\(TAG) VMaxAdEvents onAdError : error:\(error)")
    }
    
    func onAdRender(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdRender vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdImpression(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdImpression vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaStart(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaStart vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaFirstQuartile(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaFirstQuartile vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaMidPoint(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaMidPoint vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaThirdQuartile(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaThirdQuartile vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaEnd(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaEnd vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaExpand(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaExpand vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdMediaCollapse(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdMediaCollapse vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdClick(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdClick vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdSkip(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdSkip vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdClose(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdClose vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdPause(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdPause vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func onAdResume(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) VMaxAdEvents onAdResume vmaxAdInfo:\(getAdInfo(vmaxAdInfo))")
    }
    
    func getAdInfo(_ vmaxAdInfo: VmaxAdInfo) -> String{
        return vmaxAdInfo.debugDescription
    }
    
    func onAdMediaBitrateChange(_ bitrate: Float) {
        print("\(TAG) onAdMediaBitrateChange\(bitrate)")
    }
    
    func onAdTapped(_ vmaxAdInfo: VmaxAdInfo) {
        print("\(TAG) onAdTapped\(vmaxAdInfo)")
    }
    
}

extension InitialViewController : VMaxCompanionAdEvents{
    
    func onCompanionReady(_ adSlotId: String) {
        print("\(TAG) VMaxCompanionAdEvents onCompanionReady adSlotId:\(adSlotId)")
    }
    
    func onCompanionClose(_ adSlotId: String) {
        print("\(TAG) VMaxCompanionAdEvents onCompanionClose adSlotId:\(adSlotId)")
    }
    
    func onCompanionRender(_ adSlotId: String) {
        print("\(TAG) VMaxCompanionAdEvents onCompanionRender adSlotId:\(adSlotId)")
    }
    
    func onCompanionClick(_ adSlotId: String) {
        print("\(TAG) VMaxCompanionAdEvents onCompanionClick adSlotId:\(adSlotId)")
    }
    
    func onCompanionError(_ adSlotId: String) {
        print("\(TAG) VMaxCompanionAdEvents onCompanionError adSlotId:\(adSlotId)")
    }
}

extension VmaxAdInfo {
    open override var debugDescription: String {
        """
        ----------------------------------------------------------------------
                    \(String(describing: Swift.type(of: self)))
        ----------------------------------------------------------------------
        mediaFile.url:\(String(describing: self.mediaFile.url))
        mediaFile.bitrate:\(String(describing: self.mediaFile.bitrate))
        mediaFile.delivery:\(String(describing: self.mediaFile.delivery))
        mediaFile.height:\(String(describing: self.mediaFile.height))
        mediaFile.width:\(String(describing: self.mediaFile.width))
        mediaFile.type:\(String(describing: self.mediaFile.type))
        adDescription:\(String(describing: self.adDescription))
        adDuration:\(String(describing: self.adDuration))
        adTitle:\(String(describing: self.adTitle))
        isSkippable:\(String(describing: self.isSkippable))
        adId:\(String(describing: self.adId))
        adSystem:\(String(describing: self.adSystem))
        totalAds:\(String(describing: self.totalAds))
        adPosition:\(String(describing: self.adPosition))
        isBumper:\(String(describing: self.isBumper))
        podIndex:\(String(describing: self.podIndex))
        adMeta:\(String(describing: self.adMeta))
        videoLayout:\(String(describing: self.videoLayout))
        ----------------------------------------------------------------------
        ----------------------------------------------------------------------
        """
    }
}


extension InitialViewController {
    private func addObservers() {
        let sel = #selector(self.orientationChanged(notification:))
        addObserver(sel: sel, name: NSNotification.Name.UIDeviceOrientationDidChange)
    }
    
    private func addObserver(sel: Selector, name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
    }
    
    @objc func orientationChanged(notification: NSNotification) {
        //if orientationUpdatedProgramtically != nil {
        //    orientationUpdatedProgramtically = nil
        //    return
        //}
        guard let device = notification.object as? UIDevice else {
            print("\(TAG) device is nil")
            return
        }
        print("\(TAG) device.orientation\(device.orientation.rawValue)")
        switch device.orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            rotateView(orientation: device.orientation)
        case .unknown, .faceUp, .faceDown, .portraitUpsideDown:
            print("\(TAG) rotation not supported for current orientation")
        @unknown default:
            print("\(TAG) rotation not supported for current orientation @unknown")
        }
    }
    
    private func rotateView(orientation: UIDeviceOrientation) {
        print("\(TAG) device.orientation\(orientation.rawValue)")
        //guard let customView = config.videoView,
        //      let parentViewController = config.viewController else {
        //    vmLog("customView | parentViewController is nil")
        //    return
        //}
        let value: Int = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        switch orientation {
        case .portrait:
            UIView.animate(withDuration: 0.3) {
                self.videoView.transform = CGAffineTransform.identity
            }
            //rotated = false
        case .landscapeLeft, .landscapeRight:
            print("\(TAG) unsupported rotation")
            //UIView.animate(withDuration: 0.3) {
            //    self.videoView.transform = CGAffineTransform(from: self.videoView.frame as! Decoder, to: self.view.frame)
            //}
            //rotated = true
        case .unknown, .portraitUpsideDown, .faceDown, .faceUp:
            print("\(TAG) unsupported rotation")
        @unknown default:
            print("\(TAG) default unsupported rotation")
        }
    }
}
