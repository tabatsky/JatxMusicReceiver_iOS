//
//  Frame.swift
//  JatxMusicReceiver
//
//  Created by Admin on 26.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

class Frame {
    var size: Int?
    var freq: Int?
    var channels: Int?
    var position: Int?
    var data: [UInt8]?
}

let FRAME_HEADER_SIZE = 64
let FRAME_RATES = [32000, 44100, 48000]

func frameFromInputStream(inputStream: InputStream) -> Frame? {
    var freq1 = 0
    var freq2 = 0
    var freq3 = 0
    var freq4 = 0
    
    var size1 = 0
    var size2 = 0
    var size3 = 0
    var size4 = 0
    
    var pos1 = 0
    var pos2 = 0
    var pos3 = 0
    var pos4 = 0
    
    var channels = 0
    
    var header = [UInt8](repeating: 0, count: 1)
    
    var bytesRead = 0
    
    while (bytesRead < FRAME_HEADER_SIZE) {
        if (inputStream.hasBytesAvailable) {
            let justRead = inputStream.read(UnsafeMutablePointer(mutating: header), maxLength: 1)
            
            if (justRead < 0) {
                return nil
            }
            
            if (justRead > 0) {
                if (bytesRead==0) {
                    size1 = Int(header[0] & 0xff)
                } else if (bytesRead==1) {
                    size2 = Int(header[0] & 0xff)
                } else if (bytesRead==2) {
                    size3 = Int(header[0] & 0xff)
                } else if (bytesRead==3) {
                    size4 = Int(header[0] & 0xff)
                } else if (bytesRead==4) {
                    freq1 = Int(header[0] & 0xff)
                } else if (bytesRead==5) {
                    freq2 = Int(header[0] & 0xff)
                } else if (bytesRead==6) {
                    freq3 = Int(header[0] & 0xff)
                } else if (bytesRead==7) {
                    freq4 = Int(header[0] & 0xff)
                } else if (bytesRead==8) {
                    channels = Int(header[0] & 0xff)
                } else if (bytesRead==12) {
                    pos1 = Int(header[0] & 0xff)
                } else if (bytesRead==13) {
                    pos2 = Int(header[0]&0xff)
                } else if (bytesRead==14) {
                    pos3 = Int(header[0] & 0xff)
                } else if (bytesRead==15) {
                    pos4 = Int(header[0] & 0xff)
                }
                
                bytesRead += justRead
            }
        } else {
            Thread.sleep(forTimeInterval: 0.02)
        }
    }
    
    let size = (size1<<24) | (size2<<16) | (size3<<8) | size4;
    let freq = (freq1<<24) | (freq2<<16) | (freq3<<8) | freq4;
    let pos = (pos1<<24) | (pos2<<16) | (pos3<<8) | pos4
    
    bytesRead = 0;
    
    let data = [UInt8](repeating: 0, count: size)
    
    while (bytesRead < size) {
        if (inputStream.hasBytesAvailable) {
            let justRead = inputStream.read(UnsafeMutablePointer(mutating: data) + bytesRead, maxLength: size - bytesRead)
            //int justRead = is.read(data, bytesRead, size-bytesRead);
            
            if (justRead < 0) {
                return nil
            }
            
            if (justRead > 0) {
                bytesRead += justRead;
            }
        } else {
            Thread.sleep(forTimeInterval: 0.02)
        }
    }
    
    let f = Frame()
    
    f.size = size
    f.freq = freq
    f.channels = channels
    f.position = pos
    f.data = data
    
    //NSLog("frame received: %d, %d, %d, %d", f.size!, f.freq!, f.channels!, f.position!)
    
    return f
}
