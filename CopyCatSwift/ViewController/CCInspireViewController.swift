//
//  CCInspireViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/31/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import GoogleMobileAds


class CCInspireViewController : UIViewController, GADBannerViewDelegate, TableDelegate {
    private var titleLabel = CCLabel()
    private let closeButton = UIButton()
    private let instaButton = UIButton()
    private let gpsButton = UIButton()
    private let tableViewController = CCInspireTableViewController()
    private var banner = GADBannerView()
    var indicatorView = UIView()
    //MARK: UI Actions
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    func gpsAction(){
        tableViewController.gpsAction()
    }
    
    func searchAction(){
        tableViewController.searchAction()
    }
    
    //MARK: UI Lifecycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func startIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            // You only need to adjust this frame to move it anywhere you want
            self.indicatorView = UIView(frame: CGRect(x: self.view.frame.midX - 90, y: self.view.frame.midY - 25, width: 180, height: 50))
            NSLog(self)
            self.indicatorView.backgroundColor = UIColor.whiteColor()
            self.indicatorView.alpha = 0.8
            self.indicatorView.layer.cornerRadius = 10
            
            //Here the spinnier is initialized
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityView.startAnimating()
            
            let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
            textLabel.textColor = UIColor.grayColor()
            textLabel.text = "Searching"
            textLabel.textAlignment = .Left
            
            self.indicatorView.addSubview(activityView)
            self.indicatorView.addSubview(textLabel)
            
            self.view.addSubview(self.indicatorView)
        }
        
    }
    
    func stopIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.indicatorView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view!.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(CCInspireViewController.closeAction))
        swipe.direction = .Right
        self.view!.addGestureRecognizer(swipe)

        //Child VC
        tableViewController.delegate = self
        addChildViewController(tableViewController)
        tableViewController.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 90);
        view.addSubview(tableViewController.view)
        tableViewController.didMoveToParentViewController(self)
        
        //Title
        titleLabel.frame = CGRectMake(50, -1, self.view.frame.size.width - 120, 40)
        titleLabel.text = NSLocalizedString("GALLERY", comment: "INSPIRE")
        titleLabel.font = UIFont(name: NSLocalizedString("Font", comment: "Georgia"), size: 20)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        self.view!.addSubview(titleLabel)
        
        //Close
        closeButton.frame = CGRectMake(0, 1, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "back.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "back_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(CCInspireViewController.closeAction), forControlEvents: .TouchUpInside)
        self.view!.addSubview(closeButton)

    
        //Instagram
        instaButton.frame = CGRectMake(self.view.frame.size.width - 40, 5, 30, 30)
        instaButton.setBackgroundImage(UIImage(named: "search.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)), forState: .Normal)
        instaButton.addTarget(self, action: #selector(CCInspireViewController.searchAction), forControlEvents: .TouchUpInside)
        self.view!.addSubview(instaButton)

        
        //GPS
        gpsButton.frame = CGRectMake(self.view.frame.size.width - 40 - 30 - 20, 5, 30, 30)
        gpsButton.setBackgroundImage(UIImage(named: "geofence.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)), forState: .Normal)
        gpsButton.addTarget(self, action: #selector(CCInspireViewController.gpsAction), forControlEvents: .TouchUpInside)
        self.view!.addSubview(gpsButton)

        // google ad banner
        banner.frame = CGRectMake(0, self.view.frame.size.height - 50, 320, 50)
        banner.delegate = self
        banner.adUnitID = "ca-app-pub-5357330627176439/9776620702"
        banner.rootViewController = self
        banner.loadRequest(GADRequest())
        self.view!.addSubview(banner)
    }
}