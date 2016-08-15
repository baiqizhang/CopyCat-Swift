//
//  ViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/16/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import Crashlytics
//import CoreData


class CCWelcomeViewController: UIViewController {
    private let backgroundImageView = UIImageView()
    private let placeHolderImageView = UIImageView()
    private var logoImageView = UIImageView()
    
    private let categoryButton = UIButton()
    private let inspireButton = UIButton()
    private let instagramLoingButton = UIButton()
    private let profileButton = UIButton()
    private let guideButton = UIButton()
    
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    private var leftView = UIView()
    private let collectionView = UIView()
    
    private let tableView = UITableView()
    private var hotTag: [String] = []
    private var history : [String] = [] //init in willappear
    private var showHistory = false
    
    private var toHide : [UIView] = []
    private var toShow : [UIView] = []
    private var libraryViews : [UIView] = []
    
    
    // MARK: Actions
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
        if searchTextField.text == ""{
            return
            
            let overlayImage = UIImage(named: "4_0.jpg")
            
            //Add to "Saved"
            CCCoreUtil.addPhotoForTopCategory(overlayImage!)
            
            // show animation each time user re-enter categoryview
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.removeObjectForKey("isFirstTimeUser")
            userDefault.synchronize()
            
            //create overlay view
            let frame: CGRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            let overlayView = CCOverlayView(frame: frame, image: overlayImage!)
            
            //open camera
            let AVCVC: AVCamViewController = AVCamViewController(overlayView: overlayView)
            overlayView.delegate = AVCVC
            self.presentViewController(AVCVC, animated: true, completion: {
                AVCVC.setRefImage()
            })
            
        } else {
            // Add to history
            CCCoreUtil.addSearchHistory(searchTextField.text!)
            
            // Show search result
            let vc = CCInspireCollectionViewController(tag: self.searchTextField.text!)
            vc.modalTransitionStyle = .CrossDissolve
            vc.searchTitle = self.searchTextField.text
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.addAnimation(transition, forKey: nil)
            
            presentViewController(vc, animated: false, completion: nil)
        }
    }
    
    func feedbackAction(){
        let alertController = UIAlertController(title: NSLocalizedString("Quick Feedback", comment: "Quick Feedback"), message: NSLocalizedString("Are you enjoying this App?", comment: "Are you enjoying this App?"), preferredStyle: .Alert)

        let loveAction = UIAlertAction(title: NSLocalizedString("Yes, very much!", comment: "Yes, very much!"), style: .Default) { (_) in
            let alertController = UIAlertController(title: NSLocalizedString("That's nice. Thank you", comment: ""), message: NSLocalizedString("Can you help us by leaving a review on the AppStore?", comment: ""), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("Sure!", comment: ""), style: .Default) { (_) in
                //iRate.sharedInstance().openRatingsPageInAppStore()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel)  { (_) in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        }
        let hateAction = UIAlertAction(title: NSLocalizedString("Not really", comment: ""), style: .Cancel) { (_) in
            let alertController = UIAlertController(title: NSLocalizedString("How can we improve?", comment: ""), message: NSLocalizedString("Do you want to tell us how to improve our app and make you happy?", comment: ""), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: NSLocalizedString("Sure!", comment: ""), style: .Default) { (_) in
                // NOTE: maxCount = 0 to hide count
                let popupTextView = YIPopupTextView(placeHolder: NSLocalizedString(NSLocalizedString("The developer values your feedback.", comment: ""), comment: "Feedback"), maxCount: 1000, buttonStyle: YIPopupTextViewButtonStyle.RightCancelAndDone)
                popupTextView.delegate = self
                popupTextView.caretShiftGestureEnabled = true
                // default = NO
                popupTextView.text = ""
                popupTextView.showInViewController(self)

            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel)  { (_) in }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        }
        alertController.addAction(loveAction)
        alertController.addAction(hateAction)
        
        presentViewController(alertController, animated: true) {}
    }
    
    // MARK: Lifecycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        history = CCCoreUtil.getSearchHistory()
        if searchTextField.text != ""{
            textFieldDidBeginEditing(searchTextField)
            textFieldDidChange()
            searchTextField.becomeFirstResponder()
        }
        tableView.reloadData()
        
        self.popupWebView()

    }
    
    func popupWebView() {
        let alertTitle = NSLocalizedString("Update", comment: "Update")
        let alertController = UIAlertController(title: alertTitle, message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .Alert)
        let okText = NSLocalizedString("Got it", comment: "Got it")
        let cancelAction: UIAlertAction = UIAlertAction(title: okText, style: .Cancel) { action -> Void in
            print("Cancel")
        }
        alertController.addAction(cancelAction)
        let webView = UIWebView()
        if self.view.frame.width == 320 {
            webView.frame = CGRectMake(-5, 50, alertController.view.frame.width / 4 * 3 + 10, 220)
        } else {
            webView.frame = CGRectMake(-10, 50, 270, 220)
        }
        webView.backgroundColor = UIColor.clearColor()
        webView.opaque = false
        alertController.view.addSubview(webView)
        let oldVersion = CCCoreUtil.getNotificationVersion()
        let urlString = "http://ec2-52-42-208-246.us-west-2.compute.amazonaws.com:3001/api/v1/whatsnew?lang=\(NSLocale.preferredLanguages()[0] as String)&version=\(oldVersion)"
        
        CCNetUtil.getJSONFromURL(urlString) { (json) in
            if json != nil {
                let curVersion = (Int(String(json["curVersion"])))!
                if curVersion > oldVersion {
                    CCCoreUtil.setNotificationVersion(curVersion)
                    dispatch_async(dispatch_get_main_queue(), { 
                        webView.loadHTMLString(String(json["html"]), baseURL: nil)
                        webView.scrollView.contentOffset = CGPointMake(0, 100)
                        webView.stringByEvaluatingJavaScriptFromString("document. body.style.zoom = 0.85;")
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hotTag = CCNetUtil.getHottag()
        CCNetUtil.getSpecialTags()
        //Init offset and ImageView
        var offset : CGFloat = -100.0
        if self.view.frame.size.height == 568 {
        } else {
            offset = 75
        }
        let windowWidth = view.frame.size.width
        let windowHeight = view.frame.size.height
        
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
        
        
        logoImageView = UIImageView(frame: CGRectMake(view.frame.size.width/2-(100.0/320.0)*windowWidth, view.frame.size.height/2-(140.0/568)*windowHeight, (200.0/320.0)*windowWidth, (70.0/568)*windowHeight))
        logoImageView.image = UIImage(named: "cclogo.png")
        view!.addSubview(logoImageView)

        
        //search bar
        searchTextField.frame = CGRectMake(self.view.frame.size.width/2 - (120.0/320.0)*windowWidth, view.frame.size.height/2 - (50.0/568)*windowHeight , (250.0/320)*windowWidth, (35.0/568)*windowHeight)
        searchTextField.font = UIFont.systemFontOfSize(10.5)
        searchTextField.delegate = self
        searchTextField.borderStyle = .RoundedRect
        searchTextField.backgroundColor = UIColor.whiteColor()
        searchTextField.layer.borderWidth = 8.0;
        searchTextField.layer.cornerRadius = 8.0;
        searchTextField.layer.borderColor = UIColor.clearColor().CGColor

        searchTextField.autocorrectionType = .Default
        searchTextField.spellCheckingType = .No
        searchTextField.returnKeyType = .Search
        searchTextField.clearButtonMode = .WhileEditing
        searchTextField.addTarget(self, action: #selector(CCWelcomeViewController.textFieldDidChange), forControlEvents: .EditingChanged)
        searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("What to capture today? e.g. coffee", comment: ""),
                                                                   attributes:[NSForegroundColorAttributeName:
                                                                    UIColor.grayColor()])
        
        
        let magnifyingGlass = UIImageView(frame: CGRectMake(5, 0, 20, 20))
        magnifyingGlass.image = UIImage(named: "search.png")
        magnifyingGlass.image = magnifyingGlass.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        magnifyingGlass.tintColor = UIColor.grayColor()
        
        leftView = UIView(frame: CGRectMake(0, 0, (25.0/320.0)*windowWidth, 20))
        leftView.addSubview(magnifyingGlass)
        
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .Always
        
        
        view.addSubview(searchTextField)
        
        //search button
        searchButton.frame = CGRectMake(self.view.frame.size.width/2 + (105.0/320.0)*windowWidth, 35 , 37, 37)
        searchButton.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.15)
        searchButton.setImage(UIImage(named: "search.png"), forState: .Normal)
        searchButton.setImage(UIImage(named: "search.png")?.maskWithColor(UIColor(hex:0x41AFFF)), forState:.Highlighted)
        
        
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        searchButton.layer.borderWidth = 1;
        searchButton.layer.borderColor = UIColor(hexNumber: 0xEEEEEE).CGColor
        searchButton.layer.cornerRadius = 8.0;
        searchButton.alpha = 0
        searchButton.addTarget(self, action: #selector(CCWelcomeViewController.searchAction), forControlEvents: .TouchUpInside)
        view.addSubview(searchButton)
        
        collectionView.frame = CGRectMake(self.view.frame.size.width/2 - 60, view.frame.size.height/2 + 50 , 120, 50)
        collectionView.backgroundColor = .whiteColor()
        collectionView.alpha = 0
        view.addSubview(collectionView)
        
        //or select from my lib
        let orView = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 80, view.frame.size.height/2, 20, 35))
        orView.text = "or"
        orView.textColor = .whiteColor()
        orView.font = UIFont.systemFontOfSize(14)
        view.addSubview(orView)
        
        let library = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 60, view.frame.size.height/2, 135, 35))
        library.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Use my own template", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:UIFont.systemFontOfSize(11.5)]), forState: .Normal)
        library.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Use my own template", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hex:0x41AFFF),NSFontAttributeName:UIFont.systemFontOfSize(11.5)]), forState: .Highlighted)
        
        library.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
        library.layer.borderWidth = 1
        library.layer.cornerRadius = 17.0;
        library.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.1)
        library.addTarget(self, action: #selector(pickImage), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(library)
        
        let feedback = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 40, view.frame.size.height-40, 80, 30))
        feedback.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Feedback", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:UIFont.systemFontOfSize(10.5)]), forState: .Normal)
        feedback.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Feedback", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0x41AFFF),NSFontAttributeName:UIFont.systemFontOfSize(10.5)]), forState: .Highlighted)
        feedback.layer.borderColor = UIColor(hexNumber: 0x777777).CGColor
        feedback.layer.borderWidth = 1
        feedback.layer.cornerRadius = 15.0;
        feedback.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.15)
        feedback.alpha=0.8
        feedback.addTarget(self, action: #selector(feedbackAction), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(feedback)
        
        
        //search recommendation and history
        tableView.frame = CGRectMake(self.view.frame.size.width/2 - (139.5/320.0)*windowWidth, (85.0/568)*windowHeight, (278.0/320.0)*windowWidth, (260.0/568)*windowHeight)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.layer.borderColor = UIColor(hexNumber: 0x777777).CGColor
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 5.0;
        tableView.alpha = 0
        self.view.addSubview(tableView)
        
        // ----- shown on guide page -----
        
        let textWidth:CGFloat = 105.0
        
        let step1 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 6, (250.0/568)*windowHeight , textWidth*2, 35))
        step1.text = NSLocalizedString("STEP1", comment: "")
        step1.textColor = UIColor(hexNumber: 0xBBBBBB)
        step1.font = UIFont.systemFontOfSize(16)
        step1.textAlignment = .Left
        
        
        let step2 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 6, (250.0/568)*windowHeight+50 , textWidth*2, 35))
        step2.text = NSLocalizedString("STEP2", comment: "")
        step2.textColor = UIColor(hexNumber: 0xBBBBBB)
        step2.font = UIFont.systemFontOfSize(16)
        step2.textAlignment = .Left
        
        
        let step3 = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - textWidth + 6, (250.0/568)*windowHeight+100 , textWidth*2, 35))
        step3.text = NSLocalizedString("STEP3", comment: "")
        step3.textColor = UIColor(hexNumber: 0xBBBBBB)
        step3.font = UIFont.systemFontOfSize(16)
        step3.textAlignment = .Left
        
        
        
        let okay = UIButton(frame: CGRectMake(self.view.frame.size.width/2 - 85, (250.0/568)*windowHeight+200 , 170, 38))
        let font = UIFont.systemFontOfSize(16)
        okay.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Get Started", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0xDDDDDD),NSFontAttributeName:font]), forState: .Normal)
        okay.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Get Started", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0x41AFFF),NSFontAttributeName:font]), forState: .Highlighted)
        okay.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
        okay.layer.borderWidth = 1
        okay.layer.cornerRadius = 20.0;
        okay.backgroundColor = UIColor(hexNumber: 0x222222)    
        okay.addTarget(self, action: #selector(getStarted), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // instructions
        let shown = CCCoreUtil.userDefault.integerForKey(CCCoreUtil.INSTRUCTION_SHOW_TIMES)
        if shown < 3 {
            view.addSubview(step1)
            view.addSubview(step2)
            view.addSubview(step3)
            view.addSubview(okay)
            toHide = [step1,step2,step3,okay,placeHolderImageView]
            toShow = [backgroundImageView,searchTextField,orView,library,feedback,profileButton]
            for view in self.toShow{
                view.alpha = 0
                view.userInteractionEnabled = false
            }
            CCCoreUtil.userDefault.setInteger(shown + 1, forKey: CCCoreUtil.INSTRUCTION_SHOW_TIMES)
        }
        
        libraryViews = [library,orView]
    }
}

