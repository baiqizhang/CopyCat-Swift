//
//  CCProfileViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/28/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCProfileViewController: UIViewController, CCPhotoCollectionManipulation {
    //data
    internal var category : CCCategory?
    
    //Buttons
    let userImageView = UIImageView()
    private let closeButton = UIButton()
    private let cancelButton = UIButton()
    private let deleteButton = UIButton()
    private var settingsButton = UIButton()
    let infoTextLabel = UILabel()
    
    //Layout
    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView : CCCollectionView?
    
    //Delete
    private var deleting = false
    private var photosToDelete = NSMutableArray()

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    func openSettings() {
        let vc = CCSettingsViewController()
        vc.modalTransitionStyle = .CrossDissolve
        presentViewController(vc, animated: true, completion: nil)
    }

    func onTapUser() {
        if CCCoreUtil.userType != 1{
            let vc = InstagramLoginViewController()
            vc.modalTransitionStyle = .CrossDissolve
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            let refreshAlert = UIAlertController(title: NSLocalizedString("INS_LOGOUT_TITLE", comment: "Logout"), message: NSLocalizedString("INS_LOGOUT_ALERT", comment: "You will no longer be able to sync instagram likes."), preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Logout"), style: .Default, handler: { (action: UIAlertAction!) in
                CCUserManager.instagramUserInfo = nil
                let url = NSURL(string: "http://instagram.com/accounts/logout")
                
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
//                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                }
                
                task.resume()
                self.viewWillAppear(false)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Logout"), style: .Default, handler: { (action: UIAlertAction!) in
                refreshAlert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background
        view!.backgroundColor = .blackColor()
        let backgroundView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        backgroundView.backgroundColor = UIColor(white: 0.13, alpha: 0.8)
        view!.addSubview(backgroundView)
        
        //Blocks
        let lineWidth:CGFloat = 1
        let height:CGFloat = 80.0
        
        let block1: UIView = UIView(frame: CGRectMake(0, 40 + 2 * lineWidth, self.view.frame.size.width/2 - lineWidth, height))
        block1.backgroundColor = UIColor(white: 0.13, alpha: 0.8)
        view!.addSubview(block1)

        let block2: UIView = UIView(frame: CGRectMake(self.view.frame.size.width/2 + lineWidth, 40 + 2 * lineWidth, self.view.frame.size.width/2 - lineWidth, height))
        block2.backgroundColor = UIColor(white: 0.13, alpha: 0.8)
        view!.addSubview(block2)
        
        //Collection
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 2
        collectionView = CCCollectionView(frame: CGRectMake(0, 40 + 2 * lineWidth + height, self.view.frame.size.width, self.view.frame.size.height - 40 - 2 * lineWidth - height), collectionViewLayout: self.flowLayout)
        collectionView!.registerClass(CCCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = .clearColor()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        self.view!.addSubview(self.collectionView!)
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CCProfileViewController.closeAction))
        swipe.direction = .Right
        self.view!.addGestureRecognizer(swipe)
        
        // User ImageView
        let size:CGFloat = 70.0
        let image = UIImage(named: "AppIcon.png")
        userImageView.frame = CGRectMake(self.view.frame.size.width/2 - size/2, 40 + height/2, size, size)
        userImageView.image = image
        userImageView.layer.borderWidth = 1.0
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = UIColor.blackColor()
        view!.addSubview(userImageView)
        
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CCProfileViewController.onTapUser)))

        // User Info
        let labelHeight : CGFloat = 11
        let offset : CGFloat = -2
        let fontSize:CGFloat = 12.0
        
        let posts = UILabel(frame:  CGRectMake(0, 40 + 2 * lineWidth + height/2 - labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        posts.text = CCUserManager.postCount.stringValue
        posts.textColor = .whiteColor()
        posts.font = UIFont.systemFontOfSize(fontSize)
        posts.textAlignment = .Center
        view.addSubview(posts)
        
        let postsLabel = UILabel(frame:  CGRectMake(0, 40 + 2 * lineWidth + height/2 + labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        postsLabel.text = NSLocalizedString("POSTS", comment: "Posts")
        postsLabel.textColor = .whiteColor()
        postsLabel.font = UIFont.systemFontOfSize(fontSize)
        postsLabel.textAlignment = .Center
        view.addSubview(postsLabel)

        let pins = UILabel(frame:  CGRectMake(view.frame.size.width/2 + lineWidth, 40 + 2 * lineWidth + height/2 - labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        pins.text = CCUserManager.pinCount.stringValue
        pins.textColor = .whiteColor()
        pins.font = UIFont.systemFontOfSize(fontSize)
        pins.textAlignment = .Center
        view.addSubview(pins)
        
        let pinsLabel = UILabel(frame:  CGRectMake(view.frame.size.width/2 + lineWidth, 40 + 2 * lineWidth + height/2 + labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        pinsLabel.text = NSLocalizedString("PINS", comment: "Pins")
        pinsLabel.textColor = .whiteColor()
        pinsLabel.font = UIFont.systemFontOfSize(fontSize)
        pinsLabel.textAlignment = .Center
        view.addSubview(pinsLabel)
        
        
        //Settings
        settingsButton = UIButton(frame: CGRectMake(view.frame.size.width - 45, 0, 40, 40))
        settingsButton.setBackgroundImage(UIImage(named: "settings2.png"), forState: .Normal)
        settingsButton.setBackgroundImage(UIImage(named: "settings2_highlight.png"), forState: .Highlighted)
        settingsButton.addTarget(self, action: #selector(CCProfileViewController.openSettings), forControlEvents: .TouchUpInside)
        view.addSubview(self.settingsButton)
        
        //Title
        let titleLabel: CCLabel = CCLabel(frame: CGRectMake(50, -1, self.view.frame.size.width - 100, 40))
        titleLabel.text = NSLocalizedString("PROFILE", comment: "Profile")
        titleLabel.font = UIFont(name: NSLocalizedString("Font", comment : "Georgia"), size: 20.0)
        titleLabel.textColor = .whiteColor()
        titleLabel.textAlignment = .Center
        self.view!.addSubview(titleLabel)
        
        //Close
        closeButton.frame = CGRectMake(0, 0, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(CCProfileViewController.closeAction), forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        
        //Deleting
        cancelButton.frame = CGRectMake(0, -5, 50, 50)
        cancelButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        cancelButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        cancelButton.addTarget(self, action: #selector(CCProfileViewController.finishDelete), forControlEvents: .TouchUpInside)
        view!.addSubview(cancelButton)
        
        deleteButton.frame = CGRectMake(view.frame.size.width - 45, 0, 40, 40)
        deleteButton.setBackgroundImage(UIImage(named: "delete.png"), forState: .Normal)
        deleteButton.setBackgroundImage(UIImage(named: "delete_highlight.png"), forState: .Highlighted)
        deleteButton.addTarget(self, action: #selector(CCProfileViewController.performDelete), forControlEvents: .TouchUpInside)
        view!.addSubview(deleteButton)
        
        cancelButton.alpha = 0
        deleteButton.alpha = 0
        
        //info label
        infoTextLabel.frame = CGRectMake(0, view.frame.size.height/2-100, view.frame.size.width, 200)
        infoTextLabel.textAlignment = .Center
        infoTextLabel.textColor = UIColor.whiteColor()
        infoTextLabel.font = UIFont.systemFontOfSize(14)
        infoTextLabel.numberOfLines = 0
        infoTextLabel.text = "No photo in your album"//"Press CopyCat logo to login with Instagram\n\nNo photo in your album\n"
        view!.addSubview(infoTextLabel)

    }
    
    override func viewWillAppear(animated: Bool) {
        // load profile image
        NSLog("user type = \(CCCoreUtil.userType)")
        switch CCCoreUtil.userType {
        case 1:
            userImageView.image = CCCoreUtil.userPicture
            break
        default:
            userImageView.image = UIImage(named: "AppIcon.png")
        }
        
        // load user data
        category = CCCoreUtil.categories[0] as? CCCategory
        collectionView?.reloadData()
        
        // show hint text
        if category == nil || category!.photoList == nil || category!.photoList!.count == 0{
            infoTextLabel.alpha = 1
        } else {
            infoTextLabel.alpha = 0
        }

    }
    
    // MARK: Delete
    func prepareDelete() {
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.cancelButton.alpha = 1
            self.deleteButton.alpha = 1
            self.closeButton.alpha = 0
            self.settingsButton.alpha = 0
        })
        self.deleting = true
    }
    
    func finishDelete() {
        collectionView!.reloadData()
        
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.cancelButton.alpha = 0
            self.deleteButton.alpha = 0
            self.closeButton.alpha = 1
            self.settingsButton.alpha = 1
        })
        self.deleting = false
        
        self.photosToDelete = NSMutableArray()
    }
    
    func performDelete() {
        for item in self.photosToDelete {
            let photo = item as! CCPhoto
            CCCoreUtil.removePhotoForCategory(category!, photo: photo)
        }
        
        finishDelete()
    }
    
    func prepareDeleteCell(cell: CCCollectionViewCell) {
        let photo = cell.coreData as! CCPhoto
        photosToDelete.addObject(photo)
    }
    
    func cancelDeleteCell(cell: CCCollectionViewCell) {
        let photo = cell.coreData as! CCPhoto
        photosToDelete.removeObject(photo)
    }

}



// MARK: UICollectionViewDataSource

extension CCProfileViewController:UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = category?.photoList?.count{
            return count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CCCollectionViewCell
        let photo = category!.photoList![indexPath.row] as! CCPhoto
        
        cell.backgroundColor = .whiteColor()
        cell.initWithImagePath(photo.photoURI!, deleteFlag: 0)
        cell.delegate = self
        cell.coreData = photo
        
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension CCProfileViewController:UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !self.deleting{
            let browser = CCPhotoBrowser(photos: ((category?.mutableOrderedSetValueForKey("photoList").array)! as NSArray).mutableCopy() as! NSMutableArray, currentIndex: indexPath.row) //difference : without "-1"
            browser.delegate = self
            browser.category = category
            browser.modalTransitionStyle = .CrossDissolve
            self.presentViewController(browser, animated: false, completion: { _ in })
        } else {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CCCollectionViewCell
            if cell.flip(){
                prepareDeleteCell(cell)
            } else {
                cancelDeleteCell(cell)
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CCProfileViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 0, 0, 0);
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let len=(self.view.frame.size.width-6)/4.0;
        let retval = CGSizeMake(len, len);
        return retval;
    }
}
