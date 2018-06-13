//
//  Array.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

public extension Array {
    func random() -> Array {
        var buf = self
        var last = buf.count - 1
        
        while(last > 0) {
            let rand = Int(arc4random_uniform(UInt32(last)))
            buf.swapAt(last, rand)
            last -= 1
        }
        
        return buf
    }
}

public extension String {
    func toURL() -> URL? {
        if let url = URL(string: self) { return url }
        else { return nil }
    }
    
    func toImage() -> UIImage? {
        if let url = URL(string: self) {
            if let image = url.toImage() { return image }
            else { print("[ERROR: String Extension] \(self) Is Not A Valid Image URL"); return nil }
        }
        else { print("[ERROR: String Extension] \(self) Is Not A Valid URL"); return nil }
    }
}

public extension Int {
    var minutes: Int {
        let raw = Int(self / 60)
        
        return raw
    }
    
    var seconds: Int {
        let raw = Int(self / 60)
        
        return raw
    }
    
    var minutesString: String {
        let raw = self / 60
        let string = String(raw)
        
        return string
    }
    
    var secondsString: String {
        let raw = Int(self % 60)
        if raw < 10 {
            let string = "0\(raw)"
            
            return string
        }
        else {
            let string = "\(raw)"
            
            return string
        }
    }
    
    var stringTime: String {
        return self.minutesString + ":" + self.secondsString
    }
}


public extension URL {
    func toImage() -> UIImage? {
        var image: UIImage?
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: self) {
                DispatchQueue.main.async {
                        image = UIImage(data: data)
                }
            }
        }
        
        return image
    }
    
    func toImageSync() -> UIImage? {
        var image: UIImage?
        if let data = try? Data(contentsOf: self) {
            image = UIImage(data: data)
        }
        
        return image
    }
}
