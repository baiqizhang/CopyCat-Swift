//
//  CCCollectionViewCell.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/16/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCCollectionViewCell: UICollectionViewCell {
    
    var imagePath: String?

    var deleteFlag: Int?
    var delegate: AnyObject?
    var coreData: AnyObject?
    
    var overlayView: CCOverlayFrameView?
    var imageView: UIImageView?
    var longPress: UILongPressGestureRecognizer?
    
    
    func handleLongPress(longPress: UILongPressGestureRecognizer!){
        if self.deleteFlag < 0 {return}
        if longPress.state == .Began {
            let vc = self.delegate as! CCPhotoCollectionManipulation
            vc.prepareDeleteCell(self)
            vc.prepareDelete()
            self.flip()
        }
    }
    
    func flip() -> Bool {
        if self.deleteFlag! == 0
        {
            self.overlayView!.alpha=1
            self.imageView!.alpha=0.5
            self.deleteFlag = 1 - self.deleteFlag!
        }else{
            self.overlayView!.alpha=0
            self.imageView!.alpha=1
            self.deleteFlag = 1 - self.deleteFlag!
        }
        return Bool(self.deleteFlag!)
    }
    
    func getImageForPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        return image
    }
    
    func image() -> UIImage? {
        let path = "\(NSHomeDirectory())/Documents/\(self.imagePath!).jpg"
        if let tmp = self.getImageForPath(path) {
            return tmp
        } else {
            return UIImage(named: "\(self.imagePath!).jpg")
        }
    }
    
    func tmImage() -> UIImage? {
        let path = "\(NSHomeDirectory())/Documents/tm/\(self.imagePath!).jpg"
        if let tmp = self.getImageForPath(path) {
            return tmp
        } else {
            if let tmp = self.image() {
                let tmImage = tmp.thumbnailWithFactor(200)
                let imgData = UIImageJPEGRepresentation(tmImage, 0.5)
                // TODO cannot save image
                let writeFlag = imgData?.writeToFile(path, atomically: true)
                NSLog("file saved: \(writeFlag)")
                return tmImage
            }
        }
        return nil
    }

    func initWithImagePath(imagePath: String, deleteFlag: Int) {
        self.deleteFlag = deleteFlag
        self.imagePath = imagePath
        if self.imageView == nil {
            self.imageView = UIImageView()
            self.addSubview(self.imageView!)
        }
        
        self.imageView?.frame = CGRectMake(0,0, self.frame.size.width, self.frame.size.height)
        self.imageView?.alpha=0
        
        if self.overlayView == nil {
            self.overlayView = CCOverlayFrameView()
            
            self.overlayView?.frame = (self.imageView?.frame)!
            self.overlayView?.backgroundColor = UIColor.clearColor()
            self.addSubview(self.overlayView!)
        }
        self.overlayView?.alpha = 0
        
        self.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        if self.longPress == nil {
            self.longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            self.longPress!.minimumPressDuration = 0.5
            self.addGestureRecognizer(self.longPress!)
        }
        

        dispatch_async(dispatch_get_global_queue(0, 0), {
            let tmImage = self.tmImage()
            dispatch_async(dispatch_get_main_queue(), {
                self.imageView!.image = tmImage!
                self.imageView!.contentMode=UIViewContentMode.ScaleAspectFill
                self.imageView!.clipsToBounds = true
                UIView.animateWithDuration(0.3, animations: {
                    self.imageView!.alpha = 1
                })
                if self.deleteFlag! == 1 {
                    self.overlayView?.alpha = 1
                    self.imageView?.alpha = 0.5
                }
                
            })
        })

    }
    
}
