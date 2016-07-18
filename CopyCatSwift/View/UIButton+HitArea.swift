//
//  UIButton+HitArea.swift
//  
//
//  Created by Baiqi Zhang on 7/17/16.
//
//

import Foundation

private let minimumHitArea = CGSizeMake(44, 44)

extension UIButton {
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.hidden || !self.userInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = CGRectInset(self.bounds, -widthToAdd / 2, -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (CGRectContainsPoint(largerFrame, point)) ? self : nil
    }
}