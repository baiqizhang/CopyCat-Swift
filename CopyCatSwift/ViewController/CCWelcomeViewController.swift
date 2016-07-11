//
//  ViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/16/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import Gecco
import Crashlytics
//import CoreData


class CCWelcomeViewController: UIViewController {
    private var backgroundImageView = UIImageView()
    private var placeHolderImageView = UIImageView()
    private var logoImageView = UIImageView()
    
    private var categoryButton = UIButton()
    private var inspireButton = UIButton()
    private var instagramLoingButton = UIButton()
    private var profileButton = UIButton()
    private var guideButton = UIButton()
    
    private var searchTextField = UITextField()
    private var searchButton = UIButton()
    private var collectionView = UIView()
    
    
    private var toHide : [UIView] = []
    private var toShow : [UIView] = []
    private var libraryViews : [UIView] = []
    
    // Actions
    func openGalleryWithImage(image:UIImage){
        // show animation each time user re-enter categoryview
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey("isFirstTimeUser")
        userDefault.synchronize()
        
        //create overlay view
        let frame: CGRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        let overlayView = CCOverlayView(frame: frame, image: image)
        
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
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func tapAction(){
        searchTextField.resignFirstResponder()
    }
    func searchAction(){
        let vc = CCInspireCollectionViewController(tag: self.searchTextField.text!)
        vc.modalTransitionStyle = .CrossDissolve
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.addAnimation(transition, forKey: nil)
        
        presentViewController(vc, animated: false, completion: nil)

    }
    
    func feedbackAction(){
        let alertController = UIAlertController(title: "Quick Feedback", message: "Are you enjoying this App?", preferredStyle: .Alert)

        let loveAction = UIAlertAction(title: "Yes, very much!", style: .Default) { (_) in
            let alertController = UIAlertController(title: "That's nice. Thank you", message: "Can you help us by leaving a review on the AppStore?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Sure!", style: .Default) { (_) in
                iRate.sharedInstance().openRatingsPageInAppStore()
            }
            let cancelAction = UIAlertAction(title: "No", style: .Cancel)  { (_) in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        }
        let hateAction = UIAlertAction(title: "Not really", style: .Cancel) { (_) in
            let alertController = UIAlertController(title: "How can we improve?", message: "Do you want to tell us how to improve our app and make you happy?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Sure!", style: .Default) { (_) in
                // NOTE: maxCount = 0 to hide count
                let popupTextView = YIPopupTextView(placeHolder: NSLocalizedString("The developer values your feedback.", comment: "Feedback"), maxCount: 1000, buttonStyle: YIPopupTextViewButtonStyle.RightCancelAndDone)
                popupTextView.delegate = self
                popupTextView.caretShiftGestureEnabled = true
                // default = NO
                popupTextView.text = ""
                popupTextView.showInViewController(self)

            }
            let cancelAction = UIAlertAction(title: "No", style: .Cancel)  { (_) in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        }
        alertController.addAction(loveAction)
        alertController.addAction(hateAction)
        presentViewController(alertController, animated: true) {}
    }
    
    // Lifecycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewWillAppear(animated: Bool) {
        let inset = UIEdgeInsetsMake(7.5, 7.5, 12.5, 12.5)
        profileButton.setImage(CCCoreUtil.userPicture.imageWithAlignmentRectInsets(inset), forState: UIControlState.Normal)
        profileButton.contentEdgeInsets = inset
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init offset and ImageView
        var offset : CGFloat = -100.0
        if self.view.frame.size.height == 568 {
        } else {
            offset = 75
        }
        
        //Background and logo
        self.placeHolderImageView.frame = self.view.frame
        self.placeHolderImageView.backgroundColor = .blackColor()
        self.view!.addSubview(self.placeHolderImageView)
        
        backgroundImageView.frame = self.view.frame
        backgroundImageView.image = UIImage(named: "bg_welcome.png")
        backgroundImageView.contentMode = .ScaleAspectFill
        view!.addSubview(self.backgroundImageView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CCWelcomeViewController.tapAction))
        backgroundImageView.addGestureRecognizer(tapRecognizer)
        
        
        logoImageView = UIImageView(frame: CGRectMake(view.frame.size.width/2-100, view.frame.size.height/2-140, 200, 70))
        logoImageView.image = UIImage(named: "cclogo.png")
        view!.addSubview(logoImageView)

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
        
        
        
        
        
        //search bar
        searchTextField.frame = CGRectMake(self.view.frame.size.width/2 - 120, view.frame.size.height/2 - 50 , 250, 35)
        searchTextField.font = UIFont.systemFontOfSize(10.5)
        searchTextField.delegate = self
        searchTextField.borderStyle = .RoundedRect
        searchTextField.backgroundColor = UIColor.whiteColor()
        searchTextField.layer.borderWidth = 8.0;
        searchTextField.layer.cornerRadius = 8.0;
        searchTextField.layer.borderColor = UIColor.clearColor().CGColor

        searchTextField.autocorrectionType = .Default
        searchTextField.spellCheckingType = .No
        searchTextField.keyboardType = .ASCIICapable
        searchTextField.returnKeyType = .Search
        searchTextField.clearButtonMode = .WhileEditing
        searchTextField.addTarget(self, action: #selector(CCWelcomeViewController.textFieldDidChange), forControlEvents: .EditingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string:"What to capture today? e.g. coffee",
                                                                   attributes:[NSForegroundColorAttributeName:
                                                                    UIColor.grayColor()])
        
        
        let magnifyingGlass = UIImageView(frame: CGRectMake(5, 0, 20, 20))
        magnifyingGlass.image = UIImage(named: "search.png")
        magnifyingGlass.image = magnifyingGlass.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        magnifyingGlass.tintColor = UIColor.grayColor()
        
        let leftView = UIView(frame: CGRectMake(0, 0, 25, 20))
        leftView.addSubview(magnifyingGlass)
        
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .Always
        
        view.addSubview(searchTextField)
        
        //search button
        searchButton.frame = CGRectMake(self.view.frame.size.width/2 + 90, view.frame.size.height/2 - 50 , 50, 35)
        searchButton.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)//searchButton.tintColor
        searchButton.layer.borderWidth = 1.0;
        searchButton.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor//UIColor.clearColor().CGColor
        searchButton.layer.cornerRadius = 8.0;
        searchButton.setAttributedTitle(NSAttributedString(string:"Search",
            attributes:[NSForegroundColorAttributeName:
                UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(12)]), forState: .Normal)
        searchButton.alpha = 0
        searchButton.addTarget(self, action: #selector(CCWelcomeViewController.searchAction), forControlEvents: .TouchUpInside)
        view.addSubview(searchButton)
        
        collectionView.frame = CGRectMake(self.view.frame.size.width/2 - 60, view.frame.size.height/2 + 50 , 120, 50)
        collectionView.backgroundColor = .whiteColor()
        collectionView.alpha = 0
        view.addSubview(collectionView)
        
        //or select from my
        let orView = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 80, view.frame.size.height/2, 20, 35))
        orView.text = "or"
        orView.textColor = .whiteColor()
        orView.font = UIFont.systemFontOfSize(14)
        view.addSubview(orView)
        
