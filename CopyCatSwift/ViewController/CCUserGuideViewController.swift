//
//  CCUserGuideViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 8/23/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCUserGuideViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let windowWidth = view.frame.size.width
        //let windowHeight = view.frame.size.height
        

        let hiView = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 20, view.frame.size.height/2 - 200, 40, 50))
        hiView.text = "Hi"
        hiView.textColor = .blackColor()
        hiView.font = UIFont.systemFontOfSize(40)
        view.addSubview(hiView)

        let wordView = UITextView(frame: CGRectMake(self.view.frame.size.width/2 - 150, view.frame.size.height/2 - 100, 300, 200))
        wordView.text = "Let's take a selfie using CopyCat!"
        wordView.textColor = .blackColor()
        wordView.font = UIFont.systemFontOfSize(24)
        wordView.textAlignment = NSTextAlignment.Center
        view.addSubview(wordView)

        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.alpha = 1
        let library = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 60, view.frame.size.height/2 + 80, 135, 35))
        library.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Start CopyCatting!", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor.blackColor(),NSFontAttributeName:UIFont.systemFontOfSize(11.5)]), forState: .Normal)
        library.layer.borderColor = UIColor.blackColor().CGColor
        library.layer.borderWidth = 1
        library.layer.cornerRadius = 17.0;
        library.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)
        library.addTarget(self, action: #selector(beginSelfieGuide), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(library)
    }

    func beginSelfieGuide() {
        // Add to history
        
        // Show search result
        let vc = CCInspireCollectionViewController(tag: NSLocalizedString("Selfie", comment: ""))
        vc.modalTransitionStyle = .CrossDissolve
        vc.searchTitle = NSLocalizedString("Selfie", comment: "")
        vc.shouldShowHint = true
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.addAnimation(transition, forKey: nil)
        
        presentViewController(vc, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {

    }

}
