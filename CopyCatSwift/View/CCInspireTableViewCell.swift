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
    // Image
    private var count = 0
    let myImageView = UIImageView()
    var myImageURI : String{
        set{
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
                            var image = UIImage(data: data)
                            else { return }
//                        image = image.resizeWithFactor(0.3)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.count--
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
            return self.myImageURI
        }
    }
    
    // Username
    private let usernameLabel = UILabel()
    var username : String{
        set{
            usernameLabel.frame=CGRectMake(40,self.frame.size.height - 33.5, self.frame.size.width, 15)
            usernameLabel.text = newValue
            usernameLabel.textColor = .blackColor()//.blueColor()
            usernameLabel.font = UIFont.systemFontOfSize(13)
            usernameLabel.textAlignment = .Left
        }
        get{
            return self.username
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
                timestampLabel.text = String(now/60/60/24) + NSLocalizedString("DAY", comment: "days") + agoString
            } else {
                timestampLabel.text = String(now/60/60/24/365/12) + NSLocalizedString("MONTH", comment: "m") + agoString
            }
            
            timestampLabel.textColor = .blackColor()//.blueColor()
            timestampLabel.textAlignment = .Left
            timestampLabel.font = UIFont.systemFontOfSize(9)
        }
        get{
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
            return self.likeCount
        }
    }
    
    private let pinCountLabel = UILabel()
    var pcount: Int = 0
    var pinCount : Int{
        set{
            pinCountLabel.text = String(newValue)
            if newValue > 0 {
                pinCountLabel.alpha = 1
            }
            pcount = newValue
        }
        get{
            return pcount
        }
    }

    
    private let userImageView = UIImageView()
    var userImageURI : String{
        set{
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
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.userImageView.alpha = 1
                        })
                        
                    }
                }).resume()
            }
        }
        get{
            return self.userImageURI
        }
    }

    
    
    private let likeButton = UIButton()
    private let pinButton = UIButton()
    
    var delegate : CCInspireTableViewController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .whiteColor()

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
        self.addSubview(userImageView)

        // Button Inset
        let buttonPadding : CGFloat = -10.0
        let inset = UIEdgeInsetsMake(buttonPadding, buttonPadding, buttonPadding, buttonPadding)
        
        // Like button
        likeButton.setBackgroundImage(UIImage(named: "like2.png")?.imageWithAlignmentRectInsets(inset), forState: .Normal)
        likeButton.setBackgroundImage(UIImage(named: "like2_highlight.png"), forState: .Highlighted)
        likeButton.addTarget(self, action: "likeAction", forControlEvents: .TouchUpInside)
        likeButton.alpha=0
        self.addSubview(likeButton)

        // Pin button
        pinButton.setBackgroundImage(UIImage(named: "pin_black")?.imageWithAlignmentRectInsets(inset), forState: .Normal)
        pinButton.setBackgroundImage(UIImage(named: "pin_highlight.png"), forState: .Highlighted)
        pinButton.addTarget(self, action: "pinAction", forControlEvents: .TouchUpInside)
        self.addSubview(pinButton)
        
        // Like count
        likeCountLabel.textColor = .blackColor()//.blueColor()
        likeCountLabel.textAlignment = .Left
        likeCountLabel.alpha = 0
        self.addSubview(likeCountLabel)
        
        // Pin count
        pinCountLabel.textColor = .blackColor()//.blueColor()
        pinCountLabel.textAlignment = .Left
        pinCountLabel.font.fontWithSize(20)
        pinCountLabel.alpha = 0
        self.addSubview(pinCountLabel)

        
        // Like button constraint
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -40))
    
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: likeButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Like Count Label constraint
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: likeCountLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: likeButton, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: likeCountLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: likeCountLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: likeCountLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))

        // Pin button constraint
        pinButton.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -15))

//        pinButton.translatesAutoresizingMaskIntoConstraints = false
//        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: likeButton, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -30))
//        
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: pinButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Pin Count Label constraint
        pinCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: pinButton, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: pinCountLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
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
            delegate?.pinAction(image)
        }
    }

    func likeAction(){
        delegate?.likeAction()
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
