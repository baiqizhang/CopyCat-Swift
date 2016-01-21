//
//  CCOverlayView.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/21/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCOverlayView: UIView {
    
    var image: UIImage?
    var picker: UIImagePickerController?
    var delegate: AnyObject?
    var transparencyButton: UIButton?
    
    var imageView: UIImageView?
    var segControl: UISegmentedControl?
    var fakeView: UIView?
    var rotateFlag = false
    
    var overlayState: CGFloat = 0
    var savedAlpha: CGFloat = 0.0
    
    var frame_bg = CGRect()
    var frame_tm = CGRect()
    var lastPos: CGFloat = 0.0
    
    var usingBackground = false
    
    var fadeView: UIView?
    var dot: UIImageView?
    var swipeView: UIImageView?
    
    var stopAnimation = false
    
    let marginFactor: CGFloat = 60.0
    let zoomFactor: CGFloat = 10.0
    let sizeFactor: CGFloat = 45.0
    
    
    func prepareAnimation() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let number = userDefault.objectForKey("isFirstTimeUser")
        if number != nil {
            return
        }
        
        userDefault.setValue(Int(0), forKey: "isFirstTimeUser")
        userDefault.synchronize()
        
        UIView.animateWithDuration(0.1, animations: {
            self.fadeView?.alpha = 1
            }, completion: { _ in
                self.playAnimation()
        })
    }
    
    func finishAnimation() {
        UIView.animateWithDuration(0.3, animations: {
            self.dot?.alpha = 0
            self.fadeView?.alpha = 0
            self.swipeView?.alpha = 0
        })
        self.stopAnimation = true
    }
    
    
    func playAnimation(){
        if self.stopAnimation {
            return
        }
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: [UIViewAnimationOptions.CurveEaseInOut , UIViewAnimationOptions.BeginFromCurrentState], animations: {
            self.dot?.frame = CGRectMake(self.marginFactor, self.frame.size.height / 3.0 * 2, self.sizeFactor, self.sizeFactor)
            self.dot?.alpha = 1
            }, completion: { finished in
                //2
                if self.stopAnimation {
                    return
                }
                UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
                    self.dot?.frame = CGRectMake(320 - self.marginFactor - self.sizeFactor - self.zoomFactor / 2, self.frame.size.height / 3.0 * 2 - self.zoomFactor / 2, self.sizeFactor + 10, self.sizeFactor + 10)
                    self.dot?.alpha = 0
                    }, completion: { finished in
                        // 4
                        if self.stopAnimation {
                            return
                        }
                        UIView.animateWithDuration(1, delay: 0, options: [], animations: {}, completion: {
                            finished in
                            self.dot?.frame = CGRectMake(self.marginFactor - self.zoomFactor / 2, self.frame.size.height / 3.0 * 2, self.sizeFactor + self.zoomFactor, self.sizeFactor + self.zoomFactor)
                            if self.stopAnimation {
                                return
                            }
                            self.playAnimation()
                        })
                })
                
        })
    }
    
    
    func onPress() {
        switch self.overlayState {
        case 0:
            self.imageView?.alpha = self.savedAlpha
            self.overlayState = 1
        case 1:
            self.savedAlpha = (self.imageView?.alpha)!
            self.imageView?.alpha = 0
            self.overlayState = 2
        default:
            self.imageView?.alpha = 1
            self.overlayState = 0
        }
    }
    
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if self.usingBackground {
            return
        }
        recognizer.view?.transform = CGAffineTransformScale((recognizer.view?.transform)!, recognizer.scale, recognizer.scale);
        recognizer.scale = 1
    }
    
    
    func handleCameraPinch(recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.scale
        let AVCVC = self.delegate as! AVCamViewController
        AVCVC.cameraZoom(Float(scale))
        recognizer.scale = 1
    }
    
    func handleOverlayTap(recognizer: UIPanGestureRecognizer){
        if self.usingBackground {
            return
        }
        self.imageView?.transform = CGAffineTransformRotate((self.imageView?.transform)!, CGFloat(-M_PI_2))
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer){
        if self.usingBackground {
            return
        }
        let translation = recognizer.translationInView(self)
        recognizer.view?.center = CGPointMake((recognizer.view?.center.x)! + translation.x, (recognizer.view?.center.y)! + translation.y)
        recognizer.setTranslation(CGPoint.zero, inView: self)
    }
    
    func handlePanLR(recognizer:UIPanGestureRecognizer){
        self.finishAnimation()
        
        let translation = recognizer.translationInView(self)
        if recognizer.state == .Began {
            self.lastPos = translation.x
        } else {
            self.imageView?.alpha += (translation.x - self.lastPos) / 255.0
            if self.imageView?.alpha < 0 {
                self.imageView?.alpha = 0
            }
            if self.imageView?.alpha > 1 {
                self.imageView?.alpha = 1
            }
            self.lastPos = translation.x
        }
    }
    
    func handleTap(recognizer: UIPanGestureRecognizer) {
        let AVCVC = self.delegate as! AVCamViewController
        AVCVC.focusAndExposeTap(recognizer, withFlag: self.rotateFlag)
    }
    
    func onSegChanged() {
        if CCCoreUtil.isUsingBackgrondMode == 1{
            self.imageView?.frame = self.frame_bg
            self.imageView?.alpha = 0.2
            self.bringSubviewToFront(self.fakeView!)
            self.usingBackground = true
        } else {
            self.imageView?.frame = self.frame_tm
            self.imageView?.alpha = 0.9
            self.bringSubviewToFront(self.imageView! )
            self.usingBackground = false
        }
    }
    
    convenience init(var frame: CGRect, var image: UIImage) {
        self.init(frame: frame)
        
        self.overlayState = 1
        let height = frame.size.height - 140
        let width = frame.size.width
        self.frame_bg = CGRectMake(0, 40, width, height)
        let ratio = width / height
        let thumbnailSize : CGFloat = 150

        if image.size.width > image.size.height {
            self.frame_tm = CGRectMake(self.frame.size.width / 2 - image.size.height / image.size.width + thumbnailSize / 2, self.frame.size.height / 2 - thumbnailSize, image.size.height / image.size.width * thumbnailSize, thumbnailSize)
        } else {
            self.frame_tm = CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2 - image.size.height / image.size.width * thumbnailSize / 2, thumbnailSize, image.size.height / image.size.width * thumbnailSize)
        }
        
        self.backgroundColor = UIColor.clearColor()
        self.transparencyButton = UIButton.init(frame: CGRectMake(frame.size.width - 80, frame.size.height - 70, 50, 50))
        self.addSubview(self.transparencyButton!)
        self.transparencyButton?.addTarget(self, action: "onPress", forControlEvents: .TouchUpInside)
        self.transparencyButton?.setBackgroundImage(UIImage(named: "transparency.png"), forState: .Normal)
        
        var CGImage: CGImageRef
        if image.size.width > image.size.height {
            if image.size.width * ratio > image.size.height {
                CGImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake((image.size.width-image.size.height/ratio)/2.0, 0,  image.size.height/ratio,image.size.height))!
            } else {

             CGImage=CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, (image.size.height-image.size.width*ratio)/2.0, image.size.width, image.size.width*ratio))!
            }
         }
         else
         {
            if image.size.height * ratio > image.size.width {
                CGImage=CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0,(image.size.height-image.size.width/ratio)/2.0,image.size.width, image.size.width/ratio))!
            }
            
            else {
             CGImage=CGImageCreateWithImageInRect(image.CGImage, CGRectMake((image.size.width-image.size.height*ratio)/2.0, 0, image.size.height*ratio, image.size.height))!
            }
        }
        
        if image.size.width > image.size.height {
             let frame = self.frame_bg;
             UIGraphicsBeginImageContext(frame.size)
             let context = UIGraphicsGetCurrentContext()
             CGContextRotateCTM(context, 90.0/180.0*3.1415926)
             CGContextScaleCTM(context, 1.0,-1.0)
             CGContextDrawImage(context, CGRectMake(0, 0, frame.size.height, frame.size.width),CGImage)
             image = UIGraphicsGetImageFromCurrentImageContext()
             UIGraphicsEndImageContext();
         } else {
             frame=self.frame_bg;
             UIGraphicsBeginImageContext(frame.size);
             let context = UIGraphicsGetCurrentContext();
             CGContextScaleCTM(context, 1.0,-1.0);
             CGContextTranslateCTM(context, 0.0, -frame.size.height);
             CGContextDrawImage(context, CGRectMake(0, 0, frame.size.width, frame.size.height),CGImage);
             image = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
         }
        
         self.image=image;
         self.imageView = UIImageView.init(image: image)
         self.imageView!.userInteractionEnabled = true;
        
        self.addSubview(self.imageView!)
        
        self.fakeView = UIView.init(frame:self.frame_bg)
        self.fakeView!.userInteractionEnabled = true
        self.addSubview(self.fakeView!)
        
        self.onSegChanged()
        
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: "handlePan:")
        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: "handlePinch:")
        let overlayTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: "handleOverlayTap:")
        self.imageView!.addGestureRecognizer(panGestureRecognizer)
        self.imageView?.addGestureRecognizer(pinchGestureRecognizer)
        self.imageView?.addGestureRecognizer(overlayTapGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: "handleTap:")
        let panLRGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: "handlePanLR:")
        let cameraPinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: "handleCameraPinch:")
        self.fakeView?.addGestureRecognizer(panLRGestureRecognizer)
        self.fakeView?.addGestureRecognizer(tapGestureRecognizer)
        self.fakeView?.addGestureRecognizer(cameraPinchGestureRecognizer)

        self.fadeView = UIView.init(frame: self.frame)
        self.fadeView?.backgroundColor = UIColor(white: 0, alpha: 0.75)
        self.fadeView?.userInteractionEnabled = false
        self.fadeView?.alpha = 0
        self.addSubview(self.fadeView!)
        
        self.swipeView = UIImageView.init(frame: CGRectMake(320-marginFactor-sizeFactor-zoomFactor/2, self.frame.size.height/3.0*2+sizeFactor+5,60, 17.5))
        self.swipeView?.image = UIImage(named: "swipe.png")
        self.swipeView?.alpha = 0
        self.addSubview(self.swipeView!)
        self.dot = UIImageView.init(frame: CGRectMake(marginFactor-zoomFactor/2, self.frame.size.height/3.0*2-zoomFactor/2, sizeFactor+zoomFactor, sizeFactor+zoomFactor))
        self.dot?.image = UIImage(named: "whitedot.png")
        self.dot?.alpha=0;
        self.addSubview(self.dot!)
        
        self.stopAnimation = false
    }

}