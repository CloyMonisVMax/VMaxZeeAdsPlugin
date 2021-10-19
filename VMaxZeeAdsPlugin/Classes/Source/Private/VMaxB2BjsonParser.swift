//
//  VMaxB2BjsonParser.swift

import Foundation
import VMaxAdsSDK

enum VMaxJsonParsingError: Error{
    case vmaxInvalid
    case videoAdsInvalid
    case durationInvalid
    case vmaxMetaArrayInvalid
    case vmaxMetaObjInvalid
    case adSpotKeyInvalid
    case invalidKeyValuePair
    case invalidJson
}

class VMaxB2BjsonParser{
    
    func get(json: NSDictionary) throws -> [String: VMaxAdMetaData]  {
        var dictionary = [String: VMaxAdMetaData]()
        let jsonKeyValue = self.parseKeyValuePair(vmaxJson: json)
        attachAccountId(vmaxJson: json)
        guard let videoAdJson : NSDictionary = json["video_break"] as? NSDictionary else{
            throw VMaxJsonParsingError.videoAdsInvalid
        }
        var arrayCuePoints = [String]()
        for duration in videoAdJson{
            guard let durationAsString: String = duration.key as? String else{
                throw VMaxJsonParsingError.durationInvalid
            }
            arrayCuePoints.append(durationAsString)
        }
        for cuePoint in arrayCuePoints{
            guard let videoBreak: NSDictionary = videoAdJson[cuePoint] as? NSDictionary else{
                break
            }
            var count = 1
            if let requestedAds = videoBreak["requested_ads"] as? Int{
                count = requestedAds
            }
            guard let adspotKey = videoBreak["adspot_key"] as? String else {
                break
            }
            var jsonKeyValues = [String : String]()
            if let json = jsonKeyValue as? [String : String] {
                jsonKeyValues = json
            }
            let adspotKeys = Array(repeating: adspotKey, count: count)
            let adMetaData = VMaxAdMetaData(adSpotKeys: adspotKeys, customData: jsonKeyValues)
            if let maxDurationPerAd = videoBreak["max_duration_per_ad"] as? Int32{
                adMetaData.setMaxDurationPerAd(maxDurationPerAd)
            }
            dictionary[cuePoint] = adMetaData
        }
        return dictionary
    }

    private func parseKeyValuePair(vmaxJson: NSDictionary) -> NSDictionary{
        let mutableJsonKeyValue = NSMutableDictionary()
        if let commonKeyValueJson : NSDictionary = vmaxJson["key_values"] as? NSDictionary{
            for eachPair in commonKeyValueJson{
                if let key : String = eachPair.key as? String{
                    if let val : String = eachPair.value as? String{
                        mutableJsonKeyValue[key] = val
                    }else if let val : NSNumber = eachPair.value as? NSNumber{
                        mutableJsonKeyValue[key] = val
                    }
                }
            }
        }
        return mutableJsonKeyValue
    }
    
    private func attachAccountId(vmaxJson: NSDictionary){
        if let accountId = vmaxJson["account_id"] as? String, let accountIdInt = Int(accountId){
            VMaxAdSDK.setAccountId(accountIdInt)
        }
    }

    func getBannerAdSpot(json: NSDictionary,key: String) -> String?{
        guard let displayAdsJson: NSDictionary = json["display_ads"] as? NSDictionary else{
            return nil
        }
        guard let stickyBottom: NSArray = displayAdsJson[key] as? NSArray else{
            return nil
        }
        guard let adspotKey: NSDictionary = stickyBottom[0] as? NSDictionary else {
            return nil
        }
        guard let key = adspotKey["adspot_key"] as? String else {
            return nil
        }
        return key
    }
 
}
