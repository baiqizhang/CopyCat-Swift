//
//  CCCameraGuideViewController.swift
//  CopyCatSwift
//
//  Created by Roy Xue on 5/15/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit
import Gecco

class CCCameraGuideViewController: SpotlightViewController {
    
    var guideLabelViews: [UIView]! = []
    
    var stepIndex: Int = 0
    
    let screenSize = UIScreen.mainScreen().bounds.size
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
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
        
        switch stepIndex {
        case 0:
            spotlightView.appear(Spotlight.Oval(center: CGPointMake(screenSize.width/2.0 + 4 , screenSize.height - 46), diameter: 80))
        case 1:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(52.5, screenSize.height - 45), diameter: 60))
        case 2:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width - 56, screenSize.height - 43), diameter: 54))
        case 3:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width - 82, 20), diameter: 37), moveType: .Disappear)
        case 4:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(screenSize.width - 32,  20), diameter: 37))
        case 5:
            spotlightView.move(Spotlight.Oval(center: CGPointMake(25, 20), diameter: 37))
        case 6:
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

extension CCCameraGuideViewController: SpotlightViewControllerDelegate {
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
