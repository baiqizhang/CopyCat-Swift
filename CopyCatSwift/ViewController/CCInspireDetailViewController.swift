//
//  CCInspireDetailViewController.swift
//  CopyCatSwift
//
//  Created by Cheng Wang on 7/10/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCInspireDetailViewController: UIViewController , UIScrollViewDelegate{

    
    private let closeButton = UIButton()
    private let cancelButton = UIButton()
    private let deleteButton = UIButton()
    private let flowLayout = UICollectionViewFlowLayout()
    private var imageView : UIImageView!
    
    private var photosToDelete = NSMutableArray()
    
    var presentedByVc: UIViewController?;
    
    init(image: UIImage){
        super.init(nibName: nil, bundle: nil)
        self.imageView = UIImageView(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init not implemented")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //background color
        let backgroundView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        backgroundView.backgroundColor = UIColor(white: 0.13, alpha: 0)
        self.view!.addSubview(backgroundView)
        
        let backgroundView2: UIView = UIView(frame: CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40))
        backgroundView2.backgroundColor = UIColor.blackColor()
        self.view!.addSubview(backgroundView2)
        
        imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let scrollView = UIScrollView();
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40)
        scrollView.contentSize = imageView.frame.size
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4
        scrollView.addSubview(imageView)
        self.view!.addSubview(scrollView)
        
        //let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        ///imageViewTopConstraint.constant = yOffset
        //imageViewBottomConstraint.constant = yOffset
        
        //let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        //imageViewLeadingConstraint.constant = xOffset
        //imageViewTrailingConstraint.constant = xOffset
        
        //view.layoutIfNeeded()
        
        //Close
        closeButton.frame = CGRectMake(0, 1, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "back.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "back_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(CCInspireDetailViewController.closeAction), forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        
        //Deleting
        cancelButton.frame = CGRectMake(0, self.view.frame.size.height - 50, 50, 50)
        cancelButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        cancelButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        cancelButton.addTarget(self, action: #selector(CCInspireDetailViewController.closeAction), forControlEvents: .TouchUpInside)
        view!.addSubview(cancelButton)
        
        deleteButton.frame = CGRectMake(view.frame.size.width - 45, self.view.frame.size.height - 50, 40, 40)
        deleteButton.setBackgroundImage(UIImage(named: "save.png"), forState: .Normal)
        deleteButton.setBackgroundImage(UIImage(named: "save_highlight.png"), forState: .Highlighted)
        deleteButton.addTarget(self, action: #selector(CCInspireDetailViewController.okForUse), forControlEvents: .TouchUpInside)
        view!.addSubview(deleteButton)
        
    }
    
    func okForUse() {
        let overlayImage = self.imageView.image
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
        self.presentViewController(AVCVC, animated: true, completion: { _ in })

    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
