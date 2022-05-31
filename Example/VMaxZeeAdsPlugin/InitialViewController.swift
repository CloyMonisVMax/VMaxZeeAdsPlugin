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

    var playbackObserver: Any?
    var playerObserver: PlayerObserver?
    var avPlayer: AVPlayer?
    var mediaDuration: CMTime?
    var periodicTimeObserver: ((CMTime) -> Void)?
    @IBOutlet var slider: UISlider!
    @IBOutlet var videoView: VideoView!
    @IBOutlet var bannerAdView: UIView!
    let mediaUrl = "https://cfvod.kaltura.com/hls/p/2215841/sp/221584100/serveFlavor/entryId/1_w9zx2eti/v/1/ev/5/flavorId/1_,1obpcggb,3f4sp5qu,1xdbzoa6,k16ccgto,r6q0xdb6,/name/a.mp4/index.m3u8.urlset/master.m3u8"
    var started = false
    var plugin: VMaxZeeAdsPlugin?
    var observeToken: Any?
    var stickyBottomAdSpot: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
        self.bannerAdView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideCompanionView(notification:)), name: NSNotification.Name(kVMaxNotificationHideCompanion), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unHideCompanionView(notification:)), name: NSNotification.Name(kVMaxNotificationUnHideCompanion), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(TAG) viewDidDisappear")
        if isBeingDismissed{
            print("\(TAG) viewDidDisappear isBeingDismissed")
            playerObserver = nil
            if let avPlayer = avPlayer, let playbackObserver = playbackObserver {
                avPlayer.removeTimeObserver(playbackObserver)
            }
            plugin?.stop()
            plugin = nil
            self.avPlayer?.pause()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func hideCompanionView(notification: NSNotification){
        print("\(TAG) hideCompanionView \(String(describing: notification.userInfo))")
        guard let userInfo = notification.userInfo as NSDictionary?, let adSlot = userInfo[kVMaxAdSlotId] as? String, let stickyBottomAdSpot = stickyBottomAdSpot, adSlot == stickyBottomAdSpot else {
            return
        }
        print("\(TAG) hideCompanionView hidden = true \(adSlot)")
        self.bannerAdView.isHidden = true
    }
    
    @objc func unHideCompanionView(notification: NSNotification){
        print("\(TAG) unHideCompanionView \(String(describing: notification.userInfo))")
        guard let userInfo = notification.userInfo as NSDictionary?, let adSlot = userInfo[kVMaxAdSlotId] as? String, let stickyBottomAdSpot = stickyBottomAdSpot, adSlot == stickyBottomAdSpot else {
            return
        }
        print("\(TAG) unHideCompanionView hidden = false \(adSlot)")
        self.bannerAdView.isHidden = false
    }
    
    @IBAction func start(_ sender: Any) {
        guard started == false else {
            return
        }
        started = true
        playContentVideo()
    }
    
    @IBAction func actionDestroy(_ sender: Any) {
        plugin?.stop()
        plugin = nil
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
                
                //avPlayer.play()
                self.mediaDuration = self.avPlayer?.currentItem?.asset.duration
                if let mediaDuration = self.mediaDuration{
                    let mediaDurationSeconds = CMTimeGetSeconds(mediaDuration)
                    print("\(TAG) mediaDurationSeconds:\(mediaDurationSeconds)")
                    self.startPlugin()
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
        if let currentItem = avPlayer.currentItem {
            let sel = #selector(self.playerDidFinishPlaying(note:))
            NotificationCenter.default.addObserver(self, selector: sel,name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        plugin?.stop()
        plugin = nil
    }
    
    func startPlugin(){
        guard let vmaxAdsConfig = getVMaxAdsConfig() else {
            print("vmaxAdsConfig is nil")
            return
        }
        stickyBottomAdSpot = VMaxAdsPluginHelper().getStickyBottomAdSpot(vmaxAdsConfig: vmaxAdsConfig)
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
        playerObserver = PlayerObserver(plugin: plugin)
        if let playerObserver = playerObserver {
            playbackObserver = avPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main, using: playerObserver.addObserver)
        }
    }
    
    @objc func avPlayerDidComplete(notification: NSNotification) {
        print("completed")
        //plugin?.stop()
        //plugin = nil
    }
    
    private func addObservers() {
        let sel = #selector(self.orientationChanged(notification:))
        addObserver(sel: sel, name: NSNotification.Name.UIDeviceOrientationDidChange)
    }
    
    private func addObserver(sel: Selector, name: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: sel, name: name, object: nil)
    }
    
    @objc func orientationChanged(notification: NSNotification) {
        guard let device = notification.object as? UIDevice else {
            print("\(TAG) device is nil")
            return
        }
        print("\(TAG) device.orientation\(device.orientation.rawValue)")
        switch device.orientation {
        case .portrait :
            self.bannerAdView.isHidden = false
        case .landscapeLeft, .landscapeRight:
            self.bannerAdView.isHidden = true
        @unknown default:
            print("\(TAG) rotation not supported for current orientation @unknown")
        }
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
        config.requestedBitrate = 1799
        config.enableLogs = true
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
        plugin?.updateVolumeChange(event: .MUTED, level: 0)
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
        print("\(TAG) onAdTapped")
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
        ""
//        """
//        ----------------------------------------------------------------------
//                    \(String(describing: Swift.type(of: self)))
//        ----------------------------------------------------------------------
//        mediaFile.url:\(String(describing: self.mediaFile.url))
//        mediaFile.bitrate:\(String(describing: self.mediaFile.bitrate))
//        mediaFile.delivery:\(String(describing: self.mediaFile.delivery))
//        mediaFile.height:\(String(describing: self.mediaFile.height))
//        mediaFile.width:\(String(describing: self.mediaFile.width))
//        mediaFile.type:\(String(describing: self.mediaFile.type))
//        adDescription:\(String(describing: self.adDescription))
//        adDuration:\(String(describing: self.adDuration))
//        adTitle:\(String(describing: self.adTitle))
//        isSkippable:\(String(describing: self.isSkippable))
//        adId:\(String(describing: self.adId))
//        adSystem:\(String(describing: self.adSystem))
//        totalAds:\(String(describing: self.totalAds))
//        adPosition:\(String(describing: self.adPosition))
//        isBumper:\(String(describing: self.isBumper))
//        podIndex:\(String(describing: self.podIndex))
//        adMeta:\(String(describing: self.adMeta))
//        videoLayout:\(String(describing: self.videoLayout))
//        ----------------------------------------------------------------------
//        ----------------------------------------------------------------------
//        """
    }
}
