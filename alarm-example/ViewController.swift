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
    var seconds = 60
    var timer: Timer! = nil
    
    var isTimerRunning = false
    var isPaused = false
    
    var ambientPlayer: AmbientSoundPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        cancelButton.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.timeLabel.text = "\(self.timeString(minutes: selectedTimeInMinutes()))"
        
        minutes.append(contentsOf: (1...60).map{$0})
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            triggerAlarm()
        } else {
            seconds -= 1
            
            self.timeLabel.text = "\(self.timeString(seconds: seconds))"
        }
        print(seconds)
    }
    
    func stopTimer() {
        isTimerRunning = false
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }

    private func selectedTimeInMinutes() -> Int {
        let index = pickerView.selectedRow(inComponent: 0)
    
        return index + 1
    }

    @IBAction func startAlarm(_ sender: UIButton) {
        startCountdown()
    }
    
    @IBAction func pauseAlarm(_ sender: UIButton) {
        if isPaused {
            unPause()
        } else {
            pause()
        }
    }
    
    @IBAction func cancelAlarm(_ sender: UIButton) {
        reset()
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
    
    var player: AVAudioPlayer?

    func playAlarm() {
        guard let url = Bundle.main.url(forResource: "alarm-clock", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController : CountDownClock {
    func startCountdown() {
        startButton.isHidden = true
        stopButton.isHidden = false
        cancelButton.isHidden = true
        pickerView.isHidden = true

        runTimer()
        seconds = 60 * selectedTimeInMinutes()
        
        ambientPlayer = AmbientSoundPlayer(minutes: selectedTimeInMinutes())
        ambientPlayer.play()
    }
    
    func reset() {
        startButton.isHidden = false
        stopButton.setTitle("Pause", for: .normal)
        stopButton.isHidden = true
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        pickerView.isHidden = false
        timeLabel.text = "\(timeString(minutes: selectedTimeInMinutes()))"
        ambientPlayer.dispose()
        stopTimer()
        isPaused = false
    }
    
    func triggerAlarm() {
        startButton.isHidden = true
        stopButton.isHidden = true
        cancelButton.isHidden = false
        cancelButton.setTitle("Reset", for: .normal)
        isPaused = false
        stopTimer()
        ambientPlayer.dispose()
        playAlarm()
    }
    
    func pause() {
        cancelButton.isHidden = false
        stopButton.setTitle("Continue", for: .normal)
        isPaused =  true
        stopTimer()
        ambientPlayer.pause()
    }
    
    func unPause() {
        cancelButton.isHidden = true
        stopButton.setTitle("Pause", for: .normal)
        isPaused =  false
        runTimer()
        ambientPlayer.play()
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

protocol CountDownClock {
    func pause()
    func unPause()
    func triggerAlarm()
    func startCountdown()
    func reset()
}
