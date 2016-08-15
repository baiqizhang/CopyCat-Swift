//
//  CCPreviewViewController.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/20/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit
import CoreMotion
import AssetsLibrary
import Fabric
import Crashlytics
import EggsBenedict

class CCPreviewViewController : UIViewController {
    
    var delegate: AnyObject?
    var image: UIImage?
    var refImage: UIImage?
    var imageView: UIImageView?
    var refImageView: UIImageView?
    let sharingFlow = SharingFlow(type: .IGOExclusivegram)
    
    var isShowingRef: Bool = false
    
    enum ToggleButton {
        case SharingOrigin
        case SharingToken
    }
    
    var acceptButton: UIButton?
    var instagramButton: UIButton?
    var cancelButton: UIButton?
    var flipButton: UIButton?
    var shareTaken: UIButton?
    var shareOrigin: UIButton?
    var refOrientation: Float = 0
    
    var _sharingOrigin = false
    var sharingOrigin: Bool {
        set{
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if newValue {
                    self.shareOrigin?.backgroundColor = UIColor.whiteColor()
                    self.shareOrigin?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                } else {
                    self.shareOrigin?.backgroundColor = UIColor.grayColor()
                    self.shareOrigin?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
            }
            self._sharingOrigin = newValue
        }
        get{
            return self._sharingOrigin
        }
    }
    
    var _sharingTaken = false
    var sharingTaken: Bool {
        set{
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if newValue {
                    self.shareTaken?.backgroundColor = UIColor.whiteColor()
                    self.shareTaken?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                } else {
                    self.shareTaken?.backgroundColor = UIColor.grayColor()
                    self.shareTaken?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
            }
            self._sharingTaken = newValue
        }
        get{
            return self._sharingTaken
        }
    }
    
    var motionManager: CMMotionManager?
    var imageOrientation = 0
    var orientation = 0
    var ratio1: CGFloat = 0
    var ratio2: CGFloat = 0
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Actions
    
    func shareInstaAction() {
        if sharingFlow.hasInstagramApp {
            sharingFlow.presentOpenInMenuWithImage(self.image, inView: self.view)
        } else {
            let alert = UIAlertView(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("Instagram Not Found", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            alert.show()
        }
    }
    
    func toggleSharingOrigin() {
        self.sharingOrigin = !self.sharingOrigin
    }
    func toggleSharingToken() {
        self.sharingTaken = !self.sharingTaken
    }
    
    func saveImage() {
        
        let vc = self.delegate as! AVCamViewController
        vc.libraryButton.enabled = false
        vc.stillButton.enabled = false
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            let image = self.image
            let tmImage = image?.thumbnailWithFactor(200)
            dispatch_async(dispatch_get_main_queue(), {
                vc.libraryButton.setBackgroundImage(tmImage, forState: .Normal)
            })
            if CCCoreUtil.isSaveToCameraRoll == 1 {
                // TODO warning message
                ALAssetsLibrary().writeImageToSavedPhotosAlbum(image?.CGImage, orientation: ALAssetOrientation.init(rawValue: (image?.imageOrientation.rawValue)!)!, completionBlock: nil)
            }
            
            CCCoreUtil.addUserPhoto(image!, refImage: self.refImage!)
            
            dispatch_async(dispatch_get_main_queue(), {
                vc.libraryButton.enabled = true
                vc.stillButton.enabled = true
                
                if let _ = CCCoreUtil.userDefault.stringForKey("photo_saved"){
                } else {
                    CCCoreUtil.userDefault.setObject("true", forKey: "photo_saved")
                    let alert = UIAlertView(title: NSLocalizedString("Note", comment: ""), message: NSLocalizedString("Photo Saved to Camera Roll", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                    alert.show()
                }
            })
        })
        
        if sharingTaken {
            CCNetUtil.newPost(self.image!, completion: { (error:String?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("Token Image Uploaded")
                })
            })
        }
        
        if sharingOrigin {
            let resetImage = self.refImage!.rotateInDegrees(-self.refOrientation)
            CCNetUtil.newPost(resetImage, completion: { (error:String?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("Origin Image Uploaded")
                })
            })
        }
        
        self.dismissSelf()
    }
    
    
    func dismissSelf() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func onFlipPress() {
        UIView.animateWithDuration(0.1, animations: {
            self.imageView?.alpha = 0
            self.refImageView?.alpha = 1
        })
    }
    
    func onFlipRelease() {
        UIView.animateWithDuration(0.1, animations: {
            self.imageView?.alpha = 1
            self.refImageView?.alpha = 0
        })
    }
    
    //MARK: Lifecycle
    