        let library = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 60, view.frame.size.height/2, 135, 35))
        library.setAttributedTitle(NSAttributedString(string:"Use my own template",
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:UIFont.systemFontOfSize(11.5)]), forState: .Normal)
        library.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
        library.layer.borderWidth = 1
        library.layer.cornerRadius = 17.0;
        library.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)
        library.addTarget(self, action: #selector(pickImage), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(library)
        
        let feedback = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 40, view.frame.size.height-40, 80, 30))
        feedback.setAttributedTitle(NSAttributedString(string:"Feedback",
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:UIFont.systemFontOfSize(10.5)]), forState: .Normal)
        feedback.layer.borderColor = UIColor(hexNumber: 0x777777).CGColor
        feedback.layer.borderWidth = 1
        feedback.layer.cornerRadius = 15.0;
        feedback.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.15)
        feedback.alpha=0.8
        feedback.addTarget(self, action: #selector(feedbackAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(feedback)
        
        
        // ----- shown on guide page -----

        
        // instructions
        let textWidth:CGFloat = 100.0
        
        let step1 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 250 , textWidth*2, 35))
        step1.text = "1. Decide what to capture"
        step1.textColor = UIColor(hexNumber: 0xBBBBBB)
        step1.font = UIFont.systemFontOfSize(16)
        step1.textAlignment = .Left
        view.addSubview(step1)
        
        let step2 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 300 , textWidth*2, 35))
        step2.text = "2. Pick a reference photo"
        step2.textColor = UIColor(hexNumber: 0xBBBBBB)
        step2.font = UIFont.systemFontOfSize(16)
        step2.textAlignment = .Left
        view.addSubview(step2)
        
        let step3 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 10, 350 , textWidth*2, 35))
        step3.text = "3. Swipe and snap!"
        step3.textColor = UIColor(hexNumber: 0xBBBBBB)
        step3.font = UIFont.systemFontOfSize(16)
        step3.textAlignment = .Left
        view.addSubview(step3)
        
        
        let okay = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 85, 450 , 170, 38))
        let font = UIFont.systemFontOfSize(16)
        okay.setAttributedTitle(NSAttributedString(string:"Get Started",
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:font]), forState: .Normal)
        okay.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
        okay.layer.borderWidth = 1
        okay.layer.cornerRadius = 20.0;
        okay.backgroundColor = UIColor(hexNumber: 0x181818)
        okay.addTarget(self, action: #selector(getStarted), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(okay)
        
        toHide = [step1,step2,step3,okay,placeHolderImageView]
        toShow = [backgroundImageView,searchTextField,orView,library,feedback,profileButton]
        for view in self.toShow{
            view.alpha = 0
            view.userInteractionEnabled = false
        }
        
        libraryViews = [library,orView]
        
    }
}

