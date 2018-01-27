//
//  String.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

public extension String
{
    func toURL() -> URL?
    {
        if let url = URL(string: self) { return url }
        else { return nil }
    }
    
    func toImage() -> UIImage?
    {
        if let url = URL(string: self)
        {
            if let image = url.toImage()
            {
                return image
            }
            else
            {
                print("[ERROR: String Extension] \(self) Is Not A Valid Image URL")
                return nil
            }
        }
        else
        {
            print("[ERROR: String Extension] \(self) Is Not A Valid URL")
            return nil
        }
    }
}
