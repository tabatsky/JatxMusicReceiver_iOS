//
//  ViewController.swift
//  JatxMusicReceiver
//
//  Created by Admin on 24.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UI {
    
    var autoConnect: Bool?
    var host: String?
    
    var rp: ReceiverPlayer?
    var rc: ReceiverController?
    var act: AutoConnectThread?
    
    var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        
        switchOutlet.setOn(autoConnect!, animated: false)
        hostTextOutlet.text = host!
        
        act = AutoConnectThread(ui: self)
        act?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var hostTextOutlet: UITextField!
    
    @IBAction func switchClick(_ sender: UISwitch) {
        autoConnect = switchOutlet.isOn
        saveSettings()
    }
    @IBOutlet weak var switchOutlet: UISwitch!
    
    @IBAction func startStopClick(_ sender: UIButton) {
        if (!isRunning) {
            startJob(fromAutoConnectThread: false)
        } else {
            stopJob()
        }
    }
    @IBOutlet weak var startStopOutlet: UIButton!

    @IBAction func buttonExitClick(_ sender: UIButton) {
        exit(0)
    }
    
    func loadSettings() {
        let userDefaults = UserDefaults.standard
        autoConnect = userDefaults.bool(forKey: "AUTO_CONNECT")
        if let str = userDefaults.string(forKey: "IP") {
            host = str
        } else {
            host = "127.0.0.1"
        }
    }
    
    func saveSettings() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(autoConnect!, forKey: "AUTO_CONNECT")
        userDefaults.setValue(host!, forKeyPath: "IP")
    }
    
    func startJob(fromAutoConnectThread: Bool) {
        DispatchQueue.main.async {
            //NSLog("1")
            if (fromAutoConnectThread && !self.isAutoConnect()) {
                return
            }
            
            //NSLog("2")
            if (self.isRunning) {
                return
            }
            self.isRunning = true
            NSLog("start job")
            self.startStopOutlet.setTitle("Stop", for: UIControl.State.normal)
            self.host = self.hostTextOutlet.text
            //NSLog("3")
            self.saveSettings()
            //NSLog("4")
            self.rp = ReceiverPlayer(hostname: self.host!, ui: self, soundOut: IOSSoundOut())
            //NSLog("5")
            self.rc = ReceiverController(hostname: self.host!, ui: self)
            //NSLog("6")
            self.rp?.start()
            //NSLog("7")
            self.rc?.start()
            //NSLog("8")
        }
    }
    
    func stopJob() {
        DispatchQueue.main.async {
            if (!self.isRunning) {
                return
            }
            self.isRunning = false
            self.rp?.cancel()
            self.rc?.cancel()
            self.startStopOutlet.setTitle("Start", for: UIControl.State.normal)
            NSLog("stop job");
        }
    }
    
    func isAutoConnect() -> Bool {
        return autoConnect!
    }
    
    func play() {
        DispatchQueue.main.async {
            NSLog("play")
            self.rp?.play()
        }
    }
    
    func pause() {
        DispatchQueue.main.async {
            NSLog("pause")
            self.rp?.pause()
        }
    }
    
    func setVolume(vol: Int) {
        DispatchQueue.main.async {
            NSLog("volume: %d", vol);
            self.rp?.setVolume(vol: vol)
        }
    }
}

