//
//  AVPlayerItem.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import AVFoundation

public extension AVPlayerItem
{
    func url() -> URL? {
        if let urlAsset = self.asset as? AVURLAsset {
            return urlAsset.url
        }
        else {
            return nil
        }
    }
}
