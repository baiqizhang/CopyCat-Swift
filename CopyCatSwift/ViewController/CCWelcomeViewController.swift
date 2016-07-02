//
//  ViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/16/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import Gecco
//import CoreData


class CCWelcomeViewController: UIViewController {
    private var backgroundImageView = UIImageView()
    private var placeHolderImageView = UIImageView()
    private var categoryButton = UIButton()
    private var inspireButton = UIButton()
    private var instagramLoingButton = UIButton()
    private var profileButton = UIButton()
    private var guideButton = UIButton()
    
    private var toHide : [UIView] = []
    private var toShow : [UIView] = []

    // Actions
    func openGallery(){
        // show animation each time user re-enter categoryview
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey("isFirstTimeUser")
        userDefault.synchronize()
        
        //create overlay view
        let frame: CGRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        let overlayView = CCOverlayView(frame: frame, image: UIImage(named: "0_0.jpg")!)
        
        //open camera
        let AVCVC: AVCamViewController = AVCamViewController(overlayView: overlayView)
        overlayView.delegate = AVCVC
        self.presentViewController(AVCVC, animated: true, completion: { _ in })
        
////      old style  
//        let controller = CCCategoryViewController()
//        controller.modalTransitionStyle = .CrossDissolve
//        self.presentViewController(controller, animated: true, completion: nil)
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
    
    func userGuide() {
        let ccGuide = CCGuideViewController()
        self.presentViewController(ccGuide, animated: true, completion: nil)
    }

    
    func openInstagramLogin() {
        let vc = InstagramLoginViewController()
        vc.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
    }

    
    func getStarted() {
        UIView.animateWithDuration(0.3) { () -> Void in
            for view in self.toHide{
                view.alpha = 0
                view.userInteractionEnabled = false
            }
            for view in self.toShow{
                view.alpha = 1
                view.userInteractionEnabled = true
            }
        }
    }

    // Lifecycle
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
        var offset : CGFloat = -100.0

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
//        categoryButton.frame = CGRectMake(80, 340.0 - offset, 50, 50)
//        categoryButton.setBackgroundImage(UIImage(named: "photo.png"), forState: .Normal)
//        categoryButton.setBackgroundImage(UIImage(named: "photo_highlight.png"), forState: .Highlighted)
//        categoryButton.addTarget(self, action: #selector(CCWelcomeViewController.openGallery), forControlEvents: .TouchUpInside)
//        self.view!.addSubview(categoryButton)
//        
//        inspireButton.frame = CGRectMake(self.view.frame.size.width - 115, 340 - offset, 50, 50)
//        inspireButton.setBackgroundImage(UIImage(named: "gallery.png"), forState: .Normal)
//        inspireButton.setBackgroundImage(UIImage(named: "gallery_highlight.png"), forState: .Highlighted)
//        inspireButton.addTarget(self, action: #selector(CCWelcomeViewController.openInspire), forControlEvents: .TouchUpInside)
//        self.view!.addSubview(inspireButton)
//        
//        guideButton.frame = CGRectMake(self.view.frame.size.width - 50, 520 , 30, 30)
//        guideButton.setBackgroundImage(UIImage(named: "help.png"), forState: .Normal)
//        guideButton.addTarget(self, action: #selector(CCWelcomeViewController.userGuide), forControlEvents: .TouchUpInside)
//
//        
//        //Button Labels
//        let cameraLabel: UILabel = UILabel(frame: CGRectMake(75, 393 - offset, 60, 15))
//        cameraLabel.textAlignment = .Center
//        cameraLabel.text = NSLocalizedString("CAMERA", comment: "CAMERA")
//        cameraLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
//        self.view!.addSubview(cameraLabel)
//        
//        let libraryLabel: UILabel = UILabel(frame: CGRectMake(self.view.frame.size.width - 119.5, 393 - offset, 60, 15))
//        libraryLabel.textAlignment = .Center
//        libraryLabel.text = NSLocalizedString("GALLERY", comment:"GALLERY")
//        libraryLabel.font = UIFont.systemFontOfSize(CCCoreUtil.fontSizeS)
//        self.view!.addSubview(libraryLabel)

        
        
        let searchTextField = UITextField(frame: CGRectMake(self.view.frame.size.width/2 - 120, 300 , 250, 30))
        searchTextField.font = UIFont.systemFontOfSize(10.5)
        searchTextField.delegate = self
        searchTextField.keyboardType = .ASCIICapable
        searchTextField.returnKeyType = .Search
        searchTextField.borderStyle = .RoundedRect
        searchTextField.backgroundColor = UIColor.whiteColor()
        searchTextField.leftViewMode = .Never
        searchTextField.layer.borderWidth = 8.0;
        searchTextField.layer.cornerRadius = 10.0;
        searchTextField.layer.borderColor = UIColor.clearColor().CGColor

        searchTextField.attributedPlaceholder = NSAttributedString(string:"What to capture today? e.g. coffee",
                                                                   attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])

//        let magnifyingGlass = UILabel()
//        magnifyingGlass.text = " 🔍"
//        magnifyingGlass.sizeToFit()
        
