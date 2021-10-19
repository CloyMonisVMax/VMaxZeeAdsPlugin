//
//  VMaxZeeAdsConfig.swift

import Foundation
import VMaxAdsSDK

public class VMaxZeeAdsConfig: NSObject{
    public var b2b: NSDictionary?
    public var videoView: UIView?
    public var viewController: UIViewController?
    public var adBreakEvents: VMaxAdBreakEvents?
    public var mediaDuration: CMTime?
    public var vmaxAdEvents: VMaxAdEvents?
    public var vmaxCompanionAdEvents: VMaxCompanionAdEvents?
    public var bannerView: UIView?
    public var meta: VMaxAdMetaData?
}
extension VMaxZeeAdsConfig {
    public override var debugDescription: String {
        """
        ----------------------------------------------------------------------
        \(String(describing: Swift.type(of: self)))
        ----------------------------------------------------------------------
        b2b:\(String(describing: b2b))
        videoView:\(String(describing: videoView))
        viewController:\(String(describing: viewController))
        adBreakEvents:\(String(describing: adBreakEvents))
        mediaDuration:\(String(describing: mediaDuration))
        vmaxAdEvents:\(String(describing: vmaxAdEvents))
        vmaxCompanionAdEvents:\(String(describing: vmaxCompanionAdEvents))
        bannerView:\(String(describing: bannerView))
        ----------------------------------------------------------------------
        ----------------------------------------------------------------------
        """
    }
}
