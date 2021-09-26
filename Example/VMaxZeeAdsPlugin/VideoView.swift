//
//  VideoView.swift
//  VMaxZeeAdsPlugin_Example
//
//  Created by Cloy Monis on 24/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVKit

class VideoView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
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
