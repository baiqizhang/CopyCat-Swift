//
//  CCPickOverlayViewController.swift
//  CopyCat
//
//  Created by Baiqi Zhang on 2/27/16.
//  Copyright © 2016 CopyCat Team. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class CCPickOverleyViewController:UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,DNImagePickerControllerDelegate{
    
    var imageCollectionView : UICollectionView?
    var categoryCollectionView : UICollectionView?
    
    let closeButton = UIButton()
    let settingsButton = UIButton()
    
    let galleryReuseIdentifier = "galleryCell"
    let categoryReuseIdentifier = "categoryCell"
    
    internal var delegate : AVCamViewController?
    
    var userAlbums : [CCCategory] = []
    static var lastIndex = 0
    static var lastImageIndex = 1
    static var currentIndex = 0
    
    
    var currentImage : UIImage? //set when initialized
    
    
    //Add image
    var waitingAssetsCount: Int?
    var waitingAssetsCountTotal: Int?
    
    convenience init(overlayImage:UIImage){
        self.init()
        currentImage = overlayImage
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Actions
    
    func rotateLeft(){
        guard self.imageCollectionView != nil
            else{
                return
            }
        
        let windowWidth = self.view.frame.size.width
        let windowHeight = self.view.frame.size.height
        
        let height = windowHeight - 140
        let width = windowWidth
        
        
        self.imageCollectionView?.transform = CGAffineTransformIdentity
        self.imageCollectionView?.frame = CGRectMake(-75.0/320*windowWidth, 125.0/568*windowHeight, height-15.0/320*windowWidth,width-55.0/568*windowHeight)
        self.imageCollectionView!.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2));
        
        self.categoryCollectionView?.transform = CGAffineTransformIdentity
        self.categoryCollectionView?.frame = CGRectMake(width/2-73.0/320*windowWidth, 20.0/568*windowHeight+height/2.0, height-12.0/320*windowWidth,40.0/568*windowHeight)
        self.categoryCollectionView!.transform=CGAffineTransformMakeRotation (CGFloat(-M_PI_2));
        
        self.closeButton.transform=CGAffineTransformMakeRotation (CGFloat(-M_PI_2));
    }
    
    func rotateRight(){
        guard self.imageCollectionView != nil
            else{
                return
        }
        let windowWidth = self.view.frame.size.width
        let windowHeight = self.view.frame.size.height
        
        let height = windowHeight - 140
        let width = windowWidth
        
        self.imageCollectionView?.transform = CGAffineTransformIdentity
        self.imageCollectionView?.frame = CGRectMake(-27.0/320*windowWidth, 122.0/568*windowHeight, height-15.0/320*windowWidth,width-55.0/568*windowHeight)
        self.imageCollectionView?.transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        
        
        self.categoryCollectionView?.transform = CGAffineTransformIdentity
        self.categoryCollectionView?.frame = CGRectMake(-width/2-27.0/320*windowWidth, 20.0/568*windowHeight+height/2.0, height-10.0/320*windowWidth,40.0/568*windowHeight)
        self.categoryCollectionView!.transform=CGAffineTransformMakeRotation (CGFloat(M_PI_2));
        
        self.closeButton.transform=CGAffineTransformMakeRotation (CGFloat(M_PI_2));
    }
    func rotateUpright(){
        guard self.imageCollectionView != nil
            else{
                return
        }
        
        let height = self.view.frame.size.height - 140
        let width = self.view.frame.size.width
        
        self.imageCollectionView?.transform = CGAffineTransformIdentity
        self.imageCollectionView?.frame = CGRectMake(0, 45, width, height-50)
        self.imageCollectionView?.transform=CGAffineTransformMakeRotation(0);
        
        self.categoryCollectionView?.transform = CGAffineTransformIdentity
        self.categoryCollectionView?.frame = CGRectMake(0, 40 + height - 40, width, 40)
        self.categoryCollectionView?.transform=CGAffineTransformMakeRotation (0.0);
        
        self.closeButton.transform=CGAffineTransformMakeRotation (CGFloat(0));
    }
    
    override func viewWillAppear(animated: Bool) {
        self.imageCollectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Frame
        var is1x: Bool = false
        if self.view.frame.size.height == 480 {
            is1x = true
        }
        var height: CGFloat
        var width: CGFloat
        var frame_gallery: CGRect
        var frame_category: CGRect
        if is1x {
            height = self.view.frame.size.height
            width = self.view.frame.size.width
            frame_gallery = CGRectMake(0, 0, width, height-40)
            frame_category = CGRectMake(0, height-40, width, 40)
        }
        else {
            height = self.view.frame.size.height - 140
            width = self.view.frame.size.width
            frame_gallery = CGRectMake(0, 45, width, height-50)
            frame_category = CGRectMake(0, 40 + height - 40, width, 40)
        }
        
        let bgView = UIView(frame: CGRectMake(0, 40, width, height))
        bgView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.5)
        view.addSubview(bgView)
        
        //grab categories
        userAlbums = CCCoreUtil.categories as NSArray as! [CCCategory]
        userAlbums.removeAtIndex(0)
        // userAlbums[0] = mergePhotoCategories(userAlbums) // deprecated
        NSLog("%@", userAlbums)
        
        //Close
        closeButton.frame = CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 80, 60, 70)
        closeButton.backgroundColor = UIColor(white: 0.13, alpha: 1)
        closeButton.setTitle("Cancel", forState: .Normal)
        closeButton.setTitleColor(.whiteColor(), forState: .Normal)
        closeButton.setTitleColor(UIColor(hexNumber:0x41AFFF), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(closeAction), forControlEvents: .TouchUpInside)
        self.view!.addSubview(closeButton)
        
        
        //Collection
        let imageFlowLayout = UICollectionViewFlowLayout()
        imageFlowLayout.minimumInteritemSpacing = 0
        imageFlowLayout.minimumLineSpacing = 4
        imageCollectionView = UICollectionView(frame: frame_gallery, collectionViewLayout: imageFlowLayout)
        imageCollectionView!.registerClass(CCCollectionViewCell.self, forCellWithReuseIdentifier: galleryReuseIdentifier)
        imageCollectionView!.backgroundColor = .clearColor()
        imageCollectionView!.delegate = self
        imageCollectionView!.dataSource = self
        self.view!.addSubview(self.imageCollectionView!)
        
        let categoryFlowLayout = UICollectionViewFlowLayout()
        categoryFlowLayout.minimumInteritemSpacing = 0
        categoryFlowLayout.minimumLineSpacing = 1
        categoryFlowLayout.scrollDirection = .Horizontal
        categoryCollectionView = UICollectionView(frame: frame_category, collectionViewLayout: categoryFlowLayout)
        categoryCollectionView!.registerClass(CCCategoryCollectionViewCell.self, forCellWithReuseIdentifier: categoryReuseIdentifier)
        categoryCollectionView!.backgroundColor = .blackColor()
        categoryCollectionView!.delegate = self
        categoryCollectionView!.dataSource = self
        
        self.view!.addSubview(self.categoryCollectionView!)
        
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(false, completion: nil)
        let overlayView = self.delegate?.overlayView as! CCOverlayView
        overlayView.setOverlayImage(currentImage!)
        overlayView.alpha = 1
        self.delegate?.cancelButton.alpha=1
    }
    
    
    // MARK: Add Image
    
    func addFromGallery() {
        if let count = waitingAssetsCount{
            if count != 0{
                return
            }
        }
        let imagePicker: DNImagePickerController = DNImagePickerController()
        imagePicker.imagePickerDelegate = self
        self.presentViewController(imagePicker, animated: true, completion: { _ in })
    }
    
    
    func dnImagePickerController(imagePicker: DNImagePickerController!, sendImages imageAssets: [AnyObject]!, isFullImage fullImage: Bool) {
        waitingAssetsCount = imageAssets.count
        waitingAssetsCountTotal = self.waitingAssetsCount
        
        imagePicker.dismissViewControllerAnimated(true) { () -> Void in
            let alertVC = CCAlertViewController(style: .ProgressBar)
            alertVC.modalPresentationStyle = .OverCurrentContext
            alertVC.modalTransitionStyle = .CrossDissolve
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            for item in imageAssets{
                let dnasset = item as! DNAsset
                let lib: ALAssetsLibrary = ALAssetsLibrary()
                lib.assetForURL(dnasset.url, resultBlock: { (asset : ALAsset!) -> Void in
                    let assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                    
                    let orientValueFromImage = asset.valueForProperty("ALAssetPropertyOrientation") as! NSNumber
                    let imageOrientation = UIImageOrientation(rawValue: orientValueFromImage.integerValue)!
                    
                    
                    let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    let image = UIImage(CGImage: iref, scale: 1, orientation: imageOrientation)
                    
                    self.waitingAssetsCount = self.waitingAssetsCount! - 1
                    
                    CCCoreUtil.addPhotoForCategory(self.userAlbums[CCPickOverleyViewController.currentIndex], image: image)
                    
                    alertVC.progress = CGFloat(self.waitingAssetsCountTotal! - self.waitingAssetsCount!) / CGFloat(self.waitingAssetsCountTotal!)
                    NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.01))
                    if self.waitingAssetsCount == 0 {
                        self.imageCollectionView!.reloadData()
                        alertVC.dismissViewControllerAnimated(true, completion: nil)
                    }
                    }, failureBlock: { (error:NSError!) -> Void in
                        NSLog("%@",error)
                })
            }
        }
    }
    
    func dnImagePickerControllerDidCancel(imagePicker: DNImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == imageCollectionView) {
            return self.userAlbums[CCPickOverleyViewController.currentIndex].photoList!.count
        } else {
            return self.userAlbums.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //upper collection view
        if (collectionView == imageCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(galleryReuseIdentifier, forIndexPath: indexPath) as! CCCollectionViewCell
            
            let photo = self.userAlbums[CCPickOverleyViewController.currentIndex].photoList![indexPath.row] as! CCPhoto
            
            cell.backgroundColor = .whiteColor()
            
            cell.initWithImagePath(photo.photoURI!, deleteFlag: 0)
            cell.delegate = self
            cell.coreData = photo
            
            cell.alpha = 0.9
            cell.backgroundColor = UIColor.clearColor()
            
            // highlight
            if indexPath.item == CCPickOverleyViewController.lastImageIndex &&
            CCPickOverleyViewController.currentIndex == CCPickOverleyViewController.lastIndex{
//                currentImage = cell.image()
                cell.pick()
            }

            return cell
        //lower collection view
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryReuseIdentifier, forIndexPath: indexPath) as! CCCategoryCollectionViewCell
            cell.categoryText.text = self.userAlbums[indexPath.row].name
            cell.categoryText.textAlignment = .Center
            if indexPath.row == CCPickOverleyViewController.currentIndex{
                cell.categoryText.textColor = UIColor(red: 65.0/255, green: 175.0/255, blue: 1, alpha: 1)
            } else {
                cell.categoryText.textColor = UIColor.whiteColor()
            }
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        //category
        if collectionView == self.categoryCollectionView{
            CCPickOverleyViewController.currentIndex = indexPath.item
            self.imageCollectionView!.reloadData()
            self.categoryCollectionView!.reloadData()
        //image
        } else {
            if indexPath.row == 0 {
                self.addFromGallery()
            } else {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CCCollectionViewCell
                
                let image : UIImage = cell.image()!
                CCPickOverleyViewController.lastImageIndex = indexPath.item
                CCPickOverleyViewController.lastIndex = CCPickOverleyViewController.currentIndex
                currentImage = image
                closeAction()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = imageCollectionView!.bounds.width
        if (collectionView == imageCollectionView){
            if collectionView.frame.width == self.view.frame.width{
                return CGSize(width: screenWidth/3-3, height: screenWidth/3-3)
            } else {
                return CGSize(width: collectionView.frame.height/4-4, height: collectionView.frame.height/4-4)
            }
        } else {
            return CGSize(width: 80, height: 40)
        }
    }
}