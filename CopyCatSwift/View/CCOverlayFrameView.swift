//
//  CCOverlayFrameView.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/16/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCOverlayFrameView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor(red: 65.0/255, green: 175.0/255, blue: 1, alpha: 1).CGColor)
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let len: CGFloat = 2.5
        CGContextFillRect(context, CGRectMake(x, y, len, height))
        CGContextFillRect(context, CGRectMake(x, y, width, len))
        CGContextFillRect(context, CGRectMake(x+width-len, y, len, height))
        CGContextFillRect(context, CGRectMake(x,y+height-len, width, len))
    }
    
}
