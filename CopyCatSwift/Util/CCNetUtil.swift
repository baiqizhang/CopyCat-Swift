//
//  CCNetUtil.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/31/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import CoreData


@objc class CCNetUtil:NSObject{

//    static let host = "http://ec2-52-21-52-152.compute-1.amazonaws.com:8080"
//    static let host = "http://54.84.135.175:3000/api/v0/"
    static let host = "http://copycatloadbalancer-426137485.us-east-1.elb.amazonaws.com/api/v0/"

    // MARK: User Feed
    static func parsePostFromJson(json:JSON) -> [CCPost]{
        var result = [CCPost]()
        for (_, subJson) in json {
            if let uri = subJson["imageUrl"].string {
                let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: CCCoreUtil.managedObjectContext)
                let post = NSManagedObject.init(entity: postEntity!, insertIntoManagedObjectContext: nil) as! CCPost

                post.photoURI = uri

                post.photoWidth = 1
                post.photoHeight = 1

                if let width = subJson["width"].int {
                    if let height = subJson["height"].int {
                        post.photoWidth = width
                        post.photoHeight = height
                    }
                }

                post.pinCount = 0//subJson["pinCount"].int
                post.likeCount = 0//subJson["likeCount"].int
                post.id = subJson["_id"].string
                post.userName = subJson["ownerId"]["name"].string
                post.userProfileImage = subJson["ownerId"]["profilePictureUrl"].string

                if let date = subJson["time"].string {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
                    dateFormatter.timeZone = NSTimeZone(name: "UTC")
                    post.timestamp = dateFormatter.dateFromString(date)
                } else {
                    post.timestamp = NSDate()
                }

                result.append(post)
            }
        }

        return result
    }

    static func parsePostFromInstagramJson(json:JSON) -> [CCPost]{
        var result = [CCPost]()
        for (_, subJson) in json["data"] {
            let photo = subJson["images"]["standard_resolution"]
            let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: CCCoreUtil.managedObjectContext)
            let post = NSManagedObject.init(entity: postEntity!, insertIntoManagedObjectContext: nil) as! CCPost

            post.userName = subJson["user"]["username"].stringValue
            post.userProfileImage = subJson["user"]["profile_picture"].stringValue

            post.photoURI = photo["url"].string

            post.photoWidth = 1
            post.photoHeight = 1

            if let width = photo["width"].int {
                if let height = photo["height"].int {
                    post.photoWidth = width
                    post.photoHeight = height
                }
            }

            post.pinCount = 0//subJson["pinCount"].int
            post.likeCount = 0//subJson["likeCount"].int
            post.id = "aaa"

            post.timestamp = NSDate(timeIntervalSince1970: subJson["caption"]["created_time"].doubleValue)

            result.append(post)
        }

        return result
    }

    static func getFeedForCurrentUser(completion:(posts:[CCPost]) -> Void) -> Void{
//        CCNetUtil.getJSONFromURL(host+"/api/post") { (json:JSON) -> Void in
        CCNetUtil.getJSONFromURL(host+"timeline") { (json:JSON) -> Void in
            let result = parsePostFromJson(json)
            completion(posts: result)
        }
    }


    static func refreshFeedForCurrentUser(id:String,completion:(posts:[CCPost]) -> Void) -> Void{
        let url = host+"timeline?count=5&sinceId=" + id
        let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
            let result = parsePostFromJson(json)
            completion(posts: result)
        }
    }

    static func loadMoreFeedForCurrentUser(id:String, completion:(posts:[CCPost]) -> Void) -> Void{
        let url = host+"timeline?count=5&maxId=" + id
        let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
            // NSLog("%@",json["data"].string!)
            completion(posts: parsePostFromJson(json))
        }
    }

    static func loadInstagramLikes(completion:(posts:[CCPost]) -> Void) -> Void{
        if let token = NSUserDefaults.standardUserDefaults().valueForKey("access_token"){
            let url = "https://api.instagram.com/v1/users/self/media/liked?access_token=" + (token as! String)
            let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
                let result = parsePostFromInstagramJson(json)
                completion(posts: result)
            }
        }
    }


    // new post
    static func newPost(image:UIImage,completion:(error: String?) -> Void){
        let imageData = UIImageJPEGRepresentation(image,0.8)//.resizeWithFactor(0.01), 0.8)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)

        var json = [String: AnyObject]()
        let _ = String(NSDate())
        json["data"] = base64String
        json["width"] = image.size.width
        json["height"] = image.size.height

        json["ownerId"] = CCUserManager.instagramUserInfo["cc_id"].string

        do{
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
//           HTTPPostJSON(host + "/api/post", data: data, callback: { (response, error) ->
            HTTPPostJSON(host + "photos", data: data, callback: { (response, error) -> Void in
                if let _ = error {
                    completion(error: "Connection Failed")
                    return
                }
                if let datastring = NSString(data:response!, encoding:NSUTF8StringEncoding) as String? {
                    NSLog("response:%@", datastring)
                    let json = JSON.parse(datastring)
                    if let _ = json["_id"].string{
                        completion( error: nil)
                    } else{
                        completion(error: "Connection Failed")
                    }
                }
            })
        } catch{

        }
    }


    //MARK: Get Helpers

    static func getJSONFromURL(url: String,completion:(json:JSON) -> Void){
        loadDataFromURL(NSURL(string: url)!, completion:{(data: NSData?, error: NSError?) -> Void in
            if let urlData = data {
                let json = JSON(data: urlData)
                NSLog("received json:%@",json.rawString()!)
                completion(json: json)
            }
        })
    }


    static func loadDataFromURL(url: NSURL, completion:(response: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()

        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url) {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if let responseError = error {
                    completion(response: nil, error: responseError)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        let statusError = NSError(domain:"com.copycat", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(response: nil, error: statusError)
                    } else {
                        completion(response: data, error: nil)
                    }
                }
        }
        loadDataTask.resume()
    }

    //MARK: Post Helpers

    static func HTTPsendRequest(request: NSMutableURLRequest, callback: (response:NSData?, error:NSError?) -> Void) {
        let task = NSURLSession.sharedSession()
        .dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if (error != nil) {
                callback(response: nil, error: error)
            } else {
                callback(response: data!, error:nil)
            }
        }
        task.resume()
    }

    static func HTTPPostJSON(url: String, data: NSData, callback: (response:NSData?, error:NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)

        request.HTTPMethod = "Post"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.HTTPBody = data
        HTTPsendRequest(request, callback: callback)
    }

}
