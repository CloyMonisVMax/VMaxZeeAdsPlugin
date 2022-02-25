//
//  ZeeLayout.swift
//  VMaxAdsPluginSource
//
//  Created by Cloy Monis on 07/09/21.
//

import Foundation
import VMaxAdsSDK

class ZeeVmaxAdView: VMaxAdView{
    
    @IBOutlet var btnCTA: UIButton!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var lblVideoCount: UILabel!
    @IBOutlet var lblSkipAd: UILabel!
    @IBOutlet var btnSkipAd: UIButton!
    @IBOutlet var lblAdText: UILabel!
    @IBOutlet var layoutOverlay: UIView!
    
}

class ZeeUIView: UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var zeeVmaxAdView: ZeeVmaxAdView!
    @IBOutlet var zeeContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    deinit{
        if (self.zeeVmaxAdView.btnCTA != nil){
            self.zeeVmaxAdView.btnCTA.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.progressView != nil){
            self.zeeVmaxAdView.progressView.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.lblVideoCount != nil){
            self.zeeVmaxAdView.lblVideoCount.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.lblSkipAd != nil){
            self.zeeVmaxAdView.lblSkipAd.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.btnSkipAd != nil){
            self.zeeVmaxAdView.btnSkipAd.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.lblAdText != nil){
            self.zeeVmaxAdView.lblAdText.removeFromSuperview()
        }
        if (self.zeeVmaxAdView.layoutOverlay != nil){
            self.zeeVmaxAdView.layoutOverlay.removeFromSuperview()
        }
        print("deinit ZeeUIView")
    }
    
    private func commonInit(){
        Bundle(for: Self.self).loadNibNamed("ZeeView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.doTagging()
    }
    
    private func doTagging(){
        self.zeeVmaxAdView.btnCTA.tag = Int(VMaxAdVideoTag.vmax_video_cta.rawValue)
        self.zeeVmaxAdView.lblVideoCount.tag = Int(VMaxAdVideoTag.vmax_video_progresscount.rawValue)
        self.zeeVmaxAdView.progressView.tag = Int(VMaxAdVideoTag.vmax_video_progressbar.rawValue)
        self.zeeVmaxAdView.btnSkipAd.tag = Int(VMaxAdVideoTag.vmax_video_skip_action.rawValue)
        self.zeeVmaxAdView.lblAdText.tag = Int(VMaxAdVideoTag.vmax_video_ad_text.rawValue)
        self.zeeVmaxAdView.lblSkipAd.tag = Int(VMaxAdVideoTag.vmax_video_skip_element.rawValue)
        self.zeeVmaxAdView.layoutOverlay.tag = Int(VMaxAdVideoTag.vmax_video_companion.rawValue)
        self.zeeVmaxAdView.tag = Int(VMaxAdVideoTag.vmax_video_player_container_superview.rawValue)
        self.zeeContainer.tag = Int(VMaxAdVideoTag.vmax_video_player_container.rawValue)
        self.zeeVmaxAdView.layoutOverlay.backgroundColor = .clear
    }
    
}
