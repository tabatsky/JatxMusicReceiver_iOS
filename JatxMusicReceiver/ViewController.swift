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
    
    @IBAction func switchClick(sender: UISwitch) {
        autoConnect = switchOutlet.on
        saveSettings()
    }
    @IBOutlet weak var switchOutlet: UISwitch!
    
    @IBAction func startStopClick(sender: UIButton) {
        if (!isRunning) {
            startJob(false)
        } else {
            stopJob()
        }
    }
    @IBOutlet weak var startStopOutlet: UIButton!

    @IBAction func buttonExitClick(sender: UIButton) {
        exit(0)
    }
    
    func loadSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        autoConnect = userDefaults.boolForKey("AUTO_CONNECT")
        if let str = userDefaults.stringForKey("IP") {
            host = str
        } else {
            host = "127.0.0.1"
        }
    }
    
    func saveSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(autoConnect!, forKey: "AUTO_CONNECT")
        userDefaults.setValue(host!, forKeyPath: "IP")
    }
    
    func startJob(fromAutoConnectThread: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
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
            self.startStopOutlet.setTitle("Stop", forState: UIControlState.Normal)
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
        dispatch_async(dispatch_get_main_queue()) {
            if (!self.isRunning) {
                return
            }
            self.isRunning = false
            self.rp?.cancel()
            self.rc?.cancel()
            self.startStopOutlet.setTitle("Start", forState: UIControlState.Normal)
            NSLog("stop job");
        }
    }
    
    func isAutoConnect() -> Bool {
        return autoConnect!
    }
    
    func play() {
        dispatch_async(dispatch_get_main_queue()) {
            NSLog("play")
        }
    }
    
    func pause() {
        dispatch_async(dispatch_get_main_queue()) {
            NSLog("pause")
        }
    }
    
    func setVolume(vol: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            NSLog("volume: %d", vol);
        }
    }
}

