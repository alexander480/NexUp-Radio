//
//  Array.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation

public extension Array
{
    func random() -> Array
    {
        var buf = self
        var last = buf.count - 1
        
        while(last > 0)
        {
            let rand = Int(arc4random_uniform(UInt32(last)))
            buf.swapAt(last, rand)
            last -= 1
        }
        
        return buf
    }
}
