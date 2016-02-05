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
            self.userDefault.setValue(newValue["access_token"].string, forKey: "access_token")
            self.userDefault.setValue(newValue["user"]["profile_picture"].string, forKey: "profile_picture")
            self.userDefault.setValue(newValue["user"]["username"].string, forKey: "user")
        
            self.userDefault.setInteger(1, forKey: "usertype")
        
        if let url = NSURL(string: newValue["user"]["profile_picture"].string!) {
            if let data = NSData(contentsOfURL: url) {
                CCCoreUtil.userPicture = UIImage(data: data)!
            }
        }
        
        
            NSLog("set Instagram user info = \(self.userDefault.valueForKey("profile_picture"))")
        }
        get {
            
            let a = JSON([
            "access_token": self.userDefault.valueForKey("access_token")!,
            "profile_picture": self.userDefault.valueForKey("profile_picture")!,
            "user": self.userDefault.valueForKey("user")!
                ])
            return a
        }
    }
    
}