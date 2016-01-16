//
//  CCCollectionView.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/15/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCCollectionView: UICollectionView {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let vc = self.delegate as! UIViewController
        vc.touchesBegan(touches, withEvent: event)
    }
    
}
