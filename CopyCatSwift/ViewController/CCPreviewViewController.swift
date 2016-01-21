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

class CCPreviewViewController : UIViewController {
    
    var delegate: AnyObject?
    var image: UIImage?
    var refImage: UIImage?
    var imageView: UIImageView?
    var refImageView: UIImageView?
    
    var isShowingRef: Bool = false
    
    var acceptButton: UIButton?
    var cancelButton: UIButton?
    var flipButton: UIButton?
    
    var motionManager: CMMotionManager?
    var imageOrientation = 0
    var orientation = 0
    var ratio1: CGFloat = 0
    var ratio2: CGFloat = 0
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
                ALAssetsLibrary().writeImageToSavedPhotosAlbum(image?.CGImage, orientation: image?.imageOrientation as! ALAssetOrientation, completionBlock: nil)
            }
            
            CCCoreUtil.addUserPhoto(image!, refImage: self.refImage!)
            
            dispatch_async(dispatch_get_main_queue(), {
                vc.libraryButton.enabled = true
                vc.stillButton.enabled = true
            })
        })
        
        self.dismissSelf()
    }
    
    
    func dismissSelf() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func onFlipPress() {
        UIView.animateWithDuration(0.2, animations: {
            if self.isShowingRef {
                self.imageView?.alpha = 1
                self.refImageView?.alpha = 0
                self.isShowingRef = false
            } else {
                self.imageView?.alpha = 0
                self.refImageView?.alpha = 1
                self.isShowingRef = true
            }
        })
    }
    

    init(image: UIImage, withReferenceImage refImage: UIImage, orientation: Int) {
        super.init(nibName: nil, bundle: nil)
     
            self.image = image
            self.refImage = refImage
            self.imageOrientation = orientation
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
        
        // Rotation
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 0.1
        self.orientation = 0
        
        self.acceptButton = UIButton(frame: CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height - 85, 80, 80))
        self.acceptButton?.addTarget(self, action:"saveImage", forControlEvents:.TouchUpInside)
        
        self.acceptButton?.setBackgroundImage(UIImage(named: "save.png"), forState: .Normal)
        self.view.addSubview(self.acceptButton!)
        self.cancelButton = UIButton(frame: CGRectMake(40, self.view.frame.size.height - 70, 55, 55))
        
        self.cancelButton?.addTarget(self, action: "dismissSelf", forControlEvents: .TouchUpInside)
        self.cancelButton?.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        self.cancelButton?.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        self.view.addSubview(self.cancelButton!)
        self.flipButton = UIButton(frame: CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 70, 55, 55))
        self.flipButton?.addTarget(self, action: "onFlipPress", forControlEvents: .TouchUpInside)
        self.flipButton?.setBackgroundImage(UIImage(named: "flip2.png"), forState: .Normal)
        self.flipButton?.setBackgroundImage(UIImage(named: "flip2_highlight.png"), forState: .Highlighted)
        self.view.addSubview(self.flipButton!)
        self.isShowingRef = true
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
                self.cancelButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_2_PI))
                self.acceptButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.flipButton!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                
                let transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.imageView!.transform=CGAffineTransformScale(transform, ratio2, ratio2)
                break
            case 1:
                self.orientation = 1
                self.cancelButton!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.motionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {
            (motion: CMDeviceMotion?, error: NSError?) -> Void in
            if motion!.gravity.x > 0.5 {
                self.rotateLeft()
            } else if motion!.gravity.x < -0.5 {
                self.rotateRight()
            } else if motion!.gravity.y > -0.3 && motion!.gravity.x < 0.3 {
                self.rotateUpright()
            }
            
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.motionManager?.stopDeviceMotionUpdates()
    }
    
    func rotateUpright() {
        if (self.orientation==0) {
            return
        }
        UIView.animateWithDuration(0.3, animations:  {
            self.acceptButton!.transform=CGAffineTransformMakeRotation(0)
            self.cancelButton!.transform=CGAffineTransformMakeRotation(0)
            self.flipButton!.transform=CGAffineTransformMakeRotation(0)
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
}



















