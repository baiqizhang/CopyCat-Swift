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
    }
    var style : Style?
    
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
    
    override func viewDidLoad() {
        view.backgroundColor = .clearColor()
        
        let background = UIButton(frame: view.frame)
        background.backgroundColor = .blackColor()
        background.alpha = 0.75
        view.addSubview(background)

        if (style == Style.CategoryList){
            background.addTarget(self, action: "closeAction", forControlEvents: .AllTouchEvents)

            // Title View
            let titleBackground = UIView()
            titleBackground.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
            view.addSubview(titleBackground)

            let titleLable = UILabel()
            titleLable.text = "Add to Category"
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
            background.addTarget(self, action: "testAction", forControlEvents: .AllTouchEvents)

            let titleHeight : CGFloat = 30.0
            
            // Title View
            let titleBackground = UIView(frame: CGRectMake(50, view.frame.height/2 - 100, view.frame.width-100, titleHeight))
            titleBackground.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
            view.addSubview(titleBackground)
            
            let titleLable = UILabel(frame: CGRectMake(50, view.frame.height/2 - 100, view.frame.width-100, titleHeight))
            titleLable.text = "Importing..."
            titleLable.textColor = .whiteColor()
            view.addSubview(titleLable)

            let height : CGFloat = 45.0
            // Alert Background View
            let alertBackground = UIView(frame: CGRectMake(50, view.frame.height/2 - 100 + titleHeight, view.frame.width-100, height))
            alertBackground.backgroundColor = .blackColor()
            view.addSubview(alertBackground)

            // Alert Background View
            progressBar.frame = CGRectMake(progressBarMargin, view.frame.height/2 - 100 + titleHeight + height/2 - 5, 0, 10)
            progressBar.backgroundColor = UIColor.hexStringToColor("#41AFFF")
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
        cell.textLabel?.text = CCCoreUtil.categories[indexPath.row+1].name
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
