//
//  AlarmClock.swift
//  alarm-example
//
//  Created by Morten Brudvik on 04/07/2018.
//  Copyright © 2018 Morten Brudvik. All rights reserved.
//

import Foundation
import AVFoundation

class AmbientSoundPlayer {
    
    var audioPlayer: AVQueuePlayer!
    var observerToken: Any?
    var minutes: Int
    
    var onPlaying: ((_ playItem: AmbientPlayItem)->())?
    
    init(minutes: Int) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print(error)
        }
        
        self.minutes = minutes
        createPlayer(minutes)
    }
    
    func dispose() {
        if audioPlayer != nil {
            audioPlayer.pause()
            audioPlayer.seek(to: kCMTimeZero)
            removePlayer()
        }
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func createPlayer(_ minutes: Int){
        audioPlayer = AVQueuePlayer(items: createPlayList(minutes))
        audioPlayer.actionAtItemEnd = .advance
        observerToken = audioPlayer!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.audioPlayer!.currentItem?.status == .readyToPlay {
                
                let seconds : Int = Int(CMTimeGetSeconds(self.audioPlayer!.currentTime()));
                let item = AmbientPlayItem(self.audioPlayer!.currentItem!, seconds)
                self.onPlaying?(item)
            }
        }
    }
    
    func removePlayer() {
        
        if let ob = observerToken {
            audioPlayer.removeTimeObserver(ob)
        }
        audioPlayer.removeAllItems()
        audioPlayer = nil
    }
    
    private func createPlayList(_ minutes: Int) -> [AVPlayerItem] {
        let songNames = [String](repeating: "1-minute-silence", count: minutes)
        
        return songNames.map {
            let url = Bundle.main.url(forResource: $0, withExtension: "mp3")!
            return AVPlayerItem(url: url)
        }
    }
}

class AmbientPlayItem {
    init(_ item: AVPlayerItem, _ seconds: Int) {
        playTimeInSeconds = seconds
        let assetURL = item.asset as! AVURLAsset
        name = assetURL.url.lastPathComponent
    }
    let playTimeInSeconds: Int
    let name: String
}
