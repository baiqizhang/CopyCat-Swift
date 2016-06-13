//
//  CCTemplateViewController.swift
//  CopyCatSwift
//
//  Created by Roy Xue on 6/5/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCTemplateViewController: UIViewController {
  @IBOutlet weak var photoCollectionView: UICollectionView!
  @IBOutlet weak var cateCollectionView: UICollectionView!
  
  var cates = ["a", "b", "c", "d"]
  var photos = [
    "a": ["1", "2", "3", "4"],
    "b": ["1", "2", "4"],
    "c": ["1", "3", "4"],
    "d": ["2", "3", "4"],
  ]
  var currentCate = "a"

  static func loadVC() -> CCTemplateViewController {
    return UIStoryboard(name: "CameraTemplate", bundle: nil).instantiateInitialViewController() as! CCTemplateViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func closeVC(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

extension CCTemplateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == photoCollectionView {
      return photos[currentCate]?.count ?? 0
    }

    return cates.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if collectionView == photoCollectionView {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
      cell.label.text = photos[currentCate]?[indexPath.row] ?? ""
      return cell
    } else {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cateCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        
        cell.label.text = cates[indexPath.row] ?? ""
        
        return cell
    }
    
    
    
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if collectionView == photoCollectionView {
      let width = UIScreen.mainScreen().bounds.width / 3
      return CGSize(width: width, height: width)
    }
    return CGSize(width: 80, height: 80)
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if collectionView == photoCollectionView {
      debugPrint("You press photo at \(indexPath.row)")
      return
    }
    currentCate = cates[indexPath.row]
    photoCollectionView.reloadData()
  }
}