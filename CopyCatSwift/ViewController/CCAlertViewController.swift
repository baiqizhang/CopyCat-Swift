//
//  CCAlertViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 1/9/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCAlertViewController : UIViewController {
    
    enum Style {
        case CategoryList
        case ProgressBar
        case ActionSheet
    }
    var style : Style?
    var parent : UIViewController?
  
    // For "Save to gallery"
    var isHorizontal = true
    var saveButton = UIButton()
    var saveRefButton = UIButton()
    var saveCollageButton = UIButton()
    
    // For "Pin to Category"
    var image : UIImage?
    private let tableView = UITableView()

    // For progress bar
    var progress : CGFloat{
        set{
            let frame = progressBar.frame
            let maxWidth = view.frame.width - progressBarMargin * 2
            let width = newValue * maxWidth
            let newFrame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height)
            progressBar.frame = newFrame
            progressBar.layoutIfNeeded()
        }
        get{
            return 0.0 // placeholder
        }
    }
    private let progressBar = UIView()
    private let progressBarMargin : CGFloat = 70
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    func testAction() {
        progress = 0.0
//        progressBar.frame = CGRectMake(0, 0, 0, 0)
    }

    convenience init(style:Style){
        self.init()
        self.style = style
    }
    
    func saveRefAction(){
        if CCCoreUtil.doesSaveRefImage == 1 {
            CCCoreUtil.doesSaveRefImage = 0
        } else {
            CCCoreUtil.doesSaveRefImage = 1
        }
        if CCCoreUtil.doesSaveRefImage == 1 {
            saveRefButton.setTitleColor(UIColor(hexNumber: 0x41AFFF), forState: .Normal)
        }
        else {
            saveRefButton.setTitleColor(UIColor(hexNumber: 0xAAAAAA), forState: .Normal)
        }
    }
    
    func saveCollageAction(){
        if CCCoreUtil.doesSaveCollageImage == 1 {
            CCCoreUtil.doesSaveCollageImage = 0
        } else {
            CCCoreUtil.doesSaveCollageImage = 1
        }
        if CCCoreUtil.doesSaveCollageImage == 1 {
            saveCollageButton.setTitleColor(UIColor(hexNumber: 0x41AFFF), forState: .Normal)
        }
        else {
            saveCollageButton.setTitleColor(UIColor(hexNumber: 0xAAAAAA), forState: .Normal)
        }
    }
    
    func saveAction(){
        dismissViewControllerAnimated(false, completion: {
            if ((self.parent?.isKindOfClass(CCPreviewViewController)) != nil){
                let vc = self.parent as! CCPreviewViewController
                vc.saveImageCommit()
            }
        })
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clearColor()
        
        let background = UIButton(frame: view.frame)
        background.backgroundColor = .blackColor()
        background.alpha = 0.75
        view.addSubview(background)

        if (style == Style.ActionSheet){
            background.alpha = 0.25
            background.addTarget(self, action: #selector(CCAlertViewController.closeAction), forControlEvents: .AllTouchEvents)

            saveButton.backgroundColor = .blackColor()
            saveButton.setTitle("Save Now", forState: .Normal)
            saveButton.setTitleColor(.whiteColor(), forState: .Normal)
            saveButton.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
            saveButton.layer.borderWidth = 1
            saveButton.addTarget(self, action: #selector(saveAction), forControlEvents: .TouchDown)
            view.addSubview(saveButton)

            saveRefButton.backgroundColor = .blackColor()
            saveRefButton.setTitle("Save reference photo", forState: .Normal)
            saveRefButton.setTitleColor(.whiteColor(), forState: .Normal)
            saveRefButton.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
            saveRefButton.layer.borderWidth = 1
            saveRefButton.addTarget(self, action: #selector(saveRefAction), forControlEvents: .TouchDown)
            view.addSubview(saveRefButton)

            saveCollageButton.backgroundColor = .blackColor()
            saveCollageButton.setTitle("Save photo collage", forState: .Normal)
            saveCollageButton.setTitleColor(.whiteColor(), forState: .Normal)
            saveCollageButton.layer.borderColor = UIColor(hexNumber: 0xBBBBBB).CGColor
            saveCollageButton.layer.borderWidth = 1
            saveCollageButton.addTarget(self, action: #selector(saveCollageAction), forControlEvents: .TouchDown)
            view.addSubview(saveCollageButton)

            let width = view.frame.size.width
            let height = view.frame.size.height
            if isHorizontal{
                let padding = -width/8*3+height/32
                saveButton.frame = CGRectMake(padding, height*2/5, width/4*3, height/16)
                saveRefButton.frame = CGRectMake(height/16+padding-1, height*2/5, width/4*3, height/16)
                saveCollageButton.frame = CGRectMake(2*height/16+padding-2, height*2/5, width/4*3, height/16)

                saveButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                saveRefButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                saveCollageButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            } else {
                let padding = -width/8*3+width/2
                saveButton.frame = CGRectMake(padding, height-height/16, width/4*3, height/16)
                saveRefButton.frame = CGRectMake(padding, height-2*height/16+1, width/4*3, height/16)
                saveCollageButton.frame = CGRectMake(padding, height-3*height/16+2, width/4*3, height/16)
            }
            
            if CCCoreUtil.doesSaveRefImage == 1 {
                saveRefButton.setTitleColor(UIColor(hexNumber: 0x41AFFF), forState: .Normal)
            }
            else {
                saveRefButton.setTitleColor(UIColor(hexNumber: 0xAAAAAA), forState: .Normal)
            }

            if CCCoreUtil.doesSaveCollageImage == 1 {
                saveCollageButton.setTitleColor(UIColor(hexNumber: 0x41AFFF), forState: .Normal)
            }
            else {
                saveCollageButton.setTitleColor(UIColor(hexNumber: 0xAAAAAA), forState: .Normal)
            }
          
        }
        if (style == Style.CategoryList){
            background.addTarget(self, action: #selector(CCAlertViewController.closeAction), forControlEvents: .AllTouchEvents)

            // Title View
            let titleBackground = UIView()
            titleBackground.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
            view.addSubview(titleBackground)

            let titleLable = UILabel()
            titleLable.text = NSLocalizedString("ADDTOCATEGORY", comment: "Add to Category")
            titleLable.textColor = .whiteColor()
            view.addSubview(titleLable)

            // Table View
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.dataSource = self
            tableView.delegate = self
            view.addSubview(tableView)
            
            // Table View
            tableView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: view.frame.width/3*2))
            
            self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: view.frame.height/2))

        
            // Title Background constraint
            titleBackground.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: titleBackground, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: tableView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleBackground, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: tableView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleBackground, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: tableView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleBackground, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
            
            // Title constraint
            titleLable.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: titleBackground, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: titleBackground, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: titleBackground, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        }
        if (style == Style.ProgressBar){
            background.addTarget(self, action: #selector(CCAlertViewController.testAction), forControlEvents: .AllTouchEvents)

            let titleHeight : CGFloat = 30.0
            let height : CGFloat = 45.0

            // Alert Background View
            let alertBackground = UIView(frame: CGRectMake(50, view.frame.height/2 - 100 , view.frame.width-100, height + titleHeight))
            alertBackground.backgroundColor = .blackColor()
            alertBackground.layer.borderColor = UIColor(hex:0x41AFFF).CGColor
            alertBackground.layer.borderWidth = 0.5
            view.addSubview(alertBackground)
            
            
            // Title View
            let titleBackground = UIView(frame: CGRectMake(50+0.5, view.frame.height/2 - 100 + 0.5, view.frame.width-100 - 1, titleHeight))
            titleBackground.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
            view.addSubview(titleBackground)
            
            let titleLable = UILabel(frame: CGRectMake(50, view.frame.height/2 - 100, view.frame.width-100, titleHeight))
            titleLable.text = "Importing..."
            titleLable.textColor = .whiteColor()
            view.addSubview(titleLable)

            // Alert Background View
            progressBar.frame = CGRectMake(progressBarMargin, view.frame.height/2 - 100 + titleHeight + height/2 - 5, 0, 10)
            progressBar.backgroundColor = UIColor(hex:0x41AFFF)
            view.addSubview(progressBar)

        }

    }
}

// MARK: UITableViewDataSource

extension CCAlertViewController:UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CCCoreUtil.categories.count - 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let cellTitle = CCCoreUtil.categories[indexPath.row+1].name!
        cell.textLabel?.text = NSLocalizedString((cellTitle.uppercaseString), comment: cellTitle)
        cell.textLabel?.font = UIFont.systemFontOfSize(14.5)
        return cell
    }
}

// MARK: UITableViewDelegate

extension CCAlertViewController:UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = CCCoreUtil.categories[indexPath.row+1]
        CCCoreUtil.addPhotoForCategory(category as! CCCategory, image: self.image!)
        closeAction()
    }
}
