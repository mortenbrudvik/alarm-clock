//
//  ViewController.swift
//  alarm-example
//
//  Created by Morten Brudvik on 19/06/2018.
//  Copyright © 2018 Morten Brudvik. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var minutes: [Int] = []
    var secondsCountdown = 60
    var totalPlayTimeInSeconds = 0
    
    var observerToken: Any?
    
    var audioPlayer: AVQueuePlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        cancelButton.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.timeLabel.text = "\(self.timeString(seconds: 60))"
        
        minutes.append(contentsOf: (1...60).map{$0})

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print(error)
        }
    }
    
    func createPlayer(){
        audioPlayer = AVQueuePlayer(items: createPlayList())
        audioPlayer.actionAtItemEnd = .advance
        observerToken = audioPlayer!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.audioPlayer!.currentItem?.status == .readyToPlay {
                let seconds : Int = Int(CMTimeGetSeconds(self.audioPlayer!.currentTime()));
                
                let secondsTotal = self.totalPlayTimeInSeconds + seconds
                
                let timeText = "\(self.timeString(seconds: secondsTotal))"
                print(timeText)
                if secondsTotal <= self.secondsCountdown {
                    self.timeLabel.text = "\(self.timeString(seconds: self.secondsCountdown - secondsTotal))"
                    
                    if seconds == 60 {
                        self.totalPlayTimeInSeconds = self.totalPlayTimeInSeconds + 60
                        self.audioPlayer.advanceToNextItem()
                    }
                }
                if secondsTotal > self.secondsCountdown {
                    self.startButton.isHidden = true
                    self.stopButton.isHidden = true
                    self.cancelButton.isHidden = false
                }
            }
        }
    }
    
    func removePlayer() {

        if let ob = self.observerToken {
            audioPlayer.removeTimeObserver(ob)
        }
        audioPlayer.removeAllItems()
    }
    
    private func createPlayList() -> [AVPlayerItem] {
       var songNames = [String](repeating: "1-minute-silence", count: selectedTimeInMinutes())
        songNames.append("singing-bowl-1")
        return songNames.map {
            let url = Bundle.main.url(forResource: $0, withExtension: "mp3")!
            return AVPlayerItem(url: url)
        }
    }

    private func selectedTimeInMinutes() -> Int {
        let index = pickerView.selectedRow(inComponent: 0)
    
        return index + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startAlarm(_ sender: UIButton) {
        startButton.isHidden = true
        startButton.setTitle("Continue", for: .normal)
        stopButton.isHidden = false
        cancelButton.isHidden = true
        
        if !pickerView.isHidden {
            secondsCountdown = 60 * selectedTimeInMinutes()
            createPlayer()
            
            pickerView.isHidden = true
        }
        
        audioPlayer.play()
    }
    
    @IBAction func pauseAlarm(_ sender: UIButton) {
        startButton.isHidden = false
        stopButton.isHidden = true
        cancelButton.isHidden = false
        
        audioPlayer.pause()
    }
    
    @IBAction func cancelAlarm(_ sender: UIButton) {
        totalPlayTimeInSeconds = 0
        startButton.isHidden = false
        startButton.setTitle("Start", for: .normal)
        stopButton.isHidden = true
        cancelButton.isHidden = true
        pickerView.isHidden = false
        timeLabel.text = "\(timeString(minutes: selectedTimeInMinutes()))"
        audioPlayer.pause()
        audioPlayer.seek(to: kCMTimeZero)
        removePlayer()
    }
    
    func timeString(minutes: Int) -> String {
        return timeString(time: TimeInterval(minutes*60))
    }
    
    func timeString(seconds: Int) -> String {
        return timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes =  Int(time) != (60*60) ? Int(time) / 60 % 60 : 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension ViewController :  UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let titleData = "\(row + 1) \(row == 0 ? "minute" : "minutes" )"
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "AvenirNext-Regular", size: 28)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = titleData
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let seconds = minutes[row]*60
        
        timeLabel.text = "\(timeString(time: TimeInterval(seconds)))"
    }
    

    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

