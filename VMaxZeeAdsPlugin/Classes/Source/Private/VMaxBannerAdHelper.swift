//
//  VMaxBannerAdHelper.swift

import Foundation
import UIKit
import VMaxAdsSDK

class VMaxBannerAdHelper : NSObject {
    
    private var vMaxAdView: VMaxAdView
    private var viewController: UIViewController
    private var bannerView: UIView
    private var companionAdEvents: VMaxCompanionAdEvents?
    
    init(adSpotKey:String, bannerView: UIView,viewController: UIViewController,delegate: VMaxCompanionAdEvents?) {
        self.viewController = viewController
        self.bannerView = bannerView
        self.vMaxAdView = VMaxAdView(adspotID: adSpotKey, viewController: viewController, withAdUXType: .banner)
        self.vMaxAdView.viewForVMax = self.bannerView
        self.vMaxAdView.frame = self.bannerView.bounds
        self.bannerView.addSubview(self.vMaxAdView)
        self.bannerView.bringSubviewToFront(self.vMaxAdView)
        self.companionAdEvents = delegate
        super.init()
        self.addSameConstraintsFromParentView(parentView: self.bannerView, childView: vMaxAdView)
        self.vMaxAdView.delegate = self
        self.vMaxAdView.delegateCompanion = self
        self.vMaxAdView.setAdType(.companion)
        self.addObservers()
    }
    
    deinit {
        self.removeObservers()
        self.vMaxAdView.invalidateAd()
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationChanged(notification : NSNotification){
        self.vMaxAdView.layoutSubviews()
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
        self.companionAdEvents?.onCompanionReady()
    }
    
    func onCompanionRender(_ adView: VMaxAdView!) {
        vmLog("onCompanionRender")
        self.companionAdEvents?.onCompanionRender()
    }
    
    func onCompanionError(_ adView: VMaxAdView!) {
        vmLog("onCompanionError")
        //self.companionAdEvents?.onCompanionError(T##error: Error##Error)
    }
    
    func onCompanionClose(_ adView: VMaxAdView!) {
        vmLog("onCompanionClose")
        self.companionAdEvents?.onCompanionClose()
    }
    
    func onCompanionClick(_ adView: VMaxAdView!) {
        vmLog("onCompanionClick")
        self.companionAdEvents?.onCompanionClick()
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
