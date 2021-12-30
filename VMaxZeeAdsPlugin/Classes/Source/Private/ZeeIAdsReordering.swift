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
        for eachObj in adList{
            if let adViewMetaObj: AdViewMetaData = eachObj as? AdViewMetaData{
                response.append(adViewMetaObj)
            }
        }
        response.sort{ $0.adDuration < $1.adDuration }
        return response
    }
    
}