        let magnifyingGlass = UIImageView(frame: CGRectMake(5, 0, 20, 20))
        magnifyingGlass.image = UIImage(named: "search.png")
        magnifyingGlass.image = magnifyingGlass.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        magnifyingGlass.tintColor = UIColor.grayColor()
        
        let leftView = UIView(frame: CGRectMake(0, 0, 25, 20))
        leftView.addSubview(magnifyingGlass)
        
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .Always
        
        view.addSubview(searchTextField)
        
        
        

        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(CCWelcomeViewController.openProfile))
        
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
        
        
        
        let textWidth:CGFloat = 100.0
        
        let step1 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 300 , textWidth*2, 35))
        step1.text = "1. Decide what to capture"
        step1.textColor = UIColor(hexNumber: 0xDDDDDD)
        step1.font = UIFont.systemFontOfSize(16)
        step1.userInteractionEnabled = false
        view.addSubview(step1)
        
        let step2 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 350 , textWidth*2, 35))
        step2.text = "2. Pick a reference photo"
        step2.textColor = UIColor(hexNumber: 0xDDDDDD)
        step2.font = UIFont.systemFontOfSize(16)
        step2.userInteractionEnabled = false
        view.addSubview(step2)
        
        let step3 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 400 , textWidth*2, 35))
        step3.text = "3. Swipe and snap!"
        step3.textColor = UIColor(hexNumber: 0xDDDDDD)
        step3.font = UIFont.systemFontOfSize(16)
        step3.userInteractionEnabled = false
        view.addSubview(step3)
        
        
        let okay = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 60, 470 , 120, 30))
        let font = UIFont.systemFontOfSize(14)
        okay.setAttributedTitle(NSAttributedString(string:"Get Started",
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:font]), forState: .Normal)
        okay.layer.borderColor = UIColor(hexNumber: 0x888888).CGColor
        okay.layer.borderWidth = 0.5
        okay.backgroundColor = UIColor(hexNumber: 0x333333)
        okay.addTarget(self, action: #selector(getStarted), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(okay)
        
        toHide = [step1,step2,step3,okay,placeHolderImageView]
        toShow = [backgroundImageView,searchTextField,profileButton]
        for view in self.toShow{
            view.alpha = 0
            view.userInteractionEnabled = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Fading
    override func viewDidAppear(animated: Bool) {
//        if CCCoreUtil.userType > 0 {
//        }
//        
//        if (CCCoreUtil.welcomeGuide == false) {
//            userGuide()
//            CCCoreUtil.didWelcomeGuide()
//        }
        
        

        
//        //Close
//        closeButton.frame = CGRectMake(5, -5, 40, 40)
//        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
//        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
//        closeButton.addTarget(self, action: "closeAction", forControlEvents: .TouchUpInside)
//        view!.addSubview(closeButton)
//        
//        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        let authorize_url = "https://www.instagram.com"
//        print(authorize_url)
//        webView.loadRequest(NSURLRequest(URL: NSURL(string: authorize_url)!))
//        self.view.addSubview(webView)
    }
    
}

extension CCWelcomeViewController:UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        let alert = UIAlertView(title: "Search", message: textField.text, delegate: nil, cancelButtonTitle: "OK" )
//        alert.show()
        let vc = CCInspireCollectionViewController(tag: textField.text!)
        vc.modalTransitionStyle = .CrossDissolve
        presentViewController(vc, animated: true, completion: nil)
        return true
    }
}



