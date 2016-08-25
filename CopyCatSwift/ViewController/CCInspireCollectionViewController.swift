//
//  GalleryViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/18/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit
import MapKit
import AssetsLibrary

class CCInspireCollectionViewController: UIViewController{
    
    
    private let searchTextField = UITextField()
    private let closeButton = UIButton()
    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView : CCCollectionView?
    var shouldShowHint = false
    
    var searchTitle: String?
    var indicatorView = UIView()
    var postList:[CCPost]?
    var hintLabel = UITextView()
    
    private let locationManager = CLLocationManager()
    private var locationFound = false
    
    
    convenience init(tag : String){
        self.init()
        self.searchTextField.text = tag
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Actions
    func startIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            // You only need to adjust this frame to move it anywhere you want
            self.indicatorView = UIView(frame: CGRect(x: self.view.frame.midX - 90, y: self.view.frame.midY - 25, width: 180, height: 50))
            self.indicatorView.backgroundColor = UIColor.whiteColor()
            self.indicatorView.alpha = 0.8
            self.indicatorView.layer.cornerRadius = 10
            
            //Here the spinnier is initialized
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityView.startAnimating()
            
            let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
            textLabel.textColor = UIColor.grayColor()
            textLabel.text = NSLocalizedString("Searching...", comment: "")
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
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    
    //geo search
    internal func gpsAction(){
        let alertController = UIAlertController(title: "Geo-search", message: "", preferredStyle: .Alert)
        
        let searchMyLocAction = UIAlertAction(title: NSLocalizedString("Search Nearby", comment: ""), style: .Default) { (_) in
            self.startIndicator()
            
            //start tracking gps
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationFound = false
            
        }
        
        let searchByAddrAction = UIAlertAction(title: NSLocalizedString("Search By Address", comment: ""), style: .Default) { (_) in
            self.stopIndicator()
            
            let addrTextField = alertController.textFields![0] as UITextField
            CCNetUtil.searchGPSByAddressString(addrTextField.text!, completion: { (posts) in
                self.stopIndicator()
                
                if posts!.isEmpty{
                    let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("No match found", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default) {  (UIAlertAction) -> Void in
                        self.dismissViewControllerAnimated(true, completion: { _ in })
                        })
                    
                    // show the alert
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.postList = []
                    for post in posts!{
                        NSLog("uri:" + post.photoURI!);
                    }
                    self.postList = posts
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView!.reloadData()
                        // scroll to top
                        self.collectionView!.contentOffset = CGPointMake(0, 0 - self.collectionView!.contentInset.top);
                    })
                }
            })
        }
        searchByAddrAction.enabled = false
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Golden Gate Bridge"
            textField.textAlignment=NSTextAlignment.Left;
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                searchByAddrAction.enabled = textField.text != ""
            }
        }
        
        
        alertController.addAction(searchByAddrAction)
        alertController.addAction(searchMyLocAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true) {}
    }
    
    func openBrowser(){
        let vc = CCCrawlViewController.sharedInstance()
        if let title = self.searchTitle {
          vc.query = title
        }
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background color
        let backgroundView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        backgroundView.backgroundColor = UIColor(white: 0.13, alpha: 0.8)
        self.view!.addSubview(backgroundView)
        
        let backgroundView2: UIView = UIView(frame: CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40))
        backgroundView2.backgroundColor = UIColor.blackColor()
        self.view!.addSubview(backgroundView2)
        
        //Title
        let titleLabel = UILabel(frame: CGRectMake(50, 0, self.view.frame.size.width - 100, 40))
        //        let titleText = category?.name
        titleLabel.text = self.searchTitle//NSLocalizedString((titleText?.uppercaseString)!, comment: (titleText)!)
        titleLabel.font = UIFont.systemFontOfSize(17)//UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
        titleLabel.textColor = .whiteColor()
        titleLabel.textAlignment = .Center
        self.view!.addSubview(titleLabel)
        
        //Back
        if (!shouldShowHint) {
            closeButton.frame = CGRectMake(0, 1, 40, 40)
            closeButton.setBackgroundImage(UIImage(named: "back.png"), forState: .Normal)
            closeButton.setBackgroundImage(UIImage(named: "back_highlight.png"), forState: .Highlighted)
            closeButton.addTarget(self, action: #selector(closeAction), forControlEvents: .TouchUpInside)
            view!.addSubview(closeButton)
        }

        
        //GPS
        let gpsButton = UIButton(frame: CGRectMake(self.view.frame.size.width - 40, 7, 27, 27))
        gpsButton.setBackgroundImage(UIImage(named: "geofence.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)), forState: .Normal)
        gpsButton.setBackgroundImage(UIImage(named: "geofence.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)).maskWithColor(UIColor(hex:0x41AFFF)), forState:.Highlighted)
        gpsButton.addTarget(self, action: #selector(gpsAction), forControlEvents: .TouchUpInside)
        self.view!.addSubview(gpsButton)
        if self.shouldShowHint {
            hintLabel = UITextView(frame: CGRectMake(self.view.frame.size.width / 8, self.view.frame.size.height - 50, self.view.frame.size.width / 8 * 6, 40))
            //        let titleText = category?.name
            hintLabel.text = NSLocalizedString("Select a photo to imitate!", comment: "")//NSLocalizedString((titleText?.uppercaseString)!, comment: (titleText)!)
            hintLabel.font = UIFont.systemFontOfSize(20)//UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
            hintLabel.textColor = .whiteColor()
            hintLabel.textAlignment = .Center
            hintLabel.layer.borderWidth = 1
            hintLabel.layer.zPosition = 1
            hintLabel.layer.cornerRadius = 17.0;
            
            hintLabel.layer.borderColor = UIColor.whiteColor().CGColor
            hintLabel.layer.backgroundColor = UIColor.blackColor().CGColor
            hintLabel.alpha = 0
            self.view!.addSubview(hintLabel)
        }
        
//        //GPS
//        let crawlButton = UIButton(frame: CGRectMake(self.view.frame.size.width - 40, 5, 30, 30))
//        crawlButton.setBackgroundImage(UIImage(named: "browser.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)), forState: .Normal)
//        crawlButton.setBackgroundImage(UIImage(named: "browser.png")?.imageWithInsets(UIEdgeInsetsMake(10, 10, 10, 10)).maskWithColor(UIColor(hex:0x41AFFF)), forState:.Highlighted)
//        crawlButton.addTarget(self, action: #selector(openBrowser), forControlEvents: .TouchUpInside)
//        self.view!.addSubview(crawlButton)

        
        //Collection
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 2
        collectionView = CCCollectionView(frame: CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40), collectionViewLayout: self.flowLayout)
        collectionView!.registerClass(CCCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = .clearColor()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        self.view!.addSubview(self.collectionView!)
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeAction))
        swipe.direction = .Right
        self.view!.addGestureRecognizer(swipe)
        

    }
    
    override func viewWillLayoutSubviews() {
        if (shouldShowHint) {
            let alertController = UIAlertController(title: NSLocalizedString("Hi, New User", comment: ""), message: NSLocalizedString("Let's take a photo using CopyCat", comment: "Are you enjoying this App?"), preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { (_) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
                self.hintLabel.alpha = 1
            }
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true) {}
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if self.postList != nil{
            return
        }
        
        startIndicator()
        CCNetUtil.searchUnsplash(self.searchTextField.text!, completion: { (postsNullable) in
            self.stopIndicator()
            var posts:[CCPost] = []
            if let _ = postsNullable {
                posts = postsNullable!
            }
            
            if posts.isEmpty{
                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("No match found", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Use Offline Photos", comment: ""), style: UIAlertActionStyle.Default) {  (UIAlertAction) -> Void in
                    let overlayImage = UIImage(named: "4_0.jpg")
                    
                    //Add to "Saved"
                    CCCoreUtil.addPhotoForTopCategory(overlayImage!)
                    
                    // show animation each time user re-enter categoryview
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.removeObjectForKey("isFirstTimeUser")
                    userDefault.synchronize()
                    
                    //create overlay view
                    let frame: CGRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
                    let overlayView = CCOverlayView(frame: frame, overImage: overlayImage!)
                    
                    //open camera
                    let AVCVC: AVCamViewController = AVCamViewController(overlayView: overlayView)
                    overlayView.delegate = AVCVC
                    self.presentViewController(AVCVC, animated: true, completion: {
                        AVCVC.setRefImage()
                    })
                })
                alert.addAction(UIAlertAction(title: NSLocalizedString("Try photo crawler", comment: ""), style: UIAlertActionStyle.Default) {  (UIAlertAction) -> Void in
                    self.openBrowser()
                })
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel) {  (UIAlertAction) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                })
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.postList = []
                
                for post in posts{
                    let uri = post.photoURI! as String
                    print("uri:" + uri);
                }
                self.postList = posts
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView!.reloadData()
                    self.collectionView!.setContentOffset(CGPointZero, animated: true)
                    
                    if self.postList?.count<10{
                        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            let alert = UIAlertController(title: NSLocalizedString("Too few results", comment: ""), message: NSLocalizedString("We can't find that in our high quality database", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                            
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Try photo crawler", comment: ""), style: UIAlertActionStyle.Default) {  (UIAlertAction) -> Void in
                                self.openBrowser()
                            })
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Nope", comment: ""), style: UIAlertActionStyle.Cancel) {  (UIAlertAction) -> Void in
                                alert.dismissViewControllerAnimated(false, completion: nil)
                            })

                            // show the alert
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        })
        
    }
    
}


