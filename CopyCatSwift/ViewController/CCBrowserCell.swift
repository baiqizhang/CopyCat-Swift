//
//  CCBrowserCell.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/17/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit


class CCBrowserCell: UICollectionViewCell, UIScrollViewDelegate, MWTapDetectingImageViewDelegate {
    
    var photoBrowser: CCPhotoBrowser?
    var image: UIImage?
    
    var _zoomingScrollView: UIScrollView?
    var zoomingScrollView: UIScrollView? {
        get {
            if _zoomingScrollView == nil {
                _zoomingScrollView = UIScrollView.init(frame: CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height))
                _zoomingScrollView!.delegate = self

                _zoomingScrollView!.autoresizingMask = [.FlexibleWidth, .FlexibleWidth]
                _zoomingScrollView!.showsHorizontalScrollIndicator = false
                _zoomingScrollView!.showsVerticalScrollIndicator = false
                _zoomingScrollView!.decelerationRate = UIScrollViewDecelerationRateFast
                self.addSubview(_zoomingScrollView!)

            }
            return _zoomingScrollView!
        }
        
        set {
            _zoomingScrollView = newValue
        }
    }
    
    var _photoImageView: MWTapDetectingImageView?
    var photoImageView: MWTapDetectingImageView? {
        get {
            if _photoImageView == nil {
                _photoImageView = MWTapDetectingImageView.init(frame: CGRectZero)
                _photoImageView!.tapDelegate = self
                _photoImageView!.contentMode = UIViewContentMode.Center
                _photoImageView!.backgroundColor = UIColor.blackColor()
                self.zoomingScrollView!.addSubview(_photoImageView!)
            }
            return _photoImageView!
        }
        set {
            _photoImageView = newValue
        }
    }
    var imagePath: String?
    var isRef: Bool?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isRef = false
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWithImagePath(imagePath: String, photoBrowser: CCPhotoBrowser) {
        self.photoBrowser = photoBrowser
        self.zoomingScrollView!.maximumZoomScale = 1
        self.zoomingScrollView!.minimumZoomScale = 1
        self.zoomingScrollView!.zoomScale = 1
        self.zoomingScrollView!.contentSize = CGSizeMake(0, 0)
        let _ = self.photoImageView!
        
        self.imagePath = imagePath
        if self.isRef! {
            let path = "\(NSHomeDirectory())/Documents/\(imagePath)_ref.jpg"
            self.image = UIImage(contentsOfFile: path)
        } else {
            let path = "\(NSHomeDirectory())/Documents/\(imagePath).jpg"
            self.image = UIImage(contentsOfFile: path)
            if self.image == nil {
                self.image = UIImage(named: imagePath)
            }
        }
        
        var photoImageViewFrame = CGRect()
        photoImageViewFrame.origin = CGPointZero
        photoImageViewFrame.size = (self.image?.size)!
        self.photoImageView!.frame = photoImageViewFrame
        self.zoomingScrollView!.contentSize = photoImageViewFrame.size
        self.photoImageView!.image = self.image
        UIView.animateWithDuration(0.3, animations: {self.photoImageView!.alpha = 1})
        self.setMaxMinZoomScalesForCurrentBounds()
        self.setNeedsLayout()
        self.photoImageView!.hidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView!.removeFromSuperview()
        self.zoomingScrollView!.removeFromSuperview()
        self.photoImageView = nil
        self.zoomingScrollView = nil
        self.isRef = false
    }
    
    func flip() {
        let tmp = self.isRef!
        self.prepareForReuse()
        self.isRef = !tmp
        self.initWithImagePath(self.imagePath!, photoBrowser: self.photoBrowser!)
    }
    
    func initialZoomScaleWithMinScale() -> CGFloat {
        let zoomScale = self.zoomingScrollView!.minimumZoomScale
        let boundsSize = self.zoomingScrollView!.bounds.size
        let imageSize = (self.photoImageView!.image?.size)!
        let boundsAR = boundsSize.width / bounds.height
        let imageAR = imageSize.width / imageSize.height
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (abs(boundsAR - imageAR) < 0.17) {
            var zoomScale = max(xScale, yScale)
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = min(max(self.zoomingScrollView!.minimumZoomScale, zoomScale), self.zoomingScrollView!.maximumZoomScale)
        }
        return zoomScale
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        // Reset
        self.zoomingScrollView!.maximumZoomScale = 1
        self.zoomingScrollView!.minimumZoomScale = 1
        self.zoomingScrollView!.zoomScale = 1
        
        // Bail if no image
        if _photoImageView!.image == nil { return }
        
        // Reset position
        _photoImageView!.frame = CGRectMake(0, 0, _photoImageView!.frame.size.width, _photoImageView!.frame.size.height)
        
        // Sizes
        let boundsSize = self.zoomingScrollView!.bounds.size
        let imageSize = _photoImageView!.image!.size
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        var minScale = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        
        // Calculate Max
        var maxScale : CGFloat = 1.5
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            // Let them go a bit bigger on a bigger screen!
            maxScale = 4
        }
        
        // Image is smaller than screen so no zooming!
        if xScale >= 1 && yScale >= 1 {
            minScale = 1.0
        }
        
        // Set min/max zoom
        self.zoomingScrollView!.maximumZoomScale = maxScale
        self.zoomingScrollView!.minimumZoomScale = minScale
        
        // Initial zoom
        self.zoomingScrollView!.zoomScale = self.initialZoomScaleWithMinScale()
        
        // If we're zooming to fill then centralise
        if (self.zoomingScrollView!.zoomScale != minScale) {
            // Centralise
            self.zoomingScrollView!.contentOffset = CGPointMake((imageSize.width * self.zoomingScrollView!.zoomScale - boundsSize.width) / 2.0,
                                                                (imageSize.height * self.zoomingScrollView!.zoomScale - boundsSize.height) / 2.0)
            // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
            self.zoomingScrollView!.scrollEnabled = false
        }
        
        // Layout
        self.setNeedsLayout()
        
    }


    override func layoutSubviews() {
        // Super
        super.layoutSubviews()
        
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = self.zoomingScrollView!.bounds.size
        var frameToCenter = _photoImageView!.frame
        
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / CGFloat(2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / CGFloat(2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if (!CGRectEqualToRect(_photoImageView!.frame, frameToCenter)) {
           _photoImageView!.frame = frameToCenter
        }
        
    }
    

    func viewForZoomingInScrollView(scrollView: UIScrollView)-> UIView?{
        return self.photoImageView
    }

    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView: UIView?) {
        self.zoomingScrollView!.scrollEnabled = true // reset
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    

    func handleSingleTap(touchPoint: CGPoint) {
        self.photoBrowser!.performSelector("toggleControls", withObject: nil, afterDelay: 0.2)
    }

    func handleDoubleTap(touchPoint: CGPoint) {
        
        // Cancel any single tap handling
        NSObject.cancelPreviousPerformRequestsWithTarget(self.photoBrowser!)
        // Zoom
        if (self.zoomingScrollView!.zoomScale != self.zoomingScrollView!.minimumZoomScale && self.zoomingScrollView!.zoomScale != self.initialZoomScaleWithMinScale()) {
            
            // Zoom out
        self.zoomingScrollView!.setZoomScale(self.zoomingScrollView!.minimumZoomScale, animated:true)
        
        } else {
            
            // Zoom in to twice the size
            let newZoomScale = (self.zoomingScrollView!.maximumZoomScale + self.zoomingScrollView!.minimumZoomScale) / 2
            let xsize = self.zoomingScrollView!.bounds.size.width / newZoomScale
            let ysize = self.zoomingScrollView!.bounds.size.height / newZoomScale
            self.zoomingScrollView!.zoomToRect(CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize), animated:true)
            
        }
    }

// Image View
    func imageView(imageView: UIImageView, singleTapDetected touch: UITouch) {
        self.handleSingleTap(touch.locationInView(imageView))
    }
    func imageView(imageView: UIImageView, doubleTapDetected touch: UITouch) {
        self.handleDoubleTap(touch.locationInView(imageView))
    }
    
}
