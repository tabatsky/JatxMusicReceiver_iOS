//
//  UI.swift
//  JatxMusicReceiver
//
//  Created by Admin on 24.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

protocol UI: AnyObject {
    func startJob(fromAutoConnectThread: Bool);
    func stopJob();
    
    func isAutoConnect() -> Bool;
    
    func play();
    func pause();
    
    func setVolume(vol: Int);
}
