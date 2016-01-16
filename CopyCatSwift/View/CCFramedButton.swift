//
//  CCFramedButton.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/15/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCFramedButton: UIButton {
    override func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle(title, forState: state)
        self.setTitleColor(UIColor(red: 65.0/255.0, green: 175.0/255.0, blue: 1, alpha: 1), forState: .Highlighted)
    }
    
    override func drawRect(rect: CGRect) {
        let layer = self.layer
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(white: 0.5, alpha: 1).CGColor
    }
}
