//
//  CCSpotLightViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 8/24/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit
import Gecco

class CCSpotLightViewController: SpotlightViewController {
    var stepIndex: Int = 1
    var parent: AVCamViewController?
    var hint1: UILabel?
    var hint2: UILabel?
    var hint3: UILabel?

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.frame.width
        let height = self.view.frame.height
        delegate = self
        
        hint1 = UILabel(frame: CGRectMake(245.0/320*width-75, height - 275/568.0 * height, 200, 200))
        //        let titleText = category?.name
        hint1!.text = NSLocalizedString("Tab to compare the photo", comment: "")//NSLocalizedString((titleText?.uppercaseString)!, comment: (titleText)!)
        hint1!.font = UIFont.systemFontOfSize(20)//UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
        hint1!.textColor = .whiteColor()
        hint1!.textAlignment = .Center
        hint1?.backgroundColor = .clearColor()
        hint1?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        self.view.addSubview(hint1!)
        
        hint2 = UILabel(frame: CGRectMake(170.0/320*width - 75, height - 275/568.0 * height, 200, 200))
        //        let titleText = category?.name
        hint2!.text = NSLocalizedString("Tab to share the photo", comment: "")//NSLocalizedString((titleText?.uppercaseString)!, comment: (titleText)!)
        hint2!.font = UIFont.systemFontOfSize(20)//UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
        hint2!.textColor = .whiteColor()
        hint2?.backgroundColor = .clearColor()
        hint2?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        hint2!.textAlignment = .Center
        
        hint3 = UILabel(frame: CGRectMake(92.0/320*width - 75, height - 275/568.0 * height, 200, 200))
        //        let titleText = category?.name
        hint3!.text = NSLocalizedString("Tab to save the photo", comment: "")//NSLocalizedString((titleText?.uppercaseString)!, comment: (titleText)!)
        hint3!.font = UIFont.systemFontOfSize(20)//UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
        hint3!.textColor = .whiteColor()
        hint3?.backgroundColor = .clearColor()
        hint3?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        hint3!.textAlignment = .Center

        spotlightView.appear(Spotlight.Oval(center: CGPointMake(245.0/320*width + 27, height - 42/568.0 * height), diameter: 60))
    }
    
    func next(labelAnimated: Bool) {
        stepIndex += 1
        let width = self.view.frame.width
        let height = self.view.frame.height
        switch stepIndex {
        case 2:
            hint1?.removeFromSuperview()
            self.view.addSubview(hint2!)
            spotlightView.move(Spotlight.Oval(center: CGPointMake(170.0/320*width + 27, height - 42/568.0 * height), diameter: 60))
        case 3:
            hint2?.removeFromSuperview()
            spotlightView.move(Spotlight.Oval(center: CGPointMake(92.0/320*width + 27, height - 42/568.0 * height), diameter: 60))
            self.view.addSubview(hint3!)
        case 4:
            dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
        

    }
    
}

extension CCSpotLightViewController: SpotlightViewControllerDelegate {
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