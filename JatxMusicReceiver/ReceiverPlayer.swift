//
//  ReceiverPlayer.swift
//  JatxMusicReceiver
//
//  Created by Admin on 26.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

class ReceiverPlayer: NSThread, NSStreamDelegate {
    let CONNECT_PORT_PLAYER = 7171
    
    let FRAME_HEADER_SIZE = 32
    
    let SOCKET_TIMEOUT = 1500
    
    weak var ui: UI? // volatile
    
    //var isPlaying: Bool? // volatile
    var soundOut: SoundOut? // volatile
    
    //var volume: Int? // volatile
    
    var host: String?
    
    var inputStream : NSInputStream?
    var outputStream : NSOutputStream?
    
    init(hostname: String, ui: UI, soundOut: SoundOut) {
        self.ui = ui
        
        //isPlaying = false
        self.soundOut = soundOut
        
        host = hostname
        
        //volume = 100
    }
    
    func play() {
        if (!(threadDictionary["isPlaying"] as! Bool)) {
            soundOut!.play()
            threadDictionary["isPlaying"] = true
        }
    }
    
    func pause() {
        if ((threadDictionary["isPlaying"] as! Bool)) {
            soundOut!.pause()
            threadDictionary["isPlaying"] = false
        }
    }
    
    func setVolume(vol: Int) {
        threadDictionary["volume"] = vol
        
        soundOut!.setVolume(vol)
    }
    
    override func main() {
        threadDictionary["volume"] = 100
        threadDictionary["isPlaying"] = false
        
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        let host : CFString = NSString(string: self.host!)
        let port : UInt32 = UInt32(CONNECT_PORT_PLAYER)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        //outputStream!.delegate = self
        
        inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        //outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream!.open()
        //outputStream!.open()
        
        //NSLog("a")
        
        var frameRate = 44100
        var channels = 2
        var position = 0
        //NSLog("b")
        restartPlayer(frameRate, channels: channels)
        
        while (!self.cancelled) {
            if ((threadDictionary["isPlaying"] as! Bool)) {
                let f = frameFromInputStream(inputStream!)
                
                if (f == nil) {
                    NSLog("nil frame, player thread broken")
                    break
                }
                
                if (frameRate != f!.freq || channels != f!.channels || position != f!.position) {
                    frameRate = f!.freq!
                    channels = f!.channels!
                    position = f!.position!
                    restartPlayer(frameRate, channels: channels);
                }
                
                soundOut!.write(f!.data!, offset: 0, size: f!.size!);
            }
        }
        
        CFReadStreamSetProperty(inputStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
        
        inputStream?.close()
        //outputStream?.close()
        
        inputStream?.delegate = nil
        //outputStream?.delegate = nil
        
        NSLog("stop job from player")
        ui?.stopJob()
    }
    
    func restartPlayer(frameRate: Int, channels: Int) {
        //NSLog("c")
        soundOut!.renew(frameRate, channels: channels);
        
        //NSLog("d")
        soundOut!.setVolume((threadDictionary["volume"] as! Int));
        
        //NSLog("e")
        NSLog("(player) " + "player restarted");
        NSLog("(player) " + "frame rate: %d", frameRate);
        NSLog("(player) " + "channels: %d", channels);
    }
}
