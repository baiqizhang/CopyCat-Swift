//
//  CCLabel.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/17/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCLabel: UILabel {
    var scaleFactor: Float?
    var wordSpacing: Float?
    var withShadow: Bool?
    
    override func drawRect(rect: CGRect){
        let context = UIGraphicsGetCurrentContext()
        
        // Prepare font
        let ctFont = CTFontCreateWithName( self.font.fontName, self.font.pointSize, nil)
        var ctColor = UIColor.clearColor().CGColor
        let number: [CGFloat] = [0.5]
        let num = CFNumberCreate(kCFAllocatorDefault, .CGFloatType, number)
        let ctStr = CFStringCreateWithCString(nil, self.text!, CFStringBuiltInEncodings.UTF8.rawValue)

        // Create an attributed string
        var attr = [kCTFontAttributeName : ctFont, kCTForegroundColorAttributeName: ctColor, kCTKernAttributeName: num] as [NSString : AnyObject]
        var attrString = CFAttributedStringCreate(nil, ctStr, attr)
        var line = CTLineCreateWithAttributedString(attrString)
        
        CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 0.8, -1.0))
        
        let p = CGContextGetTextPosition(context)
        let centeredY = (self.font.pointSize + (self.frame.size.height - self.font.pointSize) / 2) - 2
        
        CGContextSetTextPosition(context, 0, centeredY)
        CTLineDraw(line, context!)

        // calculate width and draw shadow.
        let v = CGContextGetTextPosition(context)
        let width = v.x - p.x
        let centeredX = (self.frame.size.width - width) / 2
        
        ctColor = UIColor(white: 0.4, alpha: 1).CGColor
        attr = [kCTFontAttributeName : ctFont, kCTForegroundColorAttributeName: ctColor, kCTKernAttributeName: num] as [NSString : AnyObject]
        attrString = CFAttributedStringCreate(nil, ctStr, attr)
        line = CTLineCreateWithAttributedString(attrString)
        CGContextSetTextPosition(context, centeredX+1.5, centeredY+1.5)
        CTLineDraw(line, context!)
        
        // Draw Real Text
        ctColor = UIColor.whiteColor().CGColor
        attr = [kCTFontAttributeName : ctFont, kCTForegroundColorAttributeName: ctColor, kCTKernAttributeName: num] as [NSString : AnyObject]
        attrString = CFAttributedStringCreate(nil, ctStr, attr)
        line = CTLineCreateWithAttributedString(attrString)
        CGContextSetTextPosition(context, centeredX, centeredY)
        CTLineDraw(line, context!)

    }
}
