//
//  UserManager.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 2/4/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import Foundation


class CCUserManager: NSObject {
    
    static let userDefault = NSUserDefaults.standardUserDefaults()
    
    static var instagramUserInfo: JSON {
        set {
            if newValue==nil{
                self.userDefault.removeObjectForKey("access_token")
                self.userDefault.removeObjectForKey("profile_picture")
                self.userDefault.removeObjectForKey("user")
                self.userDefault.removeObjectForKey("user_id")
                self.userDefault.setInteger(0, forKey: "usertype")
        
                return;
            }
            
            let ig = newValue["instagram"]
            if ig != nil {
                self.userDefault.setValue(ig["access_token"].string, forKey: "access_token")
                self.userDefault.setValue(ig["user"]["profile_picture"].string, forKey: "profile_picture")
                self.userDefault.setValue(ig["user"]["username"].string, forKey: "user")
                self.userDefault.setValue(ig["user"]["id"].string, forKey: "user_id")
                self.userDefault.setInteger(1, forKey: "usertype")
                if let url = NSURL(string: ig["user"]["profile_picture"].string!) {
                    if let data = NSData(contentsOfURL: url) {
                        CCCoreUtil.userPicture = UIImage(data: data)!
                    }
                }
            }
            // set copycat user id (ownerId)
            self.userDefault.setValue(newValue["copycat"]["_id"].string, forKey: "cc_id")
        
            NSLog("set Instagram user info = \(self.userDefault.valueForKey("profile_picture"))")
        }
        get {
            // first time user
            guard let _ = self.userDefault.valueForKey("usertype")
                else {
                    return JSON([])
                }
            
            if self.userDefault.valueForKey("usertype") as! Int == 1 {
                let a = JSON([
                        "access_token": self.userDefault.valueForKey("access_token")!,
                        "profile_picture": self.userDefault.valueForKey("profile_picture") ?? "",
                        "user": self.userDefault.valueForKey("user") ?? "",
                        "user_id": self.userDefault.valueForKey("user_id") ?? "",
                        "cc_id": self.userDefault.valueForKey("cc_id") ?? ""
                ])
                return a
            } else {
                return JSON([])
            }
        }
    }
    
    static var usertype: Int {
        get {
           return self.userDefault.valueForKey("usertype") as! Int
        }
    }

    static var pinCount : NSNumber {
        set {
            self.userDefault.setValue(newValue, forKey: "pin_count")
        }
        get {
            if let count = self.userDefault.valueForKey("pin_count"){
                return count as! NSNumber
            } else {
                self.userDefault.setValue(NSNumber(int: 0), forKey: "pin_count")
                return 0
            }
        }
        
    }

    static var postCount : NSNumber {
        set {
            self.userDefault.setValue(newValue, forKey: "post_count")
        }
        get {
            if let count = self.userDefault.valueForKey("post_count"){
                return count as! NSNumber
            } else {
                self.userDefault.setValue(NSNumber(int: 0), forKey: "post_count")
                return 0
            }
        }
        
    }

}