    init(image: UIImage, withReferenceImage refImage: UIImage, orientation: Int, refOrientation: Float) {
        super.init(nibName: nil, bundle: nil)
        self.refOrientation = refOrientation
        self.image = image
        self.refImage = refImage
        self.imageOrientation = orientation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        //Logging
        Answers.logContentViewWithName("Camera",
                                       contentType: "TakePhoto",
                                       contentId: nil,
                                       customAttributes: nil)
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
        
        let windowWidth = view.frame.size.width
        let windowHeight = view.frame.size.height
        
        
        // Rotation
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 0.1
        self.orientation = 0
        
        self.cancelButton = UIButton(frame: CGRectMake(20.0/320*windowWidth, self.view.frame.size.height - 70.0/568*windowHeight, 55, 55))
        self.cancelButton?.addTarget(self, action: #selector(CCPreviewViewController.dismissSelf), forControlEvents: .TouchUpInside)
        self.cancelButton?.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        self.cancelButton?.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        self.view.addSubview(self.cancelButton!)
        
        self.acceptButton = UIButton(frame: CGRectMake(95.0/320*windowWidth, self.view.frame.size.height - 70.0/568*windowHeight, 55, 55))
        self.acceptButton?.addTarget(self, action:#selector(CCPreviewViewController.saveImage), forControlEvents:.TouchUpInside)
        self.acceptButton?.setBackgroundImage(UIImage(named: "check.png"), forState: .Normal)
        self.acceptButton?.setBackgroundImage(UIImage(named: "check_highlight.png"), forState: .Highlighted)
        self.view.addSubview(self.acceptButton!)
        
        self.instagramButton = UIButton(frame: CGRectMake(170.0/320*windowWidth, self.view.frame.size.height - 70.0/568*windowHeight, 55, 55))
        self.instagramButton?.addTarget(self, action:#selector(CCPreviewViewController.shareInstaAction), forControlEvents:.TouchUpInside)
        self.instagramButton?.setBackgroundImage(UIImage(named: "instagram_slim.png"), forState: .Normal)
        self.instagramButton?.setBackgroundImage(UIImage(named: "instagram_slim.png")?.maskWithColor(UIColor(hex:0x41AFFF)), forState:.Highlighted)
        self.view.addSubview(self.instagramButton!)
        
        self.flipButton = UIButton(frame: CGRectMake(245.0/320*windowWidth, self.view.frame.size.height - 70.0/568*windowHeight, 55, 55))
        self.flipButton?.addTarget(self, action: #selector(CCPreviewViewController.onFlipPress), forControlEvents: .TouchDown)
        self.flipButton?.addTarget(self, action: #selector(CCPreviewViewController.onFlipRelease), forControlEvents: .TouchUpInside)
        self.flipButton?.addTarget(self, action: #selector(CCPreviewViewController.onFlipRelease), forControlEvents: .TouchUpOutside)
        self.flipButton?.setBackgroundImage(UIImage(named: "flip2.png"), forState: .Normal)
        self.flipButton?.setBackgroundImage(UIImage(named: "flip2.png")?.maskWithColor(UIColor(hex:0x41AFFF)), forState:.Highlighted)
        self.view.addSubview(self.flipButton!)
        
        // Share checkbox
        self.shareOrigin = UIButton(frame: CGRectMake(40, 3, 120, 34))
        self.shareOrigin!.setTitle(NSLocalizedString("Original", comment: ""), forState: .Normal)
        self.shareOrigin!.addTarget(self, action: #selector(CCPreviewViewController.toggleSharingOrigin), forControlEvents: .TouchUpInside)
        self.shareOrigin!.layer.cornerRadius = 5
        self.shareOrigin!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.shareOrigin!.backgroundColor = UIColor.whiteColor()
        self.shareOrigin!.setTitleColor(UIColor(hex:0x1D62F0), forState: .Highlighted)
//        self.view.addSubview(self.shareOrigin!)
        
        self.shareTaken = UIButton(frame: CGRectMake(180, 3, 120, 34))
        self.shareTaken!.setTitle(NSLocalizedString("Current One", comment: ""), forState: .Normal)
        self.shareTaken!.addTarget(self, action: #selector(CCPreviewViewController.toggleSharingToken), forControlEvents: .TouchUpInside)
        self.shareTaken!.layer.cornerRadius = 5
        self.shareTaken!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.shareTaken!.backgroundColor = UIColor.whiteColor()
        self.shareTaken!.setTitleColor(UIColor(hex:0x1D62F0), forState: .Highlighted)
//        self.view.addSubview(self.shareTaken!)
        
        let height = self.view.frame.size.height - 140
        let width = self.view.frame.width
        let frame_bg = CGRectMake(0, 40, width, height)
        let backgroundView = UIView(frame: frame_bg)
        backgroundView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(backgroundView)
        self.imageView = UIImageView(frame: frame_bg)
        self.imageView?.image = self.image
        self.view.addSubview(self.imageView!)
        
        self.refImageView = UIImageView(frame: frame_bg)
        self.refImageView?.image = self.refImage
        self.refImageView?.alpha = 0
        self.view.addSubview(self.refImageView!)
        if self.imageView?.image?.size.width > self.imageView?.image?.size.height {
            self.imageView?.frame = CGRectMake(frame_bg.origin.x + frame_bg.size.width / 2 - frame_bg.size.height / 2,
                                               frame_bg.origin.y + frame_bg.size.height / 2 - frame_bg.size.width / 2,
                                               frame_bg.size.height,
                                               frame_bg.size.width)
            self.ratio1 = (self.imageView?.frame.size.height)! / (self.imageView?.frame.size.width)!
            self.ratio2 = 1
            switch self.imageOrientation {
            case -1:
                self.orientation = -1
                // self.cancelButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_2_PI))
                self.acceptButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.flipButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                
                let transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, ratio2, ratio2)
                break
            case 1:
                self.orientation = 1
                // self.cancelButton!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.acceptButton!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.flipButton!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                
                let transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, ratio2, ratio2)
                break
            default:
                break
            }
            self.imageOrientation = 0
        } else{
            self.ratio1 = 1
            self.ratio2 = (self.imageView!.frame.size.width) / (self.imageView!.frame.size.height)
        }
        
        // add watermark
         waterMark()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.motionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {
            (motion: CMDeviceMotion?, error: NSError?) -> Void in
            if motion!.gravity.x > 0.5 {
                self.rotateLeft()
            } else if motion!.gravity.x < -0.5 {
                self.rotateRight()
            } else if motion!.gravity.y < -0.3 && abs(motion!.gravity.x) < 0.3 {
                self.rotateUpright()
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.motionManager?.stopDeviceMotionUpdates()
    }
    
    //MARK: Rotation
    
    func rotateUpright() {
        if (self.orientation==0) {
            return
        }
        UIView.animateWithDuration(0.3, animations:  {
            self.acceptButton!.transform=CGAffineTransformMakeRotation(0)
            self.cancelButton!.transform=CGAffineTransformMakeRotation(0)
            self.flipButton!.transform=CGAffineTransformMakeRotation(0)
            self.instagramButton!.transform=CGAffineTransformMakeRotation(0)
            var transform: CGAffineTransform
            switch (self.imageOrientation) {
            case 0:
                transform=CGAffineTransformMakeRotation(0)
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio1, self.ratio1)
                break
            case -1:
                transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio2, self.ratio2)
                break
            case 1:
                transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio2, self.ratio2)
                break
            default:
                break
            }
            
        })
        self.orientation = 0
    }
    
    func rotateLeft() {
        if (self.orientation==1){
            return
        }
        UIView.animateWithDuration(0.3, animations:{
            self.cancelButton!.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            self.acceptButton!.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            self.flipButton!.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            self.instagramButton!.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            var transform: CGAffineTransform
            switch (self.imageOrientation) {
            case 1:
                transform=CGAffineTransformMakeRotation(0)
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio1, self.ratio1)
                break
            case 0:
                transform=CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio2, self.ratio2)
                break
            case -1:
                transform=CGAffineTransformMakeRotation(CGFloat(-M_PI))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio1, self.ratio1)
                break
            default:
                break
            }
            
        })
        self.orientation=1
    }
    
    func rotateRight() {
        if (self.orientation == -1){
            return
        }
        UIView.animateWithDuration(0.3, animations: {
            self.cancelButton!.transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            self.acceptButton!.transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            self.flipButton!.transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            self.instagramButton!.transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            var transform: CGAffineTransform
            switch (self.imageOrientation) {
            case -1:
                transform=CGAffineTransformMakeRotation(0)
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio1, self.ratio1)
                break
            case 0:
                transform=CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio2, self.ratio2)
                break
            case 1:
                transform=CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.imageView!.transform=CGAffineTransformScale(transform, self.ratio1, self.ratio1)
                break
            default:
                break
            }
            
        })
        self.orientation = -1
    }
    
