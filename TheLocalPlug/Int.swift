//
//  Int.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation

public extension Int
{
    var minutes : Int
    {
        let raw = Int(self/60)
        return raw
    }
    
    var seconds : Int
    {
        let raw = Int(self/60)
        return raw
    }
    
    var minutesString: String
    {
        let raw = self/60
        let string = String(raw)
        
        return string
    }
    
    var secondsString: String
    {
        let raw = Int(self % 60)
        
        if raw < 10
        {
            let string = "0\(raw)"
            return string
        }
        else
        {
            let string = "\(raw)"
            return string
        }
    }
    
    var stringTime: String { return self.minutesString + ":" + self.secondsString }
}
