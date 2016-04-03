//
//  CCInspireTableViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 1/2/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCInspireTableViewController : SKStatefulTableViewController {
    private var postList = [CCPost]()
    private var instagramPostList = [CCPost]()
    private var usingInstagram = false
    private var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Style
        view.backgroundColor = .blackColor()
        tableView.separatorStyle = .None
        tableView.backgroundColor = .blackColor()
        tableView.registerClass(CCInspireTableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.allowsSelection = false
        // Load data
        triggerInitialLoad()
    }
    
    func loadInstagramLikes(){
        CCNetUtil.loadInstagramLikes() { (posts) -> Void in
            self.postList = posts
            self.loading = false
            NSLog("postlist:%@\npostList.count:%d", self.postList, self.postList.count)

            self.usingInstagram = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top); // scroll to top

            })
        }
        
    }
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
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CCInspireTableViewCell
        
        if indexPath.row>=postList.count{
            return cell
        }
        
        let post = postList[indexPath.row]
        
        let uri = post.photoURI!//CCNetUtil.host + post.photoURI!
        
        cell.username = "Anonymous"
        cell.delegate = self
        cell.myImageURI = uri
        
        cell.pinCount = post.pinCount?.integerValue ?? 0
        cell.likeCount = post.likeCount?.integerValue ?? 0
        
        cell.timestamp = post.timestamp!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("rows:%d",postList.count)
        return postList.count
    }
    
    
    override func statefulTableViewControllerWillBeginInitialLoad(tvc: SKStatefulTableViewController!, completion: ((Bool, NSError!) -> Void)!) {
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
        if usingInstagram {
            completion(false, nil,false)
            return
        }
        CCNetUtil.loadMoreFeedForCurrentUser(self.postList.last!.id!, completion: { (posts) -> Void in
            var indexArray = [NSIndexPath]()
            var i = self.postList.count
            
            for post in posts{
                NSLog("uri:" + post.photoURI!);
                indexArray.append(NSIndexPath(forRow: i, inSection: 0))
                i++
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
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        NSLog("rows: %d of %d",indexPath.row,postList.count)
        // synchronization problem
        if indexPath.row>=postList.count{
            return 200
        }
        
        guard
            let height = postList[indexPath.row].photoHeight,
            let width = postList[indexPath.row].photoWidth
            where height > 0 && width > 0
            else {
                return 200.0
            }        
        let viewWidth = tableView.frame.width
        let newHeight : CGFloat = CGFloat(height) / CGFloat(width) * viewWidth
        return newHeight
    }
    
    // MARK: UI Action
    func pinAction(image : UIImage){
        let alertVC = CCAlertViewController(style: .CategoryList)
        alertVC.image = image
        alertVC.modalPresentationStyle = .OverCurrentContext
        alertVC.modalTransitionStyle = .CrossDissolve

        alertVC.parent = self
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func pinCompleted(){
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
    }
    
    func likeAction(){
    }
    

}
