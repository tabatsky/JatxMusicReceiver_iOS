//
//  SoundOutput.swift
//  JatxMusicReceiver
//
//  Created by Admin on 10/07/2019.
//  Copyright © 2019 jarz. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundOutput: Thread {
    public static var volume: Int = 100
    private var queueRef: AudioQueueRef?
    private var asbd: AudioStreamBasicDescription
    private var bufferList = [AudioQueueBufferRef]()
    private let dispatchQueue = DispatchQueue(label: "ArrayQueue")
    private var finishFlag: Bool = false
    private var isPaused: Bool = true
    
    init(freq: Int, channels: Int) {
        asbd = AudioStreamBasicDescription()
        
        asbd.mSampleRate       = Float64(freq)
        asbd.mFormatID         = kAudioFormatLinearPCM
        asbd.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        asbd.mBitsPerChannel   = 8 * 2
        asbd.mChannelsPerFrame = UInt32(channels)
        asbd.mBytesPerFrame    = UInt32(2 * asbd.mChannelsPerFrame)
        asbd.mFramesPerPacket  = 1
        asbd.mBytesPerPacket   = asbd.mBytesPerFrame * asbd.mFramesPerPacket
        asbd.mReserved         = 0
    
        AudioQueueNewOutput(&asbd, callback(pointer:queueRef:bufferRef:), nil, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue, 0, &queueRef)
    }
    
    func setFinishFlag() {
        finishFlag = true
    }
    
    func startOutput() {
        if (queueRef != nil) {
            AudioQueueStart(queueRef!, nil)
            //NSLog("start: queueRef is not nil")
        } else {
            NSLog("start: queueRef is nil")
        }
    }
    
    func pauseOutput() {
        if (queueRef != nil) {
            AudioQueuePause(queueRef!)
        } else {
            NSLog("pause: queueRef is nil")
        }
    }
    
    func stopOutput() {
        if (queueRef != nil) {
            AudioQueueStop(queueRef!, true)
            self.finishFlag = true
        } else {
            NSLog("stop: queueRef is nil")
        }
    }
    
    func setVolume(_ vol: Int) {
        AudioQueueSetParameter(queueRef!, kAudioQueueParam_Volume, Float(0.01) * Float(vol))
    }
    
    func putFrame(f: Frame) {
        var bufferRef: AudioQueueBufferRef?
        if (queueRef != nil) {
            let statusAllocate = AudioQueueAllocateBuffer(queueRef!, UInt32(f.size), &bufferRef)
            //NSLog("allocate status: " + statusAllocate.description)
            if (bufferRef != nil) {
                bufferRef!.pointee.mAudioDataByteSize = UInt32(f.size)
                let audioData = bufferRef!.pointee.mAudioData
                
                audioData.copyMemory(from: f.data!, byteCount: f.size)
                //dispatchQueue.async() {
                    self.bufferList.append(bufferRef!)
                //}
            } else {
                NSLog("playFrame: bufferRef is nil")
            }
        } else {
            NSLog("playFrame: queueRef is nil")
        }
    }
    
    override func main() {
        setVolume(SoundOutput.volume)
        while (!finishFlag) {
            //NSLog("AudioOutput main cycle body")
            var bufferRef: AudioQueueBufferRef? = nil
            
            //dispatchQueue.sync() {
                if (bufferList.isEmpty) {
                    Thread.sleep(forTimeInterval: 0.2)
                    if (bufferList.isEmpty) {
                        pauseOutput()
                    } else {
                        bufferRef = bufferList.removeFirst()
                    }
                } else {
                    bufferRef = bufferList.removeFirst()
                    startOutput()
                }
            //}
            
            if (bufferRef != nil) {
                let statusEnqueue = AudioQueueEnqueueBuffer(queueRef!, bufferRef!, 0, nil)
                //NSLog("enqueue status: " + statusEnqueue.description)
                //NSLog("buffer enqueued")
                let statusFree = AudioQueueFreeBuffer(queueRef!, bufferRef!)
                //NSLog("free status: " + statusFree.description)
            } else {
                //NSLog("main: bufferRef is nil")
            }
        }
    }
}

func callback(pointer: UnsafeMutableRawPointer?, queueRef: AudioQueueRef, bufferRef: AudioQueueBufferRef) {}
