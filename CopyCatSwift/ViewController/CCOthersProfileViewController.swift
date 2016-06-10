//
//  CCProfileViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/28/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCOthersProfileViewController: UIViewController, UICollectionViewDelegate {
    var userID = ""
    var userName = ""
    var avatar = ""
    internal var category : CCCategory?
    let userImageView = UIImageView()
    private let closeButton = UIButton()
    private let cancelButton = UIButton()
    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView : CCCollectionView?
    private var postImageUrls: [String] = []

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
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
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "closeAction")
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

        // User Info
        let labelHeight : CGFloat = 11
        let offset : CGFloat = -2
        
        let posts = UILabel(frame:  CGRectMake(0, 40 + 2 * lineWidth + height/2 - labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        posts.text = CCUserManager.postCount.stringValue
        posts.textColor = .whiteColor()
        view.addSubview(posts)
        
        let postsLabel = UILabel(frame:  CGRectMake(0, 40 + 2 * lineWidth + height/2 + labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        postsLabel.text = NSLocalizedString("POSTS", comment: "Posts")
        postsLabel.textColor = .whiteColor()
        view.addSubview(postsLabel)

        let pins = UILabel(frame:  CGRectMake(view.frame.size.width/2 + lineWidth, 40 + 2 * lineWidth + height/2 - labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        pins.text = CCUserManager.pinCount.stringValue
        pins.textColor = .whiteColor()
        view.addSubview(pins)
        
        let pinsLabel = UILabel(frame:  CGRectMake(view.frame.size.width/2 + lineWidth, 40 + 2 * lineWidth + height/2 + labelHeight + offset, view.frame.size.width/2 - lineWidth, labelHeight))
        pinsLabel.text = NSLocalizedString("PINS", comment: "Pins")
        pinsLabel.textColor = .whiteColor()
        view.addSubview(pinsLabel)
        
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
        closeButton.addTarget(self, action: "closeAction", forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        print(self.userID)
        print(self.userName)
        
        CCNetUtil.loadImage(self.avatar) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else {
                    print(error)
                    return
                }
                self.userImageView.image = UIImage(data: data)

                UIView.animateWithDuration(0.3, animations: {
                    self.userImageView.alpha = 1
                })
                
            }
        }
        
        CCNetUtil.loadPostByUsername(self.userName, completion: {(images:[String]) -> Void in
            self.postImageUrls = images
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
            
        })

    }
}

// MARK: UICollectionViewDataSource

extension CCOthersProfileViewController:UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CCCollectionViewCell
        
        cell.backgroundColor = .whiteColor()
        cell.initWithNetworkUrl(postImageUrls[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let len=(self.view.frame.size.width-6)/3.0;
        let retval = CGSizeMake(len, len);
        return retval;
    }
}



