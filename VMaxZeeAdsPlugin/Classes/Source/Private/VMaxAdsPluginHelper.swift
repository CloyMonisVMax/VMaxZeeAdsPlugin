//
//  VMaxAdsPluginHelper.swift

import Foundation
import VMaxAdsSDK

class VMaxAdsPluginHelper {
    
    func cuePointExist(seconds: Int,vmaxAdBreakStateInfo: [VMaxAdBreakStateInfo]) -> Bool {
        var res = false
        if let _ = vmaxAdBreakStateInfo.filter({ $0.cuePoint == seconds }).first{
            res = true
        }
        return res
    }
    
    func getAdsScheduled(dict: [String: VMaxAdMetaData]) -> (AdsScheduled,Set<Int>) {
        var adsScheduled = AdsScheduled()
        var midRollDurations: Set<Int> = Set<Int>()
        var arrayCuePoints = [Int]()
        for eachObj in dict{
            switch String(eachObj.key) {
            case String(VMaxAdsConstants.preroll):
                adsScheduled.preRoll = true
                arrayCuePoints.append(VMaxAdsConstants.preroll)
            case String(VMaxAdsConstants.postroll):
                adsScheduled.postRoll = true
                arrayCuePoints.append(VMaxAdsConstants.postroll)
            default:
                if let intInSeconds = Int(eachObj.key){
                    adsScheduled.midRoll = true
                    arrayCuePoints.append(intInSeconds)
                    midRollDurations.insert(intInSeconds)
                }
            }
        }
        let cuePoints = arrayCuePoints.sorted().map(String.init).joined(separator: ",")
        vmLog("scheduledCuePoints:\(cuePoints)")
        return (adsScheduled,midRollDurations)
    }
    
    func validate(vmaxAdsConfig: VMaxZeeAdsConfig) throws {
        if vmaxAdsConfig.b2b == nil {
            vmLog("b2b not set in config", .error)
        }
        if vmaxAdsConfig.videoView == nil {
            vmLog("videoView not set in config", .error)
        }
        if vmaxAdsConfig.viewController == nil {
            vmLog("viewController not set in config", .error)
        }
        if vmaxAdsConfig.mediaDuration == nil {
            vmLog("mediaDuration not set in config", .error)
        }
        guard let _ = vmaxAdsConfig.b2b,
              let _ = vmaxAdsConfig.videoView,
              let _ = vmaxAdsConfig.viewController,
              let _ = vmaxAdsConfig.mediaDuration else {
            throw VMaxAdsPluginError.configError
        }
    }
    
    func parseb2b(vmaxAdsConfig: VMaxZeeAdsConfig) throws -> [String: VMaxAdMetaData] {
        let jsonParser = VMaxB2BjsonParser()
        guard let json = vmaxAdsConfig.b2b else {
            throw VMaxJsonParsingError.vmaxInvalid
        }
        let dict = try jsonParser.get(json: json)
        return dict
    }
    
    func getStickyBottomAdSpot(vmaxAdsConfig: VMaxZeeAdsConfig) -> String?{
        let jsonParser = VMaxB2BjsonParser()
        guard let json = vmaxAdsConfig.b2b else{
            return nil
        }
        return jsonParser.getBannerAdSpot(json: json, key: "sticky_bottom")
    }
    
    func getLandscapeOverlayAdSpot(vmaxAdsConfig: VMaxZeeAdsConfig) -> String?{
        let jsonParser = VMaxB2BjsonParser()
        guard let json = vmaxAdsConfig.b2b else{
            return nil
        }
        return jsonParser.getBannerAdSpot(json: json, key: "landscape_overlay")
    }
    
}
