//
//  SoundOut.swift
//  JatxMusicReceiver
//
//  Created by Admin on 26.09.17.
//  Copyright © 2017 jatx. All rights reserved.
//

import Foundation

protocol SoundOut: AnyObject {
    func renew(frameRate: Int, channels: Int)
    func setVolume(volume: Int)
    func write(frame: Frame)
    func destroy()
    func play()
    func pause()
}
