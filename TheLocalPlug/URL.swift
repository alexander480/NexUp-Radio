//
//  URL.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/22/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

public extension URL
{
    func toImage() -> UIImage?
    {
        var image: UIImage?
        
        DispatchQueue.global().async
            {
                if let data = try? Data(contentsOf: self)
                {
                    DispatchQueue.main.async
                        {
                            image = UIImage(data: data)
                    }
                }
        }
        
        return image
    }
    
    func toImageSync() -> UIImage?
    {
        var image: UIImage?
        
        if let data = try? Data(contentsOf: self)
        {
            image = UIImage(data: data)
        }
        
        return image
    }
}
