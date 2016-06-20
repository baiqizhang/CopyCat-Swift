//
//  CCCategoryCollectionViewCell.swift
//  CopyCat
//
//  Created by Baiqi Zhang on 2/27/16.
//  Copyright © 2016 CopyCat Team. All rights reserved.
//

import Foundation
import UIKit

class CCCategoryCollectionViewCell: UICollectionViewCell {
    
    let categoryText = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)

        categoryText.text = "aaa"
        categoryText.textColor = .whiteColor()
        
        self.categoryText.translatesAutoresizingMaskIntoConstraints = false
        let leading: NSLayoutConstraint = NSLayoutConstraint(item: self.categoryText, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let trailing: NSLayoutConstraint = NSLayoutConstraint(item: self.categoryText, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let top: NSLayoutConstraint = NSLayoutConstraint(item: self.categoryText, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom: NSLayoutConstraint = NSLayoutConstraint(item: self.categoryText, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.addConstraints([leading, trailing, top, bottom])
        self.addSubview(categoryText)
    }

}
