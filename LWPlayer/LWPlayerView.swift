//
//  LWPlayerView.swift
//  LWPlayer
//
//  Created by Lynch Wong on 10/19/15.
//  Copyright © 2015 Lynch. All rights reserved.
//

import UIKit
import AVFoundation

class LWPlayerView: UIView {
    
    var player: AVPlayer {
        set {
            (layer as! AVPlayerLayer).player = newValue
        }
        get {
            return (layer as! AVPlayerLayer).player!
        }
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.classForCoder()
    }

}
