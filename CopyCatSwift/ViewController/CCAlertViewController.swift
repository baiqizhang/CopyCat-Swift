//
//  CCAlertViewController.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 1/9/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class CCAlertViewController : UIViewController {
    let tableView = UITableView()
    var input : NSObject?

    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    override func viewDidLoad() {
        view.backgroundColor = .clearColor()
        
        let background = UIButton(frame: view.frame)
        background.backgroundColor = .blackColor()
        background.alpha = 0.75
        background.addTarget(self, action: "closeAction", forControlEvents: .AllTouchEvents)
        view.addSubview(background)

        // Title View
        let titleBackground = UIView()
        titleBackground.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.13, alpha: 1)
        view.addSubview(titleBackground)

        let titleLable = CCLabel()
        titleLable.text = "PIN TO CATEGORY"
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
        let image = input as! UIImage
        CCCoreUtil.addPhotoForCategory(category as! CCCategory, image: image)
        closeAction()
    }
}
