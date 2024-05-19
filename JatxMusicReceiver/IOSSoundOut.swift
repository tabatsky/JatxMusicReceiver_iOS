//
//  IOSSoundOut.swift
//  JatxMusicReceiver
//
//  Created by Admin on 26.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

class IOSSoundOut: SoundOut {
    private var soundOutput: SoundOutput?
    
    func renew(frameRate: Int, channels: Int) {
        soundOutput?.stopOutput()
        soundOutput = SoundOutput(freq: frameRate, channels: channels)
        soundOutput?.start()
    }
    
    func setVolume(volume: Int) {
        SoundOutput.volume = volume
        soundOutput?.setVolume(volume)
    }
    
    func write(frame: Frame) {
        soundOutput?.putFrame(f: frame)
    }
    
    func destroy() {
        soundOutput?.stopOutput()
        soundOutput = nil
    }
    
    func play() {
        soundOutput?.startOutput()
    }
    
    func pause() {
        soundOutput?.pauseOutput()
    }
}