// MARK: UICollectionViewDelegate

extension CCInspireCollectionViewController:UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //et url = self.postList![indexPath.row].photoURI!
        if let indexPath = collectionView.indexPathsForSelectedItems()?[0]{
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CCCollectionViewCell {
                let overlayImage = cell.imageView?.image
                
                // show animation each time user re-enter categoryview
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.removeObjectForKey("isFirstTimeUser")
                userDefault.synchronize()
                
                let detailedView = CCInspireDetailViewController(image: overlayImage!)
                detailedView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                detailedView.parent = self
                self.presentViewController(detailedView, animated: true, completion: { _ in })
                
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension CCInspireCollectionViewController:UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let list = self.postList{
            return list.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CCCollectionViewCell
        
        cell.backgroundColor = .clearColor()
        cell.initWithNetworkUrl(postList![indexPath.row].photoURI!)
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CCInspireCollectionViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 0, 0, 0);
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let len=(self.view.frame.size.width-4)/3.0;
        let retval = CGSizeMake(len, len);
        return retval;
    }
}



extension CCInspireCollectionViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationFound {
            return
        }
        guard let location = locations.first
            else {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Failed to get location", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    alert.show()
                })
                return
        }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        locationFound = true
        
        CCNetUtil.searchGPS(lat, lon: lon, completion: { (posts) in
            if posts.isEmpty{
                let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("No match found", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default) {  (UIAlertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: { _ in })
                    })
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.postList = []
                for post in posts{
                    NSLog("uri:" + post.photoURI!);
                }
                self.postList = posts
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView!.reloadData()
                    // scroll to top
                    self.collectionView!.contentOffset = CGPointMake(0, 0 - self.collectionView!.contentInset.top);
                })            }
        })
        // Stop location updates
        self.locationManager.stopUpdatingLocation()
    }
}