//
//  NavigationHeader.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 8/15/17.
//  Copyright © 2017 LAGB Technologies. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    var title: UILabel!
    var subtitle: UILabel!
    var dropDownIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
}
