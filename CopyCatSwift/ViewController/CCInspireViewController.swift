//
//  CCInspireViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/31/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import GoogleMobileAds


class CCInspireViewController : UIViewController, GADBannerViewDelegate {
    private var titleLabel = CCLabel()
    private let closeButton = UIButton()
    private let instaButton = UIButton()
    private let tableViewController = CCInspireTableViewController()
    private var banner = GADBannerView()
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    func instaAction() {
        tableViewController.instaAction()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view!.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
        let swipe = UISwipeGestureRecognizer(target: self, action: "closeAction")
        swipe.direction = .Right
        self.view!.addGestureRecognizer(swipe)

        //Child VC
        addChildViewController(tableViewController)
        tableViewController.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 90);
        view.addSubview(tableViewController.view)
        tableViewController.didMoveToParentViewController(self)
        
        //Title
        titleLabel.frame = CGRectMake(50, -1, self.view.frame.size.width - 100, 40)
        titleLabel.text = NSLocalizedString("GALLERY", comment: "INSPIRE")
        titleLabel.font = UIFont(name: NSLocalizedString("Font", comment: "Georgia"), size: 20)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        self.view!.addSubview(titleLabel)
        
        //Close
        closeButton.frame = CGRectMake(0, 1, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "back.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "back_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: "closeAction", forControlEvents: .TouchUpInside)
        self.view!.addSubview(closeButton)

    
        //instagram
        instaButton.frame = CGRectMake(self.view.frame.size.width - 40, 5, 30, 30)
        instaButton.setBackgroundImage(UIImage(named: "instagram.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)), forState: .Normal)
        instaButton.addTarget(self, action: "instaAction", forControlEvents: .TouchUpInside)
//        self.view!.addSubview(instaButton)
        
        // google ad banner
        banner.frame = CGRectMake(0, self.view.frame.size.height - 50, 320, 50)
        banner.delegate = self
        banner.adUnitID = "ca-app-pub-5357330627176439/9776620702"
        banner.rootViewController = self
        banner.loadRequest(GADRequest())
        self.view!.addSubview(banner)
    }
}