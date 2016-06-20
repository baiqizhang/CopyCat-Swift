//
//  CCInspireTableViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 1/2/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit
import MapKit
import Fabric
import Crashlytics


class CCInspireTableViewController : SKStatefulTableViewController {
    private var postList = [CCPost]()
    private var instagramPostList = [CCPost]()
    private var usingInstagram = false
    private var loading = false
    
    private var reportURI = ""
    private var reporterID = ""
        
    private var pinedId = ""
    
    private let locationManager = CLLocationManager()
    private var locationFound = false
    var indicatorView = UIView()
    
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
    
    
    // MARK: UI Action
    func pinAction(image : UIImage, _ imageUri: String){
        let alertVC = CCAlertViewController(style: .CategoryList)
        alertVC.image = image
        alertVC.modalPresentationStyle = .OverCurrentContext
        alertVC.modalTransitionStyle = .CrossDissolve
        
        alertVC.parent = self
        presentViewController(alertVC, animated: true, completion: nil)
        self.pinedId = imageUri.substringFromIndex((imageUri.rangeOfString("com/")?.endIndex)!)
    }
    
    func pinCompleted(){
        CCUserManager.pinCount = CCUserManager.pinCount.integerValue + 1
        let notifyLabel: UILabel = UILabel(frame: CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 + 150, 200, 30))
        notifyLabel.text = "Photo pinned"
        notifyLabel.textColor = UIColor.whiteColor()
        notifyLabel.backgroundColor = UIColor.blackColor()
        notifyLabel.alpha = 0
        self.parentViewController!.view!.addSubview(notifyLabel)
        UIView.animateWithDuration(0.3, animations: {() -> Void in
            notifyLabel.alpha = 1
            }, completion: {(finished: Bool) -> Void in
                UIView.animateWithDuration(0.3, delay: 1, options: .BeginFromCurrentState, animations: {() -> Void in
                    notifyLabel.alpha = 0
                    }, completion: {(finished: Bool) -> Void in
                        notifyLabel.removeFromSuperview()
                })
        })
        // notify server througn POST: /photo/like {photoId, userId}CC
        CCNetUtil.sendPin(CCCoreUtil.userDefault.stringForKey("cc_id")!, imageId: self.pinedId)
    }
    
    func likeAction(){
    }
    
    func moreAction(reportImageURI:String, reporterID:String){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Report", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            // NOTE: maxCount = 0 to hide count
            let popupTextView = YIPopupTextView(placeHolder: "Please provide the reason for reporting the content.", maxCount: 500, buttonStyle: YIPopupTextViewButtonStyle.RightCancelAndDone)
            popupTextView.delegate = self
            popupTextView.caretShiftGestureEnabled = true
            // default = NO
            popupTextView.text = ""
            
            self.reportURI = reportImageURI
            self.reporterID = reporterID
            popupTextView.showInViewController(self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        //show Menu
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func showProfileAction(userId: String, _ userName: String, _ avatar: String) {
        let otherProfile = CCOthersProfileViewController()
        otherProfile.userID = userId
        otherProfile.userName = userName
        otherProfile.avatar = avatar
        self.presentViewController(otherProfile, animated: true, completion: nil)
    }

    func loadInstagramLikes(){
        CCNetUtil.loadInstagramLikes() { (posts) -> Void in
            self.postList = posts
            self.loading = false
            NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
            
            self.usingInstagram = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                // scroll to top
                self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
            })
        }
        
    }
    
    
    //geo search
    internal func gpsAction(){
        let alertController = UIAlertController(title: "Geo-search", message: "", preferredStyle: .Alert)
        
        let searchMyLocAction = UIAlertAction(title: "Search Nearby", style: .Default) { (_) in
            self.startIndicator()

            //start tracking gps
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.locationFound = false
            
        }
        
        let searchByAddrAction = UIAlertAction(title: "Search By Address", style: .Default) { (_) in
            self.startIndicator()

            
            let addrTextField = alertController.textFields![0] as UITextField
            CCNetUtil.searchGPSByAddressString(addrTextField.text!, completion: { (posts) in
                print(posts)
                self.stopIndicator()
                
                if posts.isEmpty{
                    let alert = UIAlertView(title: "Error", message: "No match found", delegate: self, cancelButtonTitle: "OK")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.show()
                    })
                } else {
                    self.postList = []
                    for post in posts{
                        NSLog("uri:" + post.photoURI!);
                    }
                    self.postList = posts
                    self.loading = false
                    NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        // scroll to top
                        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
                    })
                }
            })
        }
        searchByAddrAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
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

    
    //image search
    internal func searchAction(){
        let alertController = UIAlertController(title: "Search Image", message: "", preferredStyle: .Alert)

        let searchAction = UIAlertAction(title: "Search", style: .Default) { (_) in
            let tagTextField = alertController.textFields![0] as UITextField
            print(tagTextField.text)
            self.startIndicator()
            
            
            CCNetUtil.searchUnsplash(tagTextField.text!, completion: { (posts) in
                print(posts)
                self.stopIndicator()

                if posts.isEmpty{
                    let alert = UIAlertView(title: "Error", message: "No match found", delegate: self, cancelButtonTitle: "OK")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.show()
                    })
                } else {
                    self.postList = []
                    
                    for post in posts{
                        let uri = post.photoURI! as String
                        print("uri:" + uri);
                    }
                    self.postList = posts
                    self.loading = false

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            })
        }
        searchAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        //enable search only if tag is present
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "e.g. sea shore"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                searchAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true) {
            
        }
    }
    /*
    internal func instaAction(){
        if CCCoreUtil.userType != 1{
            let refreshAlert = UIAlertController(title: "Login", message: "Please login via Instagram to sync instagram likes.", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                let vc = InstagramLoginViewController()
                vc.modalTransitionStyle = .CrossDissolve
                self.presentViewController(vc, animated: true, completion: nil)
                //                refreshAlert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                //                refreshAlert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
            return
        }
        
        if loading{
            return
        }
        usingInstagram = !usingInstagram
        loading = true
        
        if usingInstagram{
            loadInstagramLikes()
        } else {
            self.postList = []
            CCNetUtil.getFeedForCurrentUser { (posts) -> Void in
                for post in posts{
                    NSLog("uri:" + post.photoURI!);
                }
                self.postList = posts
                self.loading = false
                NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }*/

    // MARK: UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Style
        view.backgroundColor = .grayColor()
        tableView.separatorStyle = .None
        tableView.backgroundColor = .grayColor()
        tableView.registerClass(CCInspireTableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.allowsSelection = false
        // Load data
        triggerInitialLoad()
    }
    
    // MARK: TableView delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // separate cells with empty cellView
        let CELL_EMPTY = "EMPTY_CELL"
        if indexPath.row % 2 == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier(CELL_EMPTY)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_EMPTY)
                cell!.contentView.alpha = 0
                cell!.backgroundColor = .clearColor()
                cell!.userInteractionEnabled = false
            }
            return cell!
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CCInspireTableViewCell

        if indexPath.row >= postList.count * 2 - 1{
            return cell
        }

        let post = postList[indexPath.row / 2]
        
        let uri = post.photoURI!//CCNetUtil.host + post.photoURI!
        
        if let name = post.userName{
            cell.username = name
        } else {
            cell.username = "Anonymous User"
        }
        
        if let uri = post.userProfileImage{
            cell.userImageURI = uri
        }
        
        cell.delegate = self
        cell.myImageURI = uri
        
        cell.pinCount = post.pinCount?.integerValue ?? 0
        cell.likeCount = post.likeCount?.integerValue ?? 0
        
        cell.userID = post.userID ?? "0"
        cell.timestamp = post.timestamp!
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        NSLog("rows: %d of %d",indexPath.row,postList.count)
        // synchronization problem
        if indexPath.row >= postList.count * 2 - 1 {
            return 200
        }

        // separate cells with empty cellView
        if indexPath.row % 2 == 1 {
            return 10
        }

        let postIndex = indexPath.row / 2
        guard
        let height = postList[postIndex].photoHeight,
        let width = postList[postIndex].photoWidth
        where height > 0 && width > 0
        else {
            return 200.0
        }
        let viewWidth = tableView.frame.width
        let newHeight : CGFloat = CGFloat(height) / CGFloat(width) * viewWidth + 10
        return newHeight
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("rows:%d",postList.count)
        return postList.count * 2 - 1
    }
    
    // Load for the 1st time
    override func statefulTableViewControllerWillBeginInitialLoad(tvc: SKStatefulTableViewController!, completion: ((Bool, NSError!) -> Void)!) {
        //Logging
        Answers.logContentViewWithName("Inspire",
                                       contentType: "ViewPage",
                                       contentId: nil,
                                       customAttributes: nil)
        CCNetUtil.getFeedForCurrentUser { (posts) -> Void in
            for post in posts{
                NSLog("uri:" + post.photoURI!);
            }
            self.postList += posts
            NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                tvc.tableView.reloadData()
                completion(self.postList.count == 0, nil)
            })
        }
    }
    
    override func statefulTableViewControllerWillBeginLoadingFromPullToRefresh(tvc: SKStatefulTableViewController!, completion: ((Bool, NSError!) -> Void)!) {
        self.refreshControl?.endRefreshing()
        completion(false, nil)
        return
        
        // no longer use instagram like sync
        if usingInstagram {
            completion(false, nil)
            return
        }
        
        CCNetUtil.refreshFeedForCurrentUser(self.postList[0].id!, completion: { (posts) -> Void in
            for post in posts{
                NSLog("uri:" + post.photoURI!);
            }
            self.postList = posts + self.postList
            NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                tvc.tableView.reloadData()
                completion(self.postList.count == 0, nil)
            })
        })
    }
    
    override func statefulTableViewControllerWillBeginLoadingMore(tvc: SKStatefulTableViewController!, completion: ((Bool, NSError!, Bool) -> Void)!) {
        //Logging
        Answers.logContentViewWithName("Inspire",
                                       contentType: "LoadMore",
                                       contentId: nil,
                                       customAttributes: nil)

        if usingInstagram {
            completion(false, nil,false)
            return
        }
        NSLog("loading more")
        CCNetUtil.loadMoreFeedForCurrentUser(self.postList.last!.id!, completion: { (posts) -> Void in
            var indexArray = [NSIndexPath]()
            var i = self.postList.count * 2 - 1
            
            for post in posts{
                NSLog("uri:" + post.photoURI!);
                indexArray.append(NSIndexPath(forRow: i, inSection: 0))
                i += 1
                indexArray.append(NSIndexPath(forRow: i, inSection: 0))
                i += 1
            }
            self.postList += posts
            NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                tvc.tableView.beginUpdates()
                tvc.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: UITableViewRowAnimation.Fade)
                tvc.tableView.endUpdates()
                completion(posts.count != 0, nil,false)
            })
        })
    }
    
    
}


