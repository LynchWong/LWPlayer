//
//  LWPlayerViewController.swift
//  LWPlayer
//
//  Created by Lynch on 10/15/15.
//  Copyright © 2015 Lynch. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class LWPlayerViewController: UIViewController {
    
    // MARK: - P
    
    let videoPath = "http://localhost:12345/wifi_640_index.m3u8"//视频播放地址
    let radio = CGFloat(375.0 / 238.0)//缩放比例
    let width = UIScreen.mainScreen().bounds.size.width//屏幕宽度
    
    let playContentView = UIView()//播放器容器视图
    let toolContentView = UIView()//播放器工具容器视图
    
    let playButton = UIButton()//播放按钮
    let muteButton = UIButton()//静音按钮
    let progress = UISlider()//播放进度
    let srtsButton = UIButton()//字幕按钮
    let fullButton = UIButton()//全屏按钮
    
    var player: AVPlayer!//播放器
    var playerView = LWPlayerView()//播放视图
    
    var hideTool = false
    
    var timeObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        initPlayer()
        initView()
    }

    func initPlayer() {
        let url = NSURL(string: videoPath)!
        let playerItem = AVPlayerItem(URL: url)
        player = AVPlayer(playerItem: playerItem)
        addProgressObserver()
    }
    
    func initView() {
        
        playContentView.backgroundColor = UIColor.blackColor()
        view.addSubview(playContentView)
        playContentView.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(view)
            make.width.equalTo(playContentView.snp_height).multipliedBy(radio)
        }
        
        playerView.player = player
        playerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("sigleTapAction")))
        playContentView.addSubview(playerView)
        playerView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(playContentView)
        }
        
        toolContentView.backgroundColor = UIColor(red: 56.0/255.0, green: 62.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        playContentView.addSubview(toolContentView)
        toolContentView.snp_makeConstraints { (make) -> Void in
            make.left.bottom.right.equalTo(playContentView)
            make.height.equalTo(30.0)
        }
        
        playButton.setImage(UIImage(named: "pause_icon_vertical"), forState: UIControlState.Normal)
        playButton.setImage(UIImage(named: "play_icon_vertical"), forState: UIControlState.Selected)
        muteButton.setImage(UIImage(named: "sound_on_vertical"), forState: UIControlState.Normal)
        muteButton.setImage(UIImage(named: "sound_off_vertical"), forState: UIControlState.Selected)
        srtsButton.setImage(UIImage(named: "chinese_english_shift_vertical"), forState: UIControlState.Normal)
        srtsButton.setImage(UIImage(named: "english_shift_vertical"), forState: UIControlState.Selected)
        fullButton.setImage(UIImage(named: "full_screen_icon_vertical"), forState: UIControlState.Normal)
        
        progress.minimumValue = 0.0
        progress.maximumValue = 1.0
        progress.continuous = false
        progress.setThumbImage(UIImage(named: "VKScrubber_thumb_vertical"), forState: UIControlState.Normal)
        progress.value = 0.0
        progress.minimumTrackTintColor = UIColor(red: 10 / 255, green: 137 / 255, blue: 153 / 255, alpha: 1.0)
        progress.maximumTrackTintColor = UIColor(red: 10 / 255, green: 137 / 255, blue: 153 / 255, alpha: 0.4)
        progress.addTarget(self, action: Selector("updateProgress:"), forControlEvents: UIControlEvents.ValueChanged)
        
        playButton.addTarget(self, action: Selector("playAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        muteButton.addTarget(self, action: Selector("muteAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        srtsButton.addTarget(self, action: Selector("srtsAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        fullButton.addTarget(self, action: Selector("fullAction:"), forControlEvents: UIControlEvents.TouchUpInside)
      
        toolContentView.addSubview(playButton)
        toolContentView.addSubview(muteButton)
        toolContentView.addSubview(progress)
        toolContentView.addSubview(srtsButton)
        toolContentView.addSubview(fullButton)
        
        playButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(10.0)
            make.centerY.equalTo(toolContentView.snp_centerY)
            make.height.width.equalTo(20.0)
        }
        
        muteButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(playButton.snp_right).offset(13.0)
            make.centerY.equalTo(toolContentView.snp_centerY)
            make.height.width.equalTo(20.0)
        }
        
        progress.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(muteButton.snp_right).offset(22.0)
            make.right.equalTo(srtsButton.snp_left).offset(-16.0)
            make.centerY.equalTo(toolContentView.snp_centerY)
            make.height.equalTo(2.0)
        }
        
        srtsButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(fullButton.snp_left).offset(-14.0)
            make.centerY.equalTo(toolContentView.snp_centerY)
            make.height.width.equalTo(20.0)
        }
        
        fullButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-10.0)
            make.centerY.equalTo(toolContentView.snp_centerY)
            make.height.width.equalTo(20.0)
        }
    }
    
    func updateProgress(sender: UISlider) {
        removeProgressObserve()
        let progress = Float64(sender.value)
        let seekTime = CMTimeGetSeconds(player.currentItem!.duration) * progress
        player.seekToTime(CMTimeMakeWithSeconds(seekTime, 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (finished: Bool) -> Void in
            if finished {
                self.addProgressObserver()
            }
        }
    }
    
    func addProgressObserver() {
        let playerItem = player.currentItem!
        timeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue()) { (time: CMTime) -> Void in
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(playerItem.duration)
            let progress = current / total
            self.progress.setValue(Float(progress), animated: true)
        }
    }
    
    func removeProgressObserve() {
        player.removeTimeObserver(timeObserver)
    }
    
    func sigleTapAction() {
        if hideTool {
            hideTool = false
            navigationController?.navigationBar.hidden = false
            toolContentView.hidden = false
        } else {
            hideTool = true
            navigationController?.navigationBar.hidden = true
            toolContentView.hidden = true
        }
    }
    
    func playAction(sender: UIButton) {
        if player.rate == 0 {
            player.play()
            sender.selected = true
        } else {
            player.pause()
            sender.selected = false
        }
    }
    
    func muteAction(sender: UIButton) {
        if player.muted {
            player.muted = false
            sender.selected = false
        } else {
            player.muted = true
            sender.selected = true
        }
    }
    
    func srtsAction(sender: UIButton) {
        
    }
    
    func fullAction(sender: UIButton) {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait {
            UIDevice.currentDevice().setValue(NSNumber(integer: UIInterfaceOrientation.LandscapeRight.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        } else {
            UIDevice.currentDevice().setValue(NSNumber(integer: UIInterfaceOrientation.Portrait.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            playContentView.snp_remakeConstraints { (make) -> Void in
                make.edges.equalTo(view)
            }
            
            toolContentView.snp_remakeConstraints { (make) -> Void in
                make.left.bottom.right.equalTo(playContentView)
                make.height.equalTo(52.0)
            }
            
            playButton.setImage(UIImage(named: "pause_icon_landscape"), forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "play_icon_landscape"), forState: UIControlState.Selected)
            muteButton.setImage(UIImage(named: "sound_on_landscape"), forState: UIControlState.Normal)
            muteButton.setImage(UIImage(named: "sound_off_landscape"), forState: UIControlState.Selected)
            srtsButton.setImage(UIImage(named: "chinese_english_shift_landscape"), forState: UIControlState.Normal)
            srtsButton.setImage(UIImage(named: "english_shift_landscape"), forState: UIControlState.Selected)
            fullButton.setImage(UIImage(named: "full_screen_icon_landscape"), forState: UIControlState.Normal)
            progress.setThumbImage(UIImage(named: "VKScrubber_thumb_landscape"), forState: UIControlState.Normal)
            
            playButton.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(25.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(24.0)
            }
            
            muteButton.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(playButton.snp_right).offset(32.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(24.0)
            }
            
            progress.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(muteButton.snp_right).offset(30.0)
                make.right.equalTo(srtsButton.snp_left).offset(-31.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.equalTo(4.0)
            }
            
            srtsButton.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(fullButton.snp_left).offset(-26.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(24.0)
            }
            
            fullButton.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(-27.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(24.0)
            }
        } else {
            playContentView.snp_remakeConstraints { (make) -> Void in
                make.top.left.right.equalTo(view)
                make.width.equalTo(playContentView.snp_height).multipliedBy(radio)
            }
            
            toolContentView.snp_remakeConstraints { (make) -> Void in
                make.left.bottom.right.equalTo(playContentView)
                make.height.equalTo(30.0)
            }
            UIApplication.sharedApplication().statusBarHidden = true
            playButton.setImage(UIImage(named: "pause_icon_vertical"), forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "play_icon_vertical"), forState: UIControlState.Selected)
            muteButton.setImage(UIImage(named: "sound_on_vertical"), forState: UIControlState.Normal)
            muteButton.setImage(UIImage(named: "sound_off_vertical"), forState: UIControlState.Selected)
            srtsButton.setImage(UIImage(named: "chinese_english_shift_vertical"), forState: UIControlState.Normal)
            srtsButton.setImage(UIImage(named: "english_shift_vertical"), forState: UIControlState.Selected)
            fullButton.setImage(UIImage(named: "full_screen_icon_vertical"), forState: UIControlState.Normal)
            progress.setThumbImage(UIImage(named: "VKScrubber_thumb_vertical"), forState: UIControlState.Normal)
            
            playButton.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(10.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(20.0)
            }
            
            muteButton.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(playButton.snp_right).offset(13.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(20.0)
            }
            
            progress.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(muteButton.snp_right).offset(22.0)
                make.right.equalTo(srtsButton.snp_left).offset(-16.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.equalTo(2.0)
            }
            
            srtsButton.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(fullButton.snp_left).offset(-14.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(20.0)
            }
            
            fullButton.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(-10.0)
                make.centerY.equalTo(toolContentView.snp_centerY)
                make.height.width.equalTo(20.0)
            }
        }
    }

}
