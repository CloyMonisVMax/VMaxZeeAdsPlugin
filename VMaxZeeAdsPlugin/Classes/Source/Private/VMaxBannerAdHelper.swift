//
//  VMaxBannerAdHelper.swift

import Foundation
import UIKit
import VMaxAdsSDK

class VMaxBannerAdHelper : NSObject {
    
    private var vMaxAdView: VMaxAdView?
    private var viewController: UIViewController?
    private var bannerView: UIView?
    private var companionAdEvents: VMaxCompanionAdEvents?
    
    init(adSpotKey:String, bannerView: UIView,viewController: UIViewController,delegate: VMaxCompanionAdEvents?) {
        self.bannerView = bannerView
        self.viewController = viewController
        self.companionAdEvents = delegate
        self.vMaxAdView = VMaxAdView(adspotID: adSpotKey, viewController: viewController, withAdUXType: .banner)
        super.init()
        vmLog("")
        guard let vMaxAdView = self.vMaxAdView, let bannerView = self.bannerView else {
            return
        }
        vMaxAdView.frame = bannerView.bounds
        bannerView.addSubview(vMaxAdView)
        bannerView.bringSubviewToFront(vMaxAdView)
        self.addSameConstraintsFromParentView(parentView: bannerView, childView: vMaxAdView)
        vMaxAdView.delegate = self
        vMaxAdView.delegateCompanion = self
        vMaxAdView.setAdType(.companion)
        self.addObservers()
    }
    
    deinit {
        vmLog("")
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationChanged(notification : NSNotification){
        vMaxAdView?.layoutSubviews()
    }
    
    internal func invalidate() {
        removeObservers()
        companionAdEvents = nil
        bannerView = nil
        viewController = nil
        vMaxAdView?.invalidateAd()
        vMaxAdView?.delegate = nil
        vMaxAdView?.delegateCompanion = nil
        vMaxAdView?.removeFromSuperview()
        vMaxAdView = nil
    }
    
}

extension VMaxBannerAdHelper: VMaxAdDelegate {
    
    func onAdReady(_ adView: VMaxAdView!) {
        vmLog("onAdReady")
    }
    
    func onAdError(_ adView: VMaxAdView!, error: Error!) {
        vmLog("onAdError")
    }

    func onAdClose(_ adView: VMaxAdView!) {
        vmLog("onAdClose")
    }

    func onAdMediaEnd(_ completed: Bool, reward: Int, _ adView: VMaxAdView!) {
        vmLog("onAdMediaEnd")
    }
    
}

extension VMaxBannerAdHelper: VMaxCompanionDelegate {
    
    func onCompanionReady(_ adView: VMaxAdView!) {
        vmLog("onCompanionReady")
        companionAdEvents?.onCompanionReady(adView.adslotID)
    }
    
    func onCompanionRender(_ adView: VMaxAdView!) {
        vmLog("onCompanionRender")
        companionAdEvents?.onCompanionRender(adView.adslotID)
    }
    
    func onCompanionError(_ adView: VMaxAdView!) {
        vmLog("onCompanionError")
        companionAdEvents?.onCompanionError(adView.adslotID)
    }
    
    func onCompanionClose(_ adView: VMaxAdView!) {
        vmLog("onCompanionClose")
        companionAdEvents?.onCompanionClose(adView.adslotID)
    }
    
    func onCompanionClick(_ adView: VMaxAdView!) {
        vmLog("onCompanionClick")
        companionAdEvents?.onCompanionClick(adView.adslotID)
    }
}

extension VMaxBannerAdHelper {
    
    private func addSameConstraintsFromParentView(parentView: UIView,childView: UIView){
        DispatchQueue.main.async {
            childView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: childView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: childView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            
            let widthConstraint = NSLayoutConstraint(item: childView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
            
            let heightConstraint = NSLayoutConstraint(item: childView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
            childView.updateConstraintsIfNeeded()
        }
    }
    
}
