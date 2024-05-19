//
//  AutoConnectThread.swift
//  JatxMusicReceiver
//
//  Created by Admin on 25.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

class AutoConnectThread: Thread {
    weak var ui: UI?
    
    var isInterrupted = false
    
    init(ui: UI) {
        self.ui = ui
    }
    
    func interrupt() {
        isInterrupted = true
    }
    
    override func main() {
        while (!isInterrupted) {
            if (ui != nil && ui!.isAutoConnect()) {
                ui!.startJob(fromAutoConnectThread: true)
            }
            
            Thread.sleep(forTimeInterval: 5.0)
        }
    }
}
