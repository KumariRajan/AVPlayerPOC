//
//  ViewController.swift
//  AVPlayerPOC
//
//  Created by Kumari Rajan on 17/03/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var playerControllView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var isDraggingStarted = false
    
//    private let videoURL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    private let videoURL = "http://amssamples.streaming.mediaservices.windows.net/634cd01c-6822-4630-8444-8dd6279f94c6/CaminandesLlamaDrama4K.ism/manifest(format=m3u8-aapl)"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.playVideo()
    }
    
    func playVideo() {
        guard let url = URL(string: videoURL) else { return }
        playerView.play(with: url)
        playerView.delegate = self
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if self.playerView.isPlaying {
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.playerView.pause()
        } else {
            self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            self.playerView.play()
        }
    }
    @IBAction func startDragging(_ sender: UISlider) {
        self.isDraggingStarted = true
        
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        self.playerView.seekForward()
    }
    
    @IBAction func backwardAction(_ sender: Any) {
        self.playerView.seekBackward()
    }
    
    @IBAction func volumeAction(_ sender: Any) {
        if self.playerView.player?.isMuted == true{
            self.playerView.player?.isMuted = false
        } else {
            self.playerView.player?.isMuted = true
        }
    }
    
    @IBAction func endDragging(_ sender: UISlider) {
        self.isDraggingStarted = false
        let targetPos = TimeInterval(self.progressBar.progress)
        print("progress: \(targetPos)")
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        
    }
}

extension ViewController: PlayerViewDelegate {
    func onPlaybackStarted() {
        if let totalDuration = self.playerView.player?.currentItem?.duration {
            let seconds = CMTimeGetSeconds(totalDuration)
            let secondsString = String(format: "%02d", Int(Int(seconds) % 60))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.totalDurationLabel.text = "\(minutesString):\(secondsString)"
        }
    }
    
    func onDurationChanged(progressTime: CMTime, currentDuration: CMTime) {
        let seconds = CMTimeGetSeconds(progressTime)
        let secondsString = String(format: "%02d", Int(Int(seconds) % 60))
        let minutesString = String(format: "%02d", Int(seconds / 60))
        self.currentDurationLabel.text = "\(minutesString):\(secondsString)"
        let durationSeconds = CMTimeGetSeconds(currentDuration)
        if !isDraggingStarted {
            self.progressBar.progress = Float(seconds / durationSeconds)
        }
    }
    
    
}

