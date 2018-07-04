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
    var timer = Timer()
    
    var isTimerRunning = false
    var isPaused = false
    
    var _player: AmbientSoundPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
        cancelButton.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.timeLabel.text = "\(self.timeString(seconds: 60))"
        
        minutes.append(contentsOf: (1...60).map{$0})
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            playSound()
            startButton.isHidden = true
            stopButton.isHidden = true
            cancelButton.isHidden = false
            cancelButton.setTitle("Reset", for: .normal)
        } else {
            seconds -= 1
            
            self.timeLabel.text = "\(self.timeString(seconds: seconds))"
        }
        print(seconds)
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
        stopButton.isHidden = false
        cancelButton.isHidden = true
        
        if isTimerRunning == false {
            runTimer()
            seconds = 60 * selectedTimeInMinutes()
            
            pickerView.isHidden = true
            _player = AmbientSoundPlayer(minutes: selectedTimeInMinutes())
            _player.play()
        }
        
    }
    
    @IBAction func pauseAlarm(_ sender: UIButton) {
        if !isPaused {
            cancelButton.isHidden = false
            isPaused =  true
            stopButton.setTitle("Continue", for: .normal)
            timer.invalidate()
            isTimerRunning = false
            _player.pause()
        } else {
            cancelButton.isHidden = true
            isPaused =  false
            stopButton.setTitle("Pause", for: .normal)
            runTimer()
            isTimerRunning = true
            _player.play()
        }
    }
    
    @IBAction func cancelAlarm(_ sender: UIButton) {
        startButton.isHidden = false
        stopButton.setTitle("Pause", for: .normal)
        stopButton.isHidden = true
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        pickerView.isHidden = false
        timeLabel.text = "\(timeString(minutes: selectedTimeInMinutes()))"
        _player.dispose()
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
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "singing-bowl-1", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
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
