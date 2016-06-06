//
//  CCTemplateViewController.swift
//  CopyCatSwift
//
//  Created by Roy Xue on 6/5/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCTemplateViewController: UIViewController {

    private var closeButton = UIButton()
    private var templateCol = UICollectionView()
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: {_ in})
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.frame = CGRectMake(self.view.frame.size.width-45, self.view.frame.size.height-45, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: "closeView", forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        
        
    }
}
