//
//  WoctaLayout.swift
//  VMaxAdsPluginSource
//
//  Created by Cloy Monis on 06/09/21.
//

import Foundation
import VMaxAdsSDK

class WoctaVmaxAdView: VMaxAdView{
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var lblVideoCount: UILabel!
    @IBOutlet var lblSkipAd: UILabel!
    @IBOutlet var btnSkipAd: UIButton!
    @IBOutlet var lblAdText: UILabel!
    @IBOutlet var layoutOverlay: UIView!
    
}

class WoctaUIView: UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var woctaVmaxAdView: WoctaVmaxAdView!
    @IBOutlet var woctaContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    deinit{
        if (self.woctaVmaxAdView.progressView != nil){
            self.woctaVmaxAdView.progressView.removeFromSuperview()
        }
        if (self.woctaVmaxAdView.lblVideoCount != nil){
            self.woctaVmaxAdView.lblVideoCount.removeFromSuperview()
        }
        if (self.woctaVmaxAdView.lblSkipAd != nil){
            self.woctaVmaxAdView.lblSkipAd.removeFromSuperview()
        }
        if (self.woctaVmaxAdView.btnSkipAd != nil){
            self.woctaVmaxAdView.btnSkipAd.removeFromSuperview()
        }
        if (self.woctaVmaxAdView.lblAdText != nil){
            self.woctaVmaxAdView.lblAdText.removeFromSuperview()
        }
        if (self.woctaVmaxAdView.layoutOverlay != nil){
            self.woctaVmaxAdView.layoutOverlay.removeFromSuperview()
        }
        print("deinit WoctaUIView")
    }
    
    private func commonInit(){
        Bundle(for: Self.self).loadNibNamed("WoctaView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.doTagging()
    }
    
    private func doTagging(){
        self.woctaVmaxAdView.lblVideoCount.tag = Int(VMaxAdVideoTag.vmax_video_progresscount.rawValue)
        self.woctaVmaxAdView.progressView.tag = Int(VMaxAdVideoTag.vmax_video_progressbar.rawValue)
        self.woctaVmaxAdView.btnSkipAd.tag = Int(VMaxAdVideoTag.vmax_video_skip_action.rawValue)
        self.woctaVmaxAdView.lblAdText.tag = Int(VMaxAdVideoTag.vmax_video_ad_text.rawValue)
        self.woctaVmaxAdView.lblSkipAd.tag = Int(VMaxAdVideoTag.vmax_video_skip_element.rawValue)
        self.woctaVmaxAdView.layoutOverlay.tag = Int(VMaxAdVideoTag.vmax_video_companion.rawValue)
        self.woctaVmaxAdView.tag = Int(VMaxAdVideoTag.vmax_video_player_container_superview.rawValue)
        self.woctaContainer.tag = Int(VMaxAdVideoTag.vmax_video_player_container.rawValue)
        self.woctaVmaxAdView.layoutOverlay.backgroundColor = .clear
    }
    
}

class SkipAdButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - (bounds.width * 0.3)), bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (bounds.width - (bounds.width * 0.7)))
        }
    }
}

class CTAButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - (bounds.width * 0.2)), bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (bounds.width - (bounds.width * 0.8)))
        }
    }
}

class SkipCounter: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    @IBInspectable
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
}
