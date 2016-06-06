//
//  CCTemplateViewController.swift
//  CopyCatSwift
//
//  Created by Roy Xue on 6/5/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCTemplateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var closeButton = UIButton()
    private var templateCol = UICollectionView()
    private var categoryCol = UICollectionView()
    let templateIdentifier = "templateCell"
    let categoryIdentifier = "categoryCell"
    
    var cateList = ["A", "B", "C"]
    var tempList = ["A", "B", "C"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.frame = CGRectMake(self.view.frame.size.width-45, self.view.frame.size.height-45, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: "closeView", forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        
        
    }
    
    // Collection View part
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == templateCol){
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (collectionView == templateCol){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(templateIdentifier, forIndexPath: indexPath) as! CCTemplateCollectionCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(categoryIdentifier, forIndexPath: indexPath) as! CCCategoryCollectionCell
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        if (collectionView == templateCol){
        } else {
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = self.view.frame.size.width
        if (collectionView == templateCol){
            return CGSize(width: screenWidth/3-10, height: screenWidth/3-10)
        } else {
            return CGSize(width: screenWidth/3-10, height: 10)
        }
    }
    
    // Close Button Function
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: {_ in})
    }
}
