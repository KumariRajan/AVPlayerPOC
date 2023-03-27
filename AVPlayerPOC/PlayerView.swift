//
//  PlayerView.swift
//  AVPlayerPOC
//
//  Created by Kumari Rajan on 16/03/23.
//

import Foundation
import AVFoundation
import UIKit

protocol PlayerViewDelegate {
    func onDurationChanged(progressTime: CMTime, currentDuration: CMTime)
    func onPlaybackStarted()
}

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
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
    
    private var playerItemContext = 0
    // Keep the reference and use it to observe the loading status.
    private var playerItem: AVPlayerItem?
    var delegate: PlayerViewDelegate?
    
    var isPlaying = false
    
    var lastObservedBitrate: Double = 0
    var mostRecentBitrate: Double = 0
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                print(".failed")
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        let interval = CMTime(value: 1, timescale: 2)
            
        DispatchQueue.main.async { [weak self] in
            self?.player = AVPlayer(playerItem: self?.playerItem!)
        }
    }
    
    func addObserverForBitrate() {
//        NSNotificationCenter.defaultCenter.addObserver(self, selector:#selector(self.accessLogEvent), name: AVPlayerItemNewAccessLogEntryNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.accessLogEvent), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: nil)
    }
    
    @objc func accessLogEvent(notification: NSNotification) {
        guard let item = notification.object as? AVPlayerItem,
              let accessLog = item.accessLog() else {
                return
        }
        accessLog.events.forEach { lastEvent in
            let bitrate = lastEvent.indicatedBitrate
            lastObservedBitrate = lastEvent.observedBitrate
//            if let mostRecentBitrate = self.mostRecentBitrate, bitrate != mostRecentBitrate {
//                self.mostRecentBitrate = bitrate
//            }
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        print("key:\(keyPath)")
            
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player?.play()
                self.delegate?.onPlaybackStarted()
                self.onDurationChangedObserver()
                self.changeQuality()
            case .failed:
                print(".failed")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
        
    }

    func play(with url: URL) {
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.setUpPlayerItem(with: asset)
        }
        self.isPlaying = true
    }
    
    func play() {
        self.player?.play()
        self.isPlaying = true
    }
    
    func pause() {
        self.player?.pause()
        self.isPlaying = false
    }
    
    func changeQuality() {
        self.player?.currentItem?.preferredPeakBitRate = 2304
    }
    
    func setAudio() {
        
    }
    
    func audioSessionObserver() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers) //For playing volume when phone is on silent
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func seekForward() {
        let currentTime = self.player?.currentTime()
        let timeToAdd   = CMTimeMakeWithSeconds(15,preferredTimescale: 1);
        if let currentTime = currentTime {
            let resultTime  = CMTimeAdd(currentTime,timeToAdd)
            self.player?.seek(to: resultTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    func seekBackward() {
        let currentTime = self.player?.currentTime()
        let timeToSubtract   = CMTimeMakeWithSeconds(15,preferredTimescale: 1);
        if let currentTime = currentTime {
            let resultTime  = CMTimeSubtract(currentTime,timeToSubtract)
            self.player?.seek(to: resultTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    func seekPosition() {
//        self.player?.seek(to: <#T##CMTime#>, toleranceBefore: <#T##CMTime#>, toleranceAfter: <#T##CMTime#>)
    }
    
    func onDurationChangedObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(Int(seconds) % 60))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            
//                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            print("seconds: \(secondsString)")
            print("minutesString: \(minutesString)")
            print("bitrate:\(self.player?.currentItem?.preferredPeakBitRate)")
            
            //lets move the slider thumb
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.delegate?.onDurationChanged(progressTime: progressTime, currentDuration: duration)
//                    self.videoSlider.value = Float(seconds / durationSeconds)
                
            }
            
        })
    }
}