extension CCWelcomeViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        let windowWidth = view.frame.size.width
        _ = view.frame.size.height
        
        
        UIView.animateWithDuration(0.15) {
            self.searchTextField.frame = CGRectMake(windowWidth/2 - (140.0/320.0)*windowWidth, 35, (235/320.0)*windowWidth, 37)
            self.searchButton.alpha = 1
            
            self.profileButton.alpha = 0
            self.logoImageView.alpha = 0
            
            let back = UIImageView(frame: CGRectMake(2.5, -5, 35, 35))
            back.image = UIImage(named: "back.png")
            back.tintColor = UIColor(hexNumber: 0xF2F2F2)
            back.image = back.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            back.tintColor = UIColor.grayColor()
            
            let leftView = UIView(frame: CGRectMake(0, 0, 30, 25))
            leftView.addSubview(back)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(CCWelcomeViewController.tapAction))
            leftView.addGestureRecognizer(tap)
            
            self.searchTextField.leftView = leftView
            self.tableView.alpha = 1
            for view in self.libraryViews{
                view.alpha = 0
                view.userInteractionEnabled = false
            }
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        let windowWidth = view.frame.size.width
        let windowHeight = view.frame.size.height
        
        self.tableView.alpha = 0
        UIView.animateWithDuration(0.15) {
            self.searchTextField.frame = CGRectMake(windowWidth/2 - (120.0/320.0)*windowWidth, windowHeight/2 - (50.0/568)*windowHeight , (255.0/320)*windowWidth, (35.0/568)*windowHeight)
            self.searchButton.alpha = 0
            self.searchTextField.leftView = self.leftView
            
            self.profileButton.alpha = 1
            self.logoImageView.alpha = 1
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
        let last = showHistory
        
        if self.searchTextField.text!.isEmpty {
            showHistory = false
        } else {
            showHistory = true
        }
        if showHistory != last {
            tableView.reloadData()
        }
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

extension CCWelcomeViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if showHistory{
            self.searchTextField.text = self.history[indexPath.row]
        } else {
            self.searchTextField.text = self.hotTag[indexPath.row]
        }
        self.searchAction()
    }
}

extension CCWelcomeViewController : UITableViewDataSource{
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showHistory{
            return NSLocalizedString("Search History", comment: "history")
        }
        return NSLocalizedString("Popular Tags", comment: "Popular Tags")
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view.isKindOfClass(UITableViewHeaderFooterView){
            let headerView = view as! UITableViewHeaderFooterView
            if #available(iOS 8.2, *) {
                //headerView.textLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
                headerView.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)!// Fallback on earlier versions
            } else {
                headerView.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)!// Fallback on earlier versions
            }
            headerView.textLabel?.textColor = UIColor(hexNumber: 0x222222)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showHistory{
            return self.history.count
        }
        return self.hotTag.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        var content = ""
        if showHistory{
            content = self.history[indexPath.row]
        } else {
            content = self.hotTag[indexPath.row]
        }
        cell.textLabel?.attributedText = NSAttributedString(string:content,
            attributes:[NSForegroundColorAttributeName: UIColor(hexNumber: 0x111111),NSFontAttributeName:UIFont.systemFontOfSize(13.5)])
        
        return cell
    }
}