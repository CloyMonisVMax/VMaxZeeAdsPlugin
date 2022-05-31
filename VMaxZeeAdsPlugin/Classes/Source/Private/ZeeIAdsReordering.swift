//
//  ZeeIAdsReordering.swift
//  VMaxAdsPluginSource
//
//  Created by Cloy Monis on 15/11/21.
//

import Foundation
import VMaxAdsSDK

class ZeeIAdsReordering : NSObject, IAdsReordering {
    
    func doAdvsReordering(_ adList: [Any]!) -> [Any]! {
        var response: [AdViewMetaData] = [AdViewMetaData]()
        guard let inputAdsList: [AdViewMetaData] = adList as? [AdViewMetaData] else {
            return []
        }
        var bodyAds = inputAdsList.filter{ $0.isMediationAd == false }
        let c2sAds = inputAdsList.filter{ $0.isMediationAd == true }
        bodyAds.sort{ $0.adDuration < $1.adDuration }
        response.append(contentsOf: bodyAds)
        response.append(contentsOf: c2sAds)
        return response
    }
    
}
