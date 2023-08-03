//
//  ReceiverController.swift
//  JatxMusicReceiver
//
//  Created by Admin on 25.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

class ReceiverController: Thread, StreamDelegate {
    let CONNECT_PORT_CONTROLLER = 7172
    
    let SOCKET_TIMEOUT = 1500
    
    let COMMAND_EMPTY = UInt8(255)
    let COMMAND_STOP = UInt8(127)
    let COMMAND_PAUSE = UInt8(126)
    let COMMAND_PLAY = UInt8(125)
    
    weak var ui: UI? // volatile
    
    var host: String?
    
    var inputStream : InputStream?
    var outputStream : OutputStream?
    
    init(hostname: String, ui: UI) {
        host = hostname;
        self.ui = ui
    }
    
    func play() {
        NSLog("(controller) " + "play command received");
        
        if (ui != nil) {
            ui!.play()
        }
    }
    
    func pause() {
        NSLog("(controller) " + "pause command received");
        
        if (ui != nil) {
            ui!.pause()
        }
    }
    
    func setVolume(vol: Int) {
        NSLog("(controller) " + "volume command received");
        NSLog("(controller) " + "volume: %d", vol);
        
        if (ui != nil) {
            ui!.setVolume(vol: vol)
        }
    }
    
    override func main() {
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?
        let host : CFString = NSString(string: self.host!)
        let port : UInt32 = UInt32(CONNECT_PORT_CONTROLLER)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream!.delegate = self
        //outputStream!.delegate = self
        
        inputStream!.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        //outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream!.open()
        //outputStream!.open()
        
        var numBytesRead : Int
        var data = [UInt8](repeating: 0, count: 1)
        
        var cmdSkipped = 0;
        
        while (!self.isCancelled) {
            if (inputStream!.hasBytesAvailable) {
                cmdSkipped = 0;
                
                numBytesRead = inputStream!.read(UnsafeMutablePointer(mutating: data), maxLength: 1)
                
                if (numBytesRead < 0) {
                    NSLog("controller frame broken")
                    break
                }
                
                if (numBytesRead==1) {
                    let cmd = data[0]
                    
                    if (cmd>=0&&cmd<=100) {
                        setVolume(vol: Int(cmd));
                    } else if (cmd==COMMAND_PLAY) {
                        play();
                    } else if (cmd==COMMAND_PAUSE) {
                        pause();
                    } else if (cmd==COMMAND_STOP) {
                        NSLog("(controller) " + "stop command received");
                        
                        if (ui != nil) {
                            ui!.stopJob();
                        }
                    } else if (cmd==COMMAND_EMPTY) {
                        //System.out.println("(controller) " + "empty command received");
                    }
                }
            } else {
                Thread.sleep(forTimeInterval: 0.05)
                cmdSkipped += 1
                if (cmdSkipped > 7) {
                    self.cancel()
                }
            }
        }
        
        CFReadStreamSetProperty(inputStream, CFStreamPropertyKey( kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanTrue)
        
        inputStream?.close()
        //outputStream?.close()
        
        inputStream?.delegate = nil
        //outputStream?.delegate = nil
        
        NSLog("stop job from controller")
        ui?.stopJob()
    }
}
