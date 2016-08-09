//
//  CCNetUtil.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 12/31/15.
//  Copyright © 2015 Baiqi Zhang. All rights reserved.
//

import CoreData
import Kingfisher
import AwesomeCache
import Polyglot

@objc class CCNetUtil:NSObject{
//    static let host = "http://ec2-52-21-52-152.compute-1.amazonaws.com:8080"
//    static let host = "http://54.84.135.175:3000/api/v0/"
    static let host = "http://copycatloadbalancer-426137485.us-east-1.elb.amazonaws.com/api/v0/"
    static let myCache = ImageCache(name: "all_image_cache")
    static let imageDownloader = ImageDownloader(name: "user_profile_downloader")
    static var searchResCache = try! Cache<NSData>(name: "resCache")
    
    
    static let hitTags = Set(["pose"]);

    static func getHottag()->[String]{
        let preferredLanguage = NSLocale.preferredLanguages()[0] as String
        if preferredLanguage.hasPrefix("zh-Hans") {
            return ["Pose","咖啡", "情侣", "建筑","早餐","海滩","秋天"]
        }
        
        return ["Pose","Dog", "Hiker", "Coffee","Couple","Macbook","Sign","Grassland"]
    }
    
    // MARK: Parsing User Feed
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

                post.pinCount = subJson["like"].int
                post.likeCount = subJson["like"].int
                post.id = subJson["_id"].string
                post.userID = subJson["ownerId"]["_id"].string
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

            post.pinCount = 0
            post.likeCount = 0
            post.id = "nil"

            post.timestamp = NSDate(timeIntervalSince1970: subJson["caption"]["created_time"].doubleValue)

