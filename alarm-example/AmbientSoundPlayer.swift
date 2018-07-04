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
    
    var _audioPlayer: AVQueuePlayer!
    var _observerToken: Any?
    var _minutes: Int
    
    init(minutes: Int) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print(error)
        }
        
        _minutes = minutes
        createPlayer(minutes)
    }
    
    func dispose() {
        _audioPlayer.pause()
        _audioPlayer.seek(to: kCMTimeZero)
        removePlayer()
    }
    
    func pause() {
        _audioPlayer.pause()
    }
    
    func play() {
        _audioPlayer.play()
    }
    
    func createPlayer(_ minutes: Int){
        _audioPlayer = AVQueuePlayer(items: createPlayList(minutes))
        _audioPlayer.actionAtItemEnd = .advance
        _observerToken = _audioPlayer!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self._audioPlayer!.currentItem?.status == .readyToPlay {
                
                let seconds : Int = Int(CMTimeGetSeconds(self._audioPlayer!.currentTime()));
                print("Current audio item - time: \(seconds)")
            }
                
        }
    }
    
    func removePlayer() {
        
        if let ob = _observerToken {
            _audioPlayer.removeTimeObserver(ob)
        }
        _audioPlayer.removeAllItems()
        _audioPlayer = nil
    }
    
    private func createPlayList(_ minutes: Int) -> [AVPlayerItem] {
        var songNames = [String](repeating: "1-minute-silence", count: minutes)
        //songNames.append("singing-bowl-1")
        return songNames.map {
            let url = Bundle.main.url(forResource: $0, withExtension: "mp3")!
            return AVPlayerItem(url: url)
        }
    }
}
