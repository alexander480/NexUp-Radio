//
//  AVQueuePlayer.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import AVFoundation

public extension AVQueuePlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
