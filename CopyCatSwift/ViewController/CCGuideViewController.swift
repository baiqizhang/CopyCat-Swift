//
//  CCGuideViewController.swift
//  CopyCatSwift
//
//  Created by Roy Xue on 4/26/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

//
//  AnnotationViewController.swift
//  Gecco
//
//  Created by yukiasai on 2016/01/19.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//
import UIKit
import Gecco

class CCGuideViewController: SpotlightViewController {
    
    var guideLabelViews: [UIView]! = []
    
    var stepIndex: Int = 0
    
    let screenSize = UIScreen.mainScreen().bounds.size
    var offset : CGFloat = 0.0
   
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if screenSize.height == 568 {
            offset = 0.0
        } else {
            offset = 75.0
        }
        
//        let cameraLabel: UILabel = UILabel(frame: CGRectMake(105, 400 - offset, 80, 15))
//        cameraLabel.textAlignment = .Left
//        cameraLabel.text = NSLocalizedString("Open Camera", comment: "Open Camera")
//        cameraLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
//        cameraLabel.alpha = 0
//        self.view!.addSubview(cameraLabel)
        
//        let imageLabel: UILabel = UILabel(frame: CGRectMake(screenSize.width - 115 + 25, 400 - offset, 80, 15))
//        imageLabel.textAlignment = .Left
//        imageLabel.text = NSLocalizedString("Open Inspiration", comment: "Open Inspiration")
//        imageLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
//        imageLabel.alpha = 0
//        self.view!.addSubview(imageLabel)
        
//        guideLabelViews.append(cameraLabel)
//        guideLabelViews.append(imageLabel)
        
    }
    
    func next(labelAnimated: Bool) {
        updateAnnotationView(labelAnimated)
        
        // Category 80, 340.0 - offset, 50
        // Inspire self.view.frame.size.width - 115, 340 - offset, 50, 50
        // Instagram self.view.frame.size.width - 115, 340 - offset - 60, 50, 50
        
        switch stepIndex {
        case 0:
            spotlightView.appear(Spotlight.Oval(center: CGPointMake(105, 365.0 - offset), diameter: 60))
        case 1:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width - 115 + 25, 365-offset), diameter: 60))
        case 2:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(20, 20), diameter: 40))
        case 3:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width / 2 + 10, 200), diameter: 220), moveType: .Disappear)
        case 4:
            dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
        
        stepIndex += 1
    }
    
    func updateAnnotationView(animated: Bool) {
        guideLabelViews.enumerate().forEach { index, view in
            UIView .animateWithDuration(animated ? 0.25 : 0) {
                view.alpha = index == self.stepIndex ? 1 : 0
            }
        }
    }
}

extension CCGuideViewController: SpotlightViewControllerDelegate {
    func spotlightViewControllerWillPresent(viewController: SpotlightViewController, animated: Bool) {
        next(false)
    }
    
    func spotlightViewControllerTapped(viewController: SpotlightViewController, isInsideSpotlight: Bool) {
        next(true)
    }
    
    func spotlightViewControllerWillDismiss(viewController: SpotlightViewController, animated: Bool) {
        spotlightView.disappear()
    }
}
