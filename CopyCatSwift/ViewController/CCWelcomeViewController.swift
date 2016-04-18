//
//  ViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/16/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
//import CoreData


class CCWelcomeViewController: UIViewController {
    private var backgroundImageView = UIImageView()
    private var placeHolderImageView = UIImageView()
    private var categoryButton = UIButton()
    private var inspireButton = UIButton()
    private var instagramLoingButton = UIButton()
    private var profileButton = UIButton()

    func openGallery(){
        let controller = CCCategoryViewController()
        controller.modalTransitionStyle = .CrossDissolve
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func openProfile() {
        let vc = CCProfileViewController()
        vc.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func openInspire() {
        let vc = CCInspireViewController()
        vc.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openInstagramLogin() {
        let vc = InstagramLoginViewController()
        vc.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewWillAppear(animated: Bool) {
//        NSLog("user type = \(CCCoreUtil.userType)")
//        switch CCCoreUtil.userType {
//        case 1:
//            instagramLoingButton.removeTarget(self, action: "openInstagramLogin", forControlEvents: .TouchUpInside)
//            instagramLoingButton.alpha = 0
//            break
//        default:
//            instagramLoingButton.setBackgroundImage(UIImage(named: "gallery.png"), forState: .Normal)
//            instagramLoingButton.setBackgroundImage(UIImage(named: "gallery_highlight.png"), forState: .Highlighted)
//            instagramLoingButton.addTarget(self, action: "openInstagramLogin", forControlEvents: .TouchUpInside)
//            instagramLoingButton.alpha = 1
//        }
        
         let inset = UIEdgeInsetsMake(7.5, 7.5, 12.5, 12.5)

        
        profileButton.setImage(CCCoreUtil.userPicture.imageWithAlignmentRectInsets(inset), forState: UIControlState.Normal)
        profileButton.contentEdgeInsets = inset
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init offset and ImageView
        var offset : CGFloat = 0.0

        //Background
        self.backgroundImageView.frame = self.view.frame
        if self.view.frame.size.height == 568 {
            self.backgroundImageView.image = UIImage(named: "LaunchImage_2x_faded.png")
        } else {
            self.backgroundImageView.image = UIImage(named: "LaunchImage_1x_faded.png")
            offset = 75
        }
        self.view!.addSubview(self.backgroundImageView)
        self.backgroundImageView.alpha = 0
        
        //Buttons
        categoryButton.frame = CGRectMake(80, 340.0 - offset, 50, 50)
        categoryButton.setBackgroundImage(UIImage(named: "photo.png"), forState: .Normal)
        categoryButton.setBackgroundImage(UIImage(named: "photo_highlight.png"), forState: .Highlighted)
        categoryButton.addTarget(self, action: "openGallery", forControlEvents: .TouchUpInside)
        self.view!.addSubview(categoryButton)
        
        inspireButton.frame = CGRectMake(self.view.frame.size.width - 115, 340 - offset, 50, 50)
        inspireButton.setBackgroundImage(UIImage(named: "gallery.png"), forState: .Normal)
        inspireButton.setBackgroundImage(UIImage(named: "gallery_highlight.png"), forState: .Highlighted)
        inspireButton.addTarget(self, action: "openInspire", forControlEvents: .TouchUpInside)
        self.view!.addSubview(inspireButton)

        //instagram
        instagramLoingButton.frame = CGRectMake(self.view.frame.size.width - 115, 340 - offset - 60, 50, 50)
        self.view!.addSubview(instagramLoingButton)
        
        //Button Labels
        let cameraLabel: UILabel = UILabel(frame: CGRectMake(75, 393 - offset, 60, 15))
        cameraLabel.textAlignment = .Center
        cameraLabel.text = NSLocalizedString("CAMERA", comment: "CAMERA")
        cameraLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
        self.view!.addSubview(cameraLabel)
        
        let libraryLabel: UILabel = UILabel(frame: CGRectMake(self.view.frame.size.width - 119.5, 393 - offset, 60, 15))
        libraryLabel.textAlignment = .Center
        libraryLabel.text = NSLocalizedString("GALLERY", comment:"GALLERY")
        libraryLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
        self.view!.addSubview(libraryLabel)
        
        

        let singleTap = UITapGestureRecognizer.init(target: self, action: "openProfile")
        
        profileButton.addGestureRecognizer(singleTap)
        profileButton.userInteractionEnabled = true
        
        profileButton.imageView?.layer.cornerRadius = 12
        profileButton.imageView?.clipsToBounds = true
        profileButton.imageView?.layer.borderWidth = 1
        profileButton.imageView?.layer.borderColor = UIColor.whiteColor().CGColor
        view!.addSubview(profileButton)
       
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: profileButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: profileButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: profileButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 45))
        
        view.addConstraint(NSLayoutConstraint(item: profileButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 45))

        
        //Placeholder for Fading
        self.placeHolderImageView.frame = self.view.frame
        if self.view.frame.size.height == 568 {
            self.placeHolderImageView.image = UIImage(named: "LaunchImage_2x.png")
        } else {
            self.placeHolderImageView.image = UIImage(named: "LaunchImage_1x.png")
        }
        self.view!.addSubview(self.placeHolderImageView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Fading
    override func viewDidAppear(animated: Bool) {
        if CCCoreUtil.userType > 0 {
         
            
        }
        UIView.animateWithDuration(0.1) { () -> Void in
            self.placeHolderImageView.alpha = 0;
            self.backgroundImageView.alpha = 1;
        }
    }
    
}