    //MARK: Image Edit
    
    func cornerImageBlured(image: UIImage, cornerRect: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cornerRect)
        let croppedImage = UIImage(CGImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage.applyLightEffect()
    }
    
    func waterMark() {
        let image = self.image!
        let waterMark = UIImage(named: "like2.png")
        let imgSize = image.size
        let ratio: CGFloat = 0.1 // how big the watermark is
        
        let scaling: CGFloat = min( (image.size.width * ratio) / (waterMark?.size.width)!, (image.size.height * ratio) / (waterMark?.size.height)!)
        let waterSize = CGSize(width: (waterMark?.size.width)! * scaling, height: (waterMark?.size.height)! * scaling)
        
        let waterRect = CGRectMake(imgSize.width - waterSize.width, imgSize.height - waterSize.height, waterSize.width, waterSize.height)
        let rect = CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height)
        let bluredBackground = cornerImageBlured(image, cornerRect: waterRect)
        
        UIGraphicsBeginImageContextWithOptions(imgSize, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, rect)
        
        image.drawInRect(rect, blendMode: .Normal, alpha: 1)
        bluredBackground.drawInRect(waterRect, blendMode: .Normal, alpha: 1)
        waterMark!.drawInRect(waterRect, blendMode: .Normal, alpha: 1)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = result
    }
}
