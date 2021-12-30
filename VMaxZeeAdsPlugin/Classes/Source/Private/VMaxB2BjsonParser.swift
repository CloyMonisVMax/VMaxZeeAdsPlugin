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

struct TimeBreakMeta{
    var maxTime: Int?
    var expectedTime: Int?
    var endCardTime: Int?
    var useTotalDurationForCompleteAd: Bool?
    var orderByTimeAscending: Bool?
    var allowOnlyCompleteAd: Bool?
}

struct VmaxAndTimeBreakMetaInfo{
    let vMaxAdMetaData: VMaxAdMetaData
    let timeBreakMeta: TimeBreakMeta
}

class VMaxB2BjsonParser{
    
    func get(json: NSDictionary) throws -> [String: VmaxAndTimeBreakMetaInfo]  {
        var dictionary = [String: VmaxAndTimeBreakMetaInfo]()
        let jsonKeyValue = self.parseKeyValuePair(vmaxJson: json)
        attachAccountId(vmaxJson: json)
        parseTimeout(vmaxJson: json)
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
            var timeBreakMeta = TimeBreakMeta()
            if let maxTime = videoBreak["max_time"] as? Int{
                timeBreakMeta.maxTime = maxTime
            }
            if let expectedTime = videoBreak["expected_time"] as? Int{
                timeBreakMeta.expectedTime = expectedTime
            }
            if let endCardTime = videoBreak["end_card_time"] as? Int{
                timeBreakMeta.endCardTime = endCardTime
            }
            if let useTotalDurationForCompleteAd = videoBreak["use_total_duration_for_complete_ad"] as? Bool{
                timeBreakMeta.useTotalDurationForCompleteAd = useTotalDurationForCompleteAd
            }
            if let orderByTimeAscending = videoBreak["order_by_time_ascending"] as? Bool{
                timeBreakMeta.orderByTimeAscending = orderByTimeAscending
            }
            if let allowOnlyCompleteAd = videoBreak["allow_only_complete_ad"] as? Bool{
                timeBreakMeta.allowOnlyCompleteAd = allowOnlyCompleteAd
            }
            let vmaxAndTimeBreakMetaInfo = VmaxAndTimeBreakMetaInfo(vMaxAdMetaData: adMetaData, timeBreakMeta: timeBreakMeta)
            dictionary[cuePoint] = vmaxAndTimeBreakMetaInfo
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
        
    private func parseTimeout(vmaxJson: NSDictionary){
         let vmaxTimeout = VMaxTimeout()
         guard let settings = vmaxJson["settings"] as? NSDictionary else{
             return
         }
         guard let timeout = settings["timeout"] as? NSDictionary else {
             vmaxTimeout.configure(.type3G, type: .mediaLoad, value: 7)
             vmaxTimeout.configure(.type4G, type: .mediaLoad, value: 7)
             vmaxTimeout.configure(.typeWifi, type: .mediaLoad, value: 5)
             vmaxTimeout.configure(.type3G, type: .adRequest, value: 5)
             vmaxTimeout.configure(.type4G, type: .adRequest, value: 5)
             vmaxTimeout.configure(.typeWifi, type: .adRequest, value: 4)
             return
         }
         if let mediaLoad = timeout["media_load"] as? NSDictionary {
             vmLog("VMaxTimeout -----------")
             if let value = mediaLoad["3G"] as? Int32{
                 vmaxTimeout.configure(.type3G, type: .mediaLoad, value: value)
             }else{
                 vmaxTimeout.configure(.type3G, type: .mediaLoad, value: 7)
             }
             vmLog("VMaxTimeout -----------")
             if let value = mediaLoad["4G"] as? Int32{
                 vmaxTimeout.configure(.type4G, type: .mediaLoad, value: value)
             }else{
                 vmaxTimeout.configure(.type4G, type: .mediaLoad, value: 7)
             }
             vmLog("VMaxTimeout -----------")
             if let value = mediaLoad["wifi"] as? Int32{
                 vmaxTimeout.configure(.typeWifi, type: .mediaLoad, value: value)
             }else{
                 vmaxTimeout.configure(.typeWifi, type: .mediaLoad, value: 5)
             }
         }else{
             vmaxTimeout.configure(.type3G, type: .mediaLoad, value: 7)
             vmaxTimeout.configure(.type4G, type: .mediaLoad, value: 7)
             vmaxTimeout.configure(.typeWifi, type: .mediaLoad, value: 5)
         }
         if let adRequest = timeout["ad_request"] as? NSDictionary {
             vmLog("VMaxTimeout -----------")
             if let value = adRequest["3G"] as? Int32{
                 vmaxTimeout.configure(.type3G, type: .adRequest, value: value)
             }else{
                 vmaxTimeout.configure(.type3G, type: .adRequest, value: 5)
             }
             vmLog("VMaxTimeout -----------")
             if let value = adRequest["4G"] as? Int32{
                 vmaxTimeout.configure(.type4G, type: .adRequest, value: value)
             }else{
                 vmaxTimeout.configure(.type4G, type: .adRequest, value: 5)
             }
             vmLog("VMaxTimeout -----------")
             if let value = adRequest["wifi"] as? Int32{
                 vmaxTimeout.configure(.typeWifi, type: .adRequest, value: value)
             }else{
                 vmaxTimeout.configure(.typeWifi, type: .adRequest, value: 4)
             }
         }else{
             vmaxTimeout.configure(.type3G, type: .adRequest, value: 5)
             vmaxTimeout.configure(.type4G, type: .adRequest, value: 5)
             vmaxTimeout.configure(.typeWifi, type: .adRequest, value: 4)
         }
         VMaxAdSDK.setTimeout(vmaxTimeout)
     }
 
}