extension CCWelcomeViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.15) {
            self.searchTextField.frame = CGRectMake(self.view.frame.size.width/2 - 120, self.view.frame.size.height/2 - 50 , 205, 35)
            self.searchButton.alpha = 1
            self.searchTextField.leftViewMode = .Never
            
//            if self.searchTextField.text!.isEmpty {
//                self.searchTextField.autocorrectionType = .No
//                self.collectionView.alpha = 1
//            }
            
            for view in self.libraryViews{
                view.alpha = 0
                view.userInteractionEnabled = false
            }
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.15) {
            self.searchTextField.frame = CGRectMake(self.view.frame.size.width/2 - 120, self.view.frame.size.height/2 - 50 , 250, 35)
            self.searchButton.alpha = 0
            self.searchTextField.leftViewMode = .Always
            
            for view in self.libraryViews{
                view.alpha = 1
                view.userInteractionEnabled = true
            }
        }
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchAction()
        return true
    }
    
    func textFieldDidChange(){
//        if self.searchTextField.text!.isEmpty {
//            self.searchTextField.autocorrectionType = .No
//            self.collectionView.alpha = 1
//        } else {
//            self.searchTextField.autocorrectionType = .Yes
//            self.collectionView.alpha = 0
//        }
    }
}



extension CCWelcomeViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true) { 
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.openGalleryWithImage(pickedImage)
            }
        }
    }
}


extension CCWelcomeViewController : YIPopupTextViewDelegate{
    func popupTextView(textView: YIPopupTextView, willDismissWithText text: String, cancelled: Bool) {
        if !cancelled {
            let str = textView.text!
            CCNetUtil.sendFeedback(str, completion: { (error) in
                if let err = error{
                    Crashlytics.logEvent(err)
                }
            })
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
}