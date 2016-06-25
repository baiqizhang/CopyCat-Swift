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
    var currentIndex = 0
    var currentImageIndex = 0
    var currentImage = UIImage(named: "AppIcon.png")
    
    
    //Add image
    var waitingAssetsCount: Int?
    var waitingAssetsCountTotal: Int?
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        
        
        //grab categories
        userAlbums = CCCoreUtil.categories as NSArray as! [CCCategory]
        NSLog("%@", userAlbums)
        
        //Close
        closeButton.frame = CGRectMake(0, 1, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(CCCategoryViewController.closeAction), forControlEvents: .TouchUpInside)
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
                    
                    CCCoreUtil.addPhotoForCategory(self.userAlbums[self.currentIndex], image: image)
                    
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
            return self.userAlbums[currentIndex].photoList!.count
        } else {
            return self.userAlbums.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //upper collection view
        if (collectionView == imageCollectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(galleryReuseIdentifier, forIndexPath: indexPath) as! CCCollectionViewCell
            
            let photo = self.userAlbums[currentIndex].photoList![indexPath.row] as! CCPhoto
            
            cell.backgroundColor = .whiteColor()
            
            cell.initWithImagePath(photo.photoURI!, deleteFlag: 0)
            cell.delegate = self
            cell.coreData = photo
            
            if indexPath.item == currentImageIndex{
                currentImage = cell.image()
            }
            
            cell.alpha = 0.8
            cell.backgroundColor = UIColor.clearColor()
            
            return cell
        //lower collection view
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryReuseIdentifier, forIndexPath: indexPath) as! CCCategoryCollectionViewCell
            cell.categoryText.text = self.userAlbums[indexPath.row].name
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        if collectionView == self.categoryCollectionView{
            currentIndex = indexPath.item
            self.imageCollectionView!.reloadData()
        } else {
            if indexPath.row == 0 {
                self.addFromGallery()
            } else {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CCCollectionViewCell
                
                let image : UIImage = cell.image()!
                currentImageIndex = indexPath.item
                currentImage = image
                
                //            cell.flip()
                //self.imageCollectionView!.reloadData()
                closeAction()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = imageCollectionView!.bounds.width
        if (collectionView == imageCollectionView){
            return CGSize(width: screenWidth/3-3, height: screenWidth/3-3)
        } else {
            return CGSize(width: screenWidth/4-1, height: 40)
        }
    }
}