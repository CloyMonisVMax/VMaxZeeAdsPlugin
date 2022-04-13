//
//  Models.swift

import Foundation
import UIKit

enum VMaxAdsPluginError: Error {
    case configError
}

struct VMaxAdBreakStateInfo {
    let cuePoint: Int
    private(set) var requested: Bool
    init(cuePoint: Int) {
        self.cuePoint = cuePoint
        self.requested = true
    }
}

struct AdsScheduled {
    var preRoll = false
    var midRoll = false
    var postRoll = false
}

struct VMaxAdsConstants {
    static let preroll = 0
    static let postroll = -1
}

class ZeeSkipAdButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 5, left: -40, bottom: 0, right: 0)
        }
        let borderWidth = 0.5
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: frame.height - borderWidth, width: frame.width, height: borderWidth)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(bottomLayer)
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: borderWidth)
        topLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(topLayer)
        let leftLayer = CALayer()
        leftLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.height)
        leftLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(leftLayer)
    }
}

class VMaxAdSkipCounterLabel : UILabel{
    override func drawText(in rect: CGRect) {
        let borderWidth = 0.5
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: frame.height - borderWidth, width: frame.width, height: borderWidth)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(bottomLayer)
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: borderWidth)
        topLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(topLayer)
        let leftLayer = CALayer()
        leftLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.height)
        leftLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(leftLayer)
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.drawText(in: rect.inset(by: insets))
    }
}

extension CGAffineTransform {
    init(from source: CGRect, to destination: CGRect) {
        let transform = CGAffineTransform.identity
            .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
            .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
        self.init(a: transform.a, b: transform.b, c: transform.c, d: transform.d, tx: transform.tx, ty: transform.ty)
    }
}