            result.append(post)
        }

        return result
    }
    
    
    
    static func parsePostFromUnsplashJson(json:JSON) -> [CCPost]{
        var result = [CCPost]()
        for (_, subJson) in json{
            let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: CCCoreUtil.managedObjectContext)
            let post = NSManagedObject.init(entity: postEntity!, insertIntoManagedObjectContext: nil) as! CCPost
            
//            post.userName = subJson["user"]["name"].stringValue
//            post.userProfileImage = subJson["user"]["profile_image"]["small"].stringValue
            
            post.photoURI = subJson["urls"]["small"].string
            
            post.photoWidth = 1
            post.photoHeight = 1
            
            post.pinCount = 0//subJson["pinCount"].int
            post.likeCount = 0//subJson["likeCount"].int
            post.id = "nil"
            
            
            //parse timestamp
            if let date = subJson["created_at"].string {
                let RFC3339DateFormatter = NSDateFormatter()
                RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            
                post.timestamp = RFC3339DateFormatter.dateFromString(date)
            } else {
                post.timestamp = NSDate()
            }

            result.append(post)
        }
        
        return result
    }

    static func parsePostFromFlickrJson(json:JSON) -> [CCPost]{
        var result = [CCPost]()
        for (_, subJson) in json["photos"]["photo"]{
            let postEntity = NSEntityDescription.entityForName("Post", inManagedObjectContext: CCCoreUtil.managedObjectContext)
            let post = NSManagedObject.init(entity: postEntity!, insertIntoManagedObjectContext: nil) as! CCPost
            
            
            let id = subJson["id"].stringValue
            let secret = subJson["secret"].stringValue
            let server = subJson["server"].stringValue
            let farm = subJson["farm"].stringValue
            
            post.photoURI = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_c.jpg"
            
            post.userName = "Flickr"
            post.userProfileImage = "https://lh5.ggpht.com/JNba5eiZjaaS7SxI3uBoEnW9PQtD5paoHest5KO2KW2GDHIaEqaUPvFsuylTNxkeeA=w300"
            
            
            post.photoWidth = 1
            post.photoHeight = 1
            
            post.pinCount = 0//subJson["pinCount"].int
            post.likeCount = 0//subJson["likeCount"].int
            post.id = "nil"
            
            
            //parse timestamp
            let RFC3339DateFormatter = NSDateFormatter()
            RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

            post.timestamp = RFC3339DateFormatter.dateFromString("2013-12-06T07:28:13-05:00")
            
            result.append(post)
        }
        
        return result
    }
    
    // MARK: Getting data
    static func getFeedForCurrentUser(completion:(posts:[CCPost]) -> Void) -> Void{
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
    
    static func searchUnsplashTranslated(tag:String, completion:(posts:[CCPost]?) -> Void) -> Void{
        let copyCatUrl = "http://ec2-52-42-208-246.us-west-2.compute.amazonaws.com:3001/api/v1/search?labels=\(tag.lowercaseString)"
        let unsplashUrl = "https://api.unsplash.com/photos/search?query="+tag.lowercaseString+"&per_page=50&&client_id=6aeca0a320939652cbb91719382190478eee706cdbd7cfa8774138a00dd81fab"
        if let cachedJSON = searchResCache[copyCatUrl] {
            let result = parsePostFromUnsplashJson(JSON(data: cachedJSON))
            completion(posts: result)
            return
        } else if let cachedJSON = searchResCache[unsplashUrl] {
            let result = parsePostFromUnsplashJson(JSON(data: cachedJSON))
            completion(posts: result)
            return
        }
        if (hitTags.contains(tag.lowercaseString)) {
            var encodedUrl = copyCatUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
                if json != nil {
                    let result = parsePostFromUnsplashJson(json)
                    completion(posts: result)
                } else {
                    encodedUrl = unsplashUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                    CCNetUtil.getJSONFromURL(encodedUrl!) { (unJson:JSON) -> Void in
                        if (unJson == nil) {
                            completion(posts: nil)
                        }
                        let result = parsePostFromUnsplashJson(unJson)
                        completion(posts: result)
                    }
                }
            }
        } else {
            let encodedUrl = unsplashUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            CCNetUtil.getJSONFromURL(encodedUrl!) { (unJson:JSON) -> Void in
                if (unJson == nil) {
                    completion(posts: nil)
                }
                let result = parsePostFromUnsplashJson(unJson)
                completion(posts: result)
            }
        }
        
    }
    
    static func searchUnsplash(tag:String, completion:(posts:[CCPost]?) -> Void) -> Void{
        let preferredLanguage = NSLocale.preferredLanguages()[0] as String
        if preferredLanguage.hasPrefix("en") || (hitTags.contains(tag.lowercaseString)) {
            searchUnsplashTranslated(tag, completion: completion)
        } else {
            //translage to en
            let translator = Polyglot(clientId: "copycat", clientSecret: "UUwOEXGR919dCnmgar9NKYsT1x/OT1PllpWgAX0Zmqw=")
            translator.translate(tag) { translation in
                searchUnsplashTranslated(translation, completion: completion)
            }
        }
        
    }
    
    
    static func searchGPS(lat:Double,lon:Double,completion:(posts:[CCPost]) -> Void) -> Void{
//        let lat = 37.7749
//        let lon = 122.41
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f91a179a286be8256e0ca7624f254642&lat=\(lat)&lon=\(lon)&radius=0.2&format=json&nojsoncallback=1"
        let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
            let result = parsePostFromFlickrJson(json)
            completion(posts: result)
        }
    }
    
    
    static func searchGPSByAddressString(addressStr: String,completion:(posts:[CCPost]?) -> Void) -> Void{
        let url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(addressStr)"
        let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
            for (_, subJson) in json["results"]{
                guard let lat = subJson["geometry"]["location"]["lat"].double else {
                    completion(posts: [])
                    return
                }
                guard let lon = subJson["geometry"]["location"]["lng"].double else {
                    completion(posts: [])
                    return
                }
                let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f91a179a286be8256e0ca7624f254642&lat=\(lat)&lon=\(lon)&radius=0.2&format=json&nojsoncallback=1"
                let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                CCNetUtil.getJSONFromURL(encodedUrl!) { (json:JSON) -> Void in
                    if (json == nil) {
                        completion(posts: nil);
                    }
                    let result = parsePostFromFlickrJson(json)
                    completion(posts: result)
                }
                break
            }
        }
        
    }


    
    //MARK: Posting data
    
    static func feelLucky(image:UIImage,completion:(error: String?) -> Void){
        //resize before sending
        let maxdim = max(image.size.width, image.size.height)
        let mindim = min(image.size.width, image.size.height)
        var resizedImage = image
        if maxdim > 320 && mindim > 120{
            let ratio = Float(720.0 / maxdim)
            resizedImage = image.resizeWithFactor(ratio)
        }
        
        //base64 encoding
        let imageData = UIImageJPEGRepresentation(resizedImage,0.8)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        var json = [String: AnyObject]()
        let _ = String(NSDate())
        json["data"] = base64String
        
        do{
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
            //           HTTPPostJSON(host + "/api/post", data: data, callback: { (response, error) ->
            HTTPPostJSON(host + "smart", data: data, callback: { (response, error) -> Void in
                if let _ = error {
                    completion(error: "Connection Failed")
                    return
                }
                if let datastring = NSString(data:response!, encoding:NSUTF8StringEncoding) as String? {
                    NSLog("response:%@", datastring)
                    let json = JSON.parse(datastring)
                    if let _ = json["labels"].array{
                        completion( error: nil)
                    } else{
                        completion(error: "Connection Failed")
                    }
                }
            })
        } catch{
            
        }
    }
    
    
    static func newPost(image:UIImage,completion:(error: String?) -> Void){
        //resize before sending
        let maxdim = max(image.size.width, image.size.height)
        let mindim = min(image.size.width, image.size.height)
        var resizedImage = image
        if maxdim > 720 && mindim > 360{
            let ratio = Float(720.0 / maxdim)
            resizedImage = image.resizeWithFactor(ratio)
        }
        
        //base64 encoding
        let imageData = UIImageJPEGRepresentation(resizedImage,0.8)
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
    
    static func sendPin(userId: String?, imageId: String) {
        var json = [String: AnyObject]()
        if userId != nil {
            json["userId"] = userId!
        }
        json["photoId"] = imageId
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
            HTTPPostJSON(host + "photos/like", data: data, callback: {(response, error) -> Void in
                if let _ = error {
                    NSLog("Pin Failed!")
                    return
                }

                if let datastring = NSString(data:response!, encoding:NSUTF8StringEncoding) as String? {
                    NSLog("response:%@", datastring)
                    if datastring.containsString("OK"){
                        NSLog("Pined!!!!")
                    } else {
                        NSLog("Not OK!!!")
                        NSLog(datastring)
                    }
                    
                }
            })
        } catch {
            
        }
    }

    static func sendFeedback(content:String, completion:(error:String?) -> Void) -> Void{
        let message = SMTPMessage()
        message.from = "copycatsvteam@gmail.com"
        message.to = "copycatsvteam@gmail.com"
        message.host = "smtp.gmail.com"
        message.account = "copycatsvteam@gmail.com"
        message.pwd = "copycatteam"
        
        message.subject = "Feedback"
        message.content = content
        
        message.send({ (message, now, total) in
            NSLog("Sending feedback")
            }, success: { (message) in
                NSLog("Email sent")
        }) { (message, error) in
            NSLog("Error:%@",error)
        }
    }
    
    static func sendReport(imageId:String, userId:String, content:String, completion:(error:String?) -> Void) -> Void {
        var json = [String: AnyObject]()
        let _ = String(NSDate())
        
        var content = [String: AnyObject]()
        content["reportType"] = ""
        content["contentType"] = "photo"
        content["contentId"] = imageId
        json["content"] = content
        
        var reporter = [String: AnyObject]()
        reporter["ownerId"] = userId
        reporter["reporterEmail"] = ""
        json["reporter"] = reporter
        
        print(json)
        
        do{
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
            HTTPPostJSON(host + "reports", data: data, callback: { (response, error) -> Void in
                if let _ = error {
                    completion(error: "Connection Failed")
                    return
                }
                if let datastring = NSString(data:response!, encoding:NSUTF8StringEncoding) as String? {
                    NSLog("response:%@", datastring)
                    if datastring.containsString("Issued"){
                        completion( error: nil)
                    } else {
                        completion( error: datastring)
                    }
                    
                }
            })
        } catch{
            
        }
    }
    
    static func loadPostByUsername(username:String, completion:(images:[String]) -> Void) {
        let url = host + "users/" + username + "/photos"
        getJSONFromURL(url, completion: {(json:JSON) -> Void in
            let posts = self.parsePostFromJson(json)
            var arr = [String]()
            for ccpost in posts {
                arr.append(ccpost.photoURI!)
            }
            completion(images: arr)
        })
    }

    

    //MARK: HTTP Get Helpers

    static func getJSONFromURL(url: String,completion:(json:JSON) -> Void){
        loadDataFromURL(NSURL(string: url)!, completion:{(data: NSData?, error: NSError?) -> Void in
            if let urlData = data {
                let json = JSON(data: urlData)
                searchResCache.setObject(urlData, forKey: url, expires: .Seconds(86400))
                NSLog("received json:%@",json.rawString()!)
                completion(json: json)
            } else {
                completion(json: nil)
            }
        })
    }
    
    static func loadImage(rawUrl:String, completion: (data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void) {
        let url = NSURL(string: rawUrl)!
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    static func loadImageWithCache(rawUrl:String, myImageView: UIImageView) {
        let url = NSURL(string: rawUrl)!
        myImageView.kf_showIndicatorWhenLoading = true
        myImageView.kf_setImageWithURL(url, optionsInfo: [.TargetCache(myCache)])
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

    //MARK: HTTP Post Helpers

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
