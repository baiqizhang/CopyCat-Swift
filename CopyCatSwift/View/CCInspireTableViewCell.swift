//
//  CCInspireTableViewCell.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 1/2/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

@IBDesignable
class CCInspireTableViewCell : UITableViewCell {
    var userID = ""
    
    // Image
    private var count = 0
    let myImageView = UIImageView()
    
    private var _myImageURI = ""
    var myImageURI : String{
        set{
            _myImageURI = newValue
            
            self.myImageView.image = nil
            self.myImageView.alpha = 0
            count += 1
            myImageView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40);
            myImageView.contentMode = .ScaleAspectFill
            myImageView.clipsToBounds = true
            
            dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
                if let image = UIImage(named: newValue){
                    self.myImageView.image = image
                } else {
                    guard
                        let url = NSURL(string: newValue)
                        else {return}
                    NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
                        guard
                            let data = data where error == nil,
                            let image = UIImage(data: data)
                            else { return }
//                        image = image.resizeWithFactor(0.3)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.count -= 1
                            if self.count != 0 {
                                return
                            }
                            self.myImageView.image = image
                            UIView.animateWithDuration(0.5, animations: { () -> Void in
                                self.myImageView.alpha = 1
                            })
                            
                        }
                    }).resume()
                }
            }
        }
        get{
            return _myImageURI
        }
    }
    
    // Username
    private let usernameLabel = UILabel()
    private var _username = ""
    var username : String{
        set{
            _username = newValue
            usernameLabel.frame=CGRectMake(40,self.frame.size.height - 33.5, self.frame.size.width, 15)
            usernameLabel.text = newValue
            usernameLabel.textColor = .blackColor()//.blueColor()
            usernameLabel.font = UIFont.systemFontOfSize(13)
            usernameLabel.textAlignment = .Left
        }
        get{
            return _username
        }
    }
    
    
    // Timestamp
    private let timestampLabel = UILabel()
    var timestamp : NSDate{
        set{
            let now = Int(NSDate().timeIntervalSinceDate(newValue))
            
            timestampLabel.frame=CGRectMake(40,self.frame.size.height - 20, self.frame.size.width, 15)
            
            let agoString = NSLocalizedString("AGO", comment: " ago")
            
            if now<60{
                timestampLabel.text = String(now) + NSLocalizedString("SECOND", comment: "s") + agoString
            } else if now < 60*60{
                timestampLabel.text = String(now/60) + NSLocalizedString("MINUTE", comment: "min") + agoString
            } else if now < 60*60*24{
                timestampLabel.text = String(now/60/60) + NSLocalizedString("HOUR", comment: "h") + agoString
            } else if now < 60*60*24*365{
                timestampLabel.text = String(now/60/60/24) + " " + NSLocalizedString("DAY", comment: "days") + agoString
            } else if now < 60*60*24*365*12{
                timestampLabel.text = String(now/60/60/24/365) + " " + NSLocalizedString("MONTH", comment: "m") + agoString
            } else{
                timestampLabel.text = String(now/60/60/24/365/12) + " " + NSLocalizedString("YEAR", comment: "y") + agoString
            }
            
            timestampLabel.textColor = .blackColor()//.blueColor()
            timestampLabel.textAlignment = .Left
            timestampLabel.font = UIFont.systemFontOfSize(9)
        }
        get{
            //TODO fix
            return self.timestamp
        }
    }

    // Counts
    private let likeCountLabel = UILabel()
    var likeCount : Int{
        set{
            likeCountLabel.text = String(newValue)
        }
        get{
            //TODO fix
            return self.likeCount
        }
    }
    
    private let pinCountLabel = UILabel()
    var pcount: Int = 0
    var pinCount : Int{
        set{
            pinCountLabel.text = String(newValue)
            if newValue > 0 {
                pinCountLabel.alpha = 0.9
            }
            pcount = newValue
        }
        get{
            //TODO fix
            return pcount
        }
    }

    
    private let userImageView = UIImageView()
    private var _userImageURI = ""
    var userImageURI : String{
        set{
            _userImageURI = newValue
            dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
                guard
                    let url = NSURL(string: newValue)
                    else {return}
                NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
                    guard
                        let data = data where error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        let padding : CGFloat = -7.0
                        self.userImageView.image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(padding, padding, padding, padding))
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.userImageView.alpha = 1
                        })
                        
                    }
                }).resume()
            }
        }
        get{
            //TODO fix
            return self._userImageURI
        }
    }

    
    
    private let likeButton = UIButton()
    private let moreButton = UIButton()
    private let pinButton = UIButton()
    
    var delegate : CCInspireTableViewController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .whiteColor()
        
        self.userImageURI = ""

        myImageView.alpha = 0.0
        self.addSubview(usernameLabel)
        self.addSubview(myImageView)
        self.addSubview(timestampLabel)

        // User ImageView
        let padding : CGFloat = -7.0
        let image = UIImage(named: "AppIcon.png")?.imageWithAlignmentRectInsets(UIEdgeInsetsMake(padding, padding, padding, padding))
        userImageView.image = image
        userImageView.layer.borderWidth = 1.0
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userImageView.layer.cornerRadius = 20 + padding
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = UIColor.blackColor()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(CCInspireTableViewCell.showProfileAction))
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(userImageView)

        // Button Inset
        let buttonPadding : CGFloat = -10.0
        let inset = UIEdgeInsetsMake(buttonPadding, buttonPadding, buttonPadding, buttonPadding)
        
        // Like button
        likeButton.setBackgroundImage(UIImage(named: "like2.png")?.imageWithAlignmentRectInsets(inset), forState: .Normal)
        likeButton.setBackgroundImage(UIImage(named: "like2_highlight.png"), forState: .Highlighted)
        likeButton.addTarget(self, action: #selector(CCInspireTableViewCell.likeAction), forControlEvents: .TouchUpInside)
        //self.addSubview(likeButton)

        // More button
        moreButton.setBackgroundImage(UIImage(named: "more.png")?.imageWithAlignmentRectInsets(inset), forState: .Normal)
        moreButton.setBackgroundImage(UIImage(named: "more.png"), forState: .Highlighted)
        moreButton.addTarget(self, action: #selector(CCInspireTableViewCell.moreAction), forControlEvents: .TouchUpInside)
        self.addSubview(moreButton)
        
        // Pin button
        pinButton.setBackgroundImage(UIImage(named: "pin_black")?.imageWithAlignmentRectInsets(inset), forState: .Normal)
        pinButton.setBackgroundImage(UIImage(named: "pin_highlight.png"), forState: .Highlighted)
        pinButton.addTarget(self, action: #selector(CCInspireTableViewCell.pinAction), forControlEvents: .TouchUpInside)
        self.addSubview(pinButton)
        
        // Like count
        likeCountLabel.textColor = .blackColor()//.blueColor()
        likeCountLabel.textAlignment = .Left
        likeCountLabel.font = UIFont.systemFontOfSize(10.5)
//        self.addSubview(likeCountLabel)
        
        // Pin count
        pinCountLabel.textColor = .blackColor()//.blueColor()
        pinCountLabel.textAlignment = .Left
        pinCountLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 16.0)
        pinCountLabel.alpha = 1.0
        self.addSubview(pinCountLabel)

        
        // More button constraint
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: moreButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -5))
        
        addConstraint(NSLayoutConstraint(item: moreButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: moreButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: moreButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Pin button constraint
        pinButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: moreButton, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -15))

        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Pin Count Label constraint
        pinCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: pinButton, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -5))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 37.5))
        
        // User Image constraint
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: userImageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: userImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: userImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: userImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Action
    func pinAction(){
        if let image = myImageView.image{
            delegate?.pinAction(image, self.myImageURI)
            pinCount = pinCount + 1
        }
    }

    func likeAction(){
        delegate?.likeAction()
    }
    
    func moreAction(){
        delegate?.moreAction(self.myImageURI, reporterID: self.userID)
    }
    
    func showProfileAction() {
        delegate?.showProfileAction(self.userID, self._username, self.userImageURI)
    }

    /*
        make the cell as CardView. https://github.com/aclissold/CardView
    */
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.blackColor()
    @IBInspectable var shadowOpacity: Float = 0.5

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.CGColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.CGPath
    }
}