extension CCInspireTableViewController : YIPopupTextViewDelegate{
    func popupTextView(textView: YIPopupTextView, willDismissWithText text: String, cancelled: Bool) {
        if !cancelled {
            let reportContent = textView.text!
            
            if let range = self.reportURI.rangeOfString("com/") {
                let pos = range.endIndex
                let photoId = self.reportURI.substringFromIndex(pos)
                CCNetUtil.sendReport(photoId, userId: self.reporterID, content: reportContent, completion: {(error: String?) in
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        let notifyLabel: UILabel = UILabel(frame: CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 + 150, 200, 30))
                        notifyLabel.textColor = UIColor.whiteColor()
                        notifyLabel.backgroundColor = UIColor.blackColor()
                        notifyLabel.alpha = 0
                        self.parentViewController!.view!.addSubview(notifyLabel)
                        
                        if (error != nil) {
                            notifyLabel.text = "Network failure"
                        } else {
                            notifyLabel.text = "Content reported"
                        }
                        
                        UIView.animateWithDuration(0.3, animations: {() -> Void in
                            notifyLabel.alpha = 1
                            }, completion: {(finished: Bool) -> Void in
                                UIView.animateWithDuration(0.3, delay: 1, options: .BeginFromCurrentState, animations: {() -> Void in
                                    notifyLabel.alpha = 0
                                    }, completion: {(finished: Bool) -> Void in
                                        notifyLabel.removeFromSuperview()
                                })
                        })
                    })
                    
                })
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
}



extension CCInspireTableViewController : UIAlertViewDelegate{
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        print(buttonIndex)
    }
}


extension CCInspireTableViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationFound {
            return
        }
        guard let location = locations.first
        else {
            let alert = UIAlertView(title: "Error", message: "Failed to get location", delegate: self, cancelButtonTitle: "OK")
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
                let alert = UIAlertView(title: "Error", message: "No match found", delegate: self, cancelButtonTitle: "OK")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    alert.show()
                })
            } else {
                self.postList = []
                for post in posts{
                    NSLog("uri:" + post.photoURI!);
                }
                self.postList = posts
                self.loading = false
                NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)
                
                
                self.stopIndicator()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    // scroll to top
                    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
                })
            }
        })
        // Stop location updates
        self.locationManager.stopUpdatingLocation()
    }
}