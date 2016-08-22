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
    
    let upperBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    let lowerBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    
    //overlay mode
    var frame_bg = CGRect()
    var frame_tm = CGRect()
    var lastPos: CGFloat = 0.0
    var usingBackground = false
    
    //animation
    var fadeView: UIView?
    var dot: UIImageView?
    var swipeView: UIImageView?
    var stopAnimation = false
    let guideLabel1 = UILabel()
    let guideLabel2 = UILabel()
    var timesPlayed = 0
    
    //constants
    let marginFactor: CGFloat = 15.0
    let zoomFactor: CGFloat = 15.0
    let sizeFactor: CGFloat = 70.0
    let positionFactor : CGFloat = 0.56
    let headerHeight: CGFloat = 40
    let footerHeight: CGFloat = 100
    
    var refOrientation = 0.0
    
    //slider & alpha control
    var slider: UISlider?
    var _control_alpha: Float = 0.0
    var overlayAlpha: CGFloat{
        set {
            if newValue > 1.0 {
                self._control_alpha = Float(newValue)
                self.imageView?.alpha = 1.0
                self.slider?.value = 1.0
                if newValue > 1.15 {
                    switchToBigDot()
                }
                if newValue > 1.3 {
                    self._control_alpha = 1.3
                }
            } else {
                self._control_alpha = Float(newValue)
                self.imageView?.alpha = newValue
                self.slider?.value = self._control_alpha
                switchToSmallDot()
            }
        }
        get {
            return CGFloat(_control_alpha)
        }
    }
    var sliderDot: UIImageView?
    
    func switchToBigDot() {
        self.slider?.setThumbImage(UIImage(named: "empty.png"), forState: .Normal)
        let sWidth = self.frame.width
        let sHeight = frame.height
        UIView.animateWithDuration(0.07) {
            self.sliderDot?.frame = CGRectMake(sWidth - 65, sHeight-self.footerHeight-69, 45, 45)
        }
        if self.usingBackground {
            onSegChanged()
        }
    }
    
    func switchToSmallDot() {
        self.slider?.setThumbImage(nil, forState: .Normal)
        let sWidth = self.frame.width
        let sHeight = frame.height
        UIView.animateWithDuration(0.07) {
            self.sliderDot?.frame = CGRectMake(sWidth - 48, sHeight-self.footerHeight-51, 10, 10)
        }
        if self.usingBackground == false {
            onSegChanged()
        }
    }
    
    // grid overlay
    var gridBtn: UIButton?
    var gridOverlay: CCGridOverlay?
    
    func prepareAnimation() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let number = userDefault.objectForKey("isFirstTimeUser")
        if number != nil {
            return
        }
        
        userDefault.setValue(Int(0), forKey: "isFirstTimeUser")
        userDefault.synchronize()
        
        UIView.animateWithDuration(0.1, animations: {
            self.guideLabel1.alpha = 1
            self.guideLabel2.alpha = 1
            self.fadeView?.alpha = 1
            self.swipeView?.alpha = 1
            }, completion: { _ in
                self.playAnimation()
        })
    }
    
    func finishAnimation() {
        UIView.animateWithDuration(0.3, animations: {
            self.guideLabel1.alpha = 0
            self.guideLabel2.alpha = 0
            self.dot?.alpha = 0
            self.fadeView?.alpha = 0
            self.swipeView?.alpha = 0
        })
        self.stopAnimation = true
    }
    
    func playAnimation(){
        if self.stopAnimation || self.timesPlayed > 2 {
            return
        }
        self.timesPlayed += 1
        UIView.animateWithDuration(0.3, delay: 0.3, options: [UIViewAnimationOptions.CurveEaseInOut , UIViewAnimationOptions.BeginFromCurrentState], animations: { // appear
            self.dot?.frame = CGRectMake(self.marginFactor, self.frame.size.height * self.positionFactor, self.sizeFactor, self.sizeFactor)
            self.dot?.alpha = 1
            self.imageView?.alpha = 0
            self.slider?.alpha = 1
            }, completion: { finished in
                
                if self.stopAnimation {
                    return
                }
                
                UIView.animateWithDuration(0.7, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: { // moving
                    self.dot?.frame = CGRectMake(self.frame.width - self.marginFactor - self.sizeFactor - self.zoomFactor / 2, self.frame.size.height * self.positionFactor - self.zoomFactor / 2, self.sizeFactor + self.zoomFactor, self.sizeFactor + self.zoomFactor)
                    self.imageView?.alpha = 1
                    self.slider?.setValue(1, animated: true)
                    }, completion: { finished in
                        
                        if self.stopAnimation {
                            return
                        }
                        
                        UIView.animateWithDuration(0.5, delay: 0.3, options: [UIViewAnimationOptions.CurveEaseInOut], animations: { // move back
                            self.dot?.frame = CGRectMake(self.marginFactor, self.frame.size.height * self.positionFactor, self.sizeFactor, self.sizeFactor)
                            self.dot?.alpha = 0
                            self.imageView?.alpha = 0
                            self.slider?.setValue(0, animated: true)
                            }, completion: { finished in
                                if self.stopAnimation {
                                    return
                                }
                                UIView.animateWithDuration(0.3, delay: 0, options: [], animations: {
                                        self.slider?.alpha = 0
                                    }, completion: { // disapear and resize
                                    finished in
                                    self.dot?.frame = CGRectMake(self.marginFactor - self.zoomFactor / 2, self.frame.size.height * self.positionFactor, self.sizeFactor + self.zoomFactor, self.sizeFactor + self.zoomFactor)
                                    
                                    if self.stopAnimation {
                                        return
                                    }
                                    
                                    self.playAnimation()
                                })
                            })
                })
                
        })
    }
    
    func toggleGrid() {
        self.gridOverlay?.changeToNextType()
    }
    
    func onPress() {
        switch self.overlayState {
        case 0:
            self.overlayAlpha = self.savedAlpha
            self.overlayState = 1
        case 1:
            self.savedAlpha = (self.imageView?.alpha)!
            self.overlayAlpha = 0
            self.overlayState = 2
        default:
            self.overlayAlpha = 1
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
            UIView.animateWithDuration(0.3, animations: {
                self.slider?.alpha = 1.0
                self.sliderDot!.alpha = 1.0
            })
        } else if recognizer.state == .Ended {
            UIView.animateWithDuration(0.3, animations: {
                self.slider?.alpha = 0.0
                self.sliderDot!.alpha = 0.0
            })
        } else{
            
            self.overlayAlpha += (translation.x - self.lastPos) * 1.5 / 255.0
            if self.overlayAlpha < 0 {
                self.overlayAlpha = 0
            }
            if self.overlayAlpha > 1.3 {
                self.overlayAlpha = 1.3
            }
            self.lastPos = translation.x
        }
    }
    
    func handleTap(recognizer: UIPanGestureRecognizer) {
        let AVCVC = self.delegate as! AVCamViewController
        AVCVC.focusAndExposeTap(recognizer, withFlag: self.rotateFlag)
    }
    
    func onSegChanged() {
        if self.usingBackground {
            UIView.animateWithDuration(0.1, animations: {
                self.imageView?.frame = self.frame_tm
            })
            self.bringSubviewToFront(self.imageView! )
            self.usingBackground = false
        } else {
            UIView.animateWithDuration(0.1, animations: {
                self.imageView?.frame = self.frame_bg
            })
            self.bringSubviewToFront(self.slider!)
            self.bringSubviewToFront(self.sliderDot!)
            self.bringSubviewToFront(self.fakeView!)
            self.usingBackground = true
        }
        

    }
    
    
    func setOverlayImage(overImage:UIImage){
        var image = overImage
        let thumbnailSize : CGFloat = 150
        
        if image.size.width > image.size.height {
            self.frame_tm = CGRectMake(self.frame.size.width / 2 - image.size.height / image.size.width + thumbnailSize / 2, self.frame.size.height / 2 - thumbnailSize, image.size.height / image.size.width * thumbnailSize, thumbnailSize)
        } else {
            self.frame_tm = CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2 - image.size.height / image.size.width * thumbnailSize / 2, thumbnailSize, image.size.height / image.size.width * thumbnailSize)
        }
        //rotate if width > height
        if image.size.width > image.size.height {
            image = image.rotateInDegrees(-90.0)
            self.refOrientation = -90
        } else {
            self.refOrientation = 0
        }
        self.image=image;
        self.imageView?.image = image
        
        
        //for square image
        if image.size.width == image.size.height{
            self.imageView!.contentMode=UIViewContentMode.ScaleAspectFit
            upperBlurView.alpha = 1
            lowerBlurView.alpha = 1
        } else {
            upperBlurView.alpha = 0
            lowerBlurView.alpha = 0
            self.imageView!.contentMode=UIViewContentMode.ScaleAspectFill
        }

    }
    
    convenience init( frame: CGRect,  overImage: UIImage) {
        self.init(frame: frame)
        var image = overImage
        self.overlayState = 1
        let height = frame.size.height - 140
        let width = frame.size.width
        self.frame_bg = CGRectMake(0, 40, width, height)
        if frame.size.width>320{
            self.frame_bg = CGRectMake(0, 53.0/375*frame.size.width, width, height-20.0/667*frame.size.height)
        }
        let thumbnailSize : CGFloat = 150
        
        if image.size.width > image.size.height {
            self.frame_tm = CGRectMake(self.frame.size.width / 2 - image.size.height / image.size.width + thumbnailSize / 2, self.frame.size.height / 2 - thumbnailSize, image.size.height / image.size.width * thumbnailSize, thumbnailSize)
        } else {
            self.frame_tm = CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2 - image.size.height / image.size.width * thumbnailSize / 2, thumbnailSize, image.size.height / image.size.width * thumbnailSize)
        }
        
        self.backgroundColor = UIColor.clearColor()
        self.transparencyButton = UIButton.init(frame: CGRectMake(frame.size.width - 80, frame.size.height - 70, 50, 50))
        self.transparencyButton?.addTarget(self, action: #selector(CCOverlayView.onPress), forControlEvents: .TouchUpInside)
        self.transparencyButton?.setBackgroundImage(UIImage(named: "transparency.png"), forState: .Normal)
        //        self.addSubview(self.transparencyButton!)
        
        //rotate if width > height
        if image.size.width > image.size.height {
            image = image.rotateInDegrees(-90.0)
            self.refOrientation = -90
        }
        self.image=image;
        self.imageView = UIImageView.init(image: image)
        
        //for square image
        upperBlurView.frame = CGRectMake(0, 40, width, (height-width)/2)
        lowerBlurView.frame = CGRectMake(0, 40+width+(height-width)/2, width, (height-width)/2)
        
        self.addSubview(upperBlurView)
        self.addSubview(lowerBlurView)
        
        if image.size.width == image.size.height{
            self.imageView!.contentMode=UIViewContentMode.ScaleAspectFit
            upperBlurView.alpha = 1
            lowerBlurView.alpha = 1
        } else {
            upperBlurView.alpha = 0
            lowerBlurView.alpha = 0
            self.imageView!.contentMode=UIViewContentMode.ScaleAspectFill
        }
        
        
        self.imageView!.clipsToBounds = true
        self.imageView!.userInteractionEnabled = true;
        self.addSubview(self.imageView!)
        
        //slider
        self.slider = UISlider(frame: CGRectMake(30, frame.height-self.footerHeight-70, frame.size.width - 100, 50))
        self.slider?.minimumValue = 0.0
        self.slider?.maximumValue = 1.0
        self.slider?.continuous = true
        self.slider?.tintColor = UIColor.lightGrayColor()
        self.slider?.maximumTrackTintColor = UIColor.whiteColor()
        self.slider?.minimumTrackTintColor = UIColor.whiteColor()
        self.slider?.value = Float(self.overlayAlpha)
        self.slider?.alpha = 0
        self.addSubview(self.slider!)
        
        // slider dot
        self.sliderDot = UIImageView.init(frame: CGRectMake(frame.width - 65, frame.height-self.footerHeight-69, 45, 45))
        self.sliderDot?.image = UIImage(named: "whitedot.png")
        self.sliderDot?.alpha = 0
        self.addSubview(self.sliderDot!)
        
        //grid layout
        self.gridBtn = UIButton(frame: CGRectMake(10, 2, 35, 35))
        self.gridBtn?.setBackgroundImage(UIImage(named: "grid.png"), forState: .Normal)
        self.gridBtn?.setBackgroundImage(UIImage(named: "grid_tint.png"), forState: .Highlighted)
        self.gridBtn?.addTarget(self, action: #selector(CCOverlayView.toggleGrid), forControlEvents: .TouchUpInside)
        self.addSubview(self.gridBtn!)
        self.gridOverlay = CCGridOverlay(frame: CGRectMake(0, self.headerHeight, frame.width, frame.height-self.headerHeight-self.footerHeight))
        self.addSubview(self.gridOverlay!)
        
        self.fakeView = UIView.init(frame:self.frame_bg)
        self.fakeView!.userInteractionEnabled = true
        self.addSubview(self.fakeView!)
        self.onSegChanged()
        self.overlayAlpha = 0
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handlePan(_:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handlePinch(_:)))
        let overlayTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handleOverlayTap(_:)))
        self.imageView!.addGestureRecognizer(panGestureRecognizer)
        self.imageView?.addGestureRecognizer(pinchGestureRecognizer)
        self.imageView?.addGestureRecognizer(overlayTapGestureRecognizer)
        
        //gesture receiver
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handleTap(_:)))
        let panLRGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handlePanLR(_:)))
        let cameraPinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(CCOverlayView.handleCameraPinch(_:)))
        self.fakeView?.addGestureRecognizer(panLRGestureRecognizer)
        self.fakeView?.addGestureRecognizer(tapGestureRecognizer)
        self.fakeView?.addGestureRecognizer(cameraPinchGestureRecognizer)
        
        
        //for animation
        let shown = CCCoreUtil.userDefault.integerForKey(CCCoreUtil.SWIPE_HINT_SHOWN_TIMES)
        if (shown < 3) {
            self.fadeView = UIView.init(frame: self.frame)
            self.fadeView?.backgroundColor = UIColor(white: 0, alpha: 0.25)
            self.fadeView?.userInteractionEnabled = false
            self.fadeView?.alpha = 0
            self.addSubview(self.fadeView!)
            
            self.swipeView = UIImageView.init(frame: CGRectMake(self.frame.width-marginFactor-sizeFactor-zoomFactor/2 - 20, self.frame.size.height/2+sizeFactor+10,80, 24))
            self.swipeView?.image = UIImage(named: "swipe.png")
            self.swipeView?.alpha = 0
            //self.addSubview(self.swipeView!)
            
            self.dot = UIImageView.init(frame: CGRectMake(marginFactor-zoomFactor/2, self.frame.size.height * self.positionFactor-zoomFactor/2, sizeFactor+zoomFactor, sizeFactor+zoomFactor))
            self.dot?.image = UIImage(named: "finger.png")
            self.dot?.alpha=0;
            self.addSubview(self.dot!)
            
            guideLabel1.frame = CGRectMake(self.frame.size.width/2-150, self.frame.size.height/2-130,300, 40)
            guideLabel1.text = NSLocalizedString("Swipe to adjust transparency", comment: "") //and learn its composition
            guideLabel1.textAlignment = .Center
            guideLabel1.font = UIFont.systemFontOfSize(22)
            guideLabel1.textColor = .whiteColor()
            guideLabel1.alpha = 0
            //addSubview(guideLabel1)
            
            guideLabel2.frame = CGRectMake(self.frame.size.width/2-150, self.frame.size.height/2-80,300, 40)
            guideLabel2.text = NSLocalizedString("and learn its composition", comment: "")
            guideLabel2.textAlignment = .Center
            guideLabel2.font = UIFont.systemFontOfSize(19)
            guideLabel2.textColor = .whiteColor()
            guideLabel2.alpha = 0
            //addSubview(guideLabel2)
            
            self.stopAnimation = false
            
            CCCoreUtil.userDefault.setInteger(shown + 1, forKey: CCCoreUtil.SWIPE_HINT_SHOWN_TIMES)
        } else {
            self.stopAnimation = true
        }
        
    }
    
    
    
}
