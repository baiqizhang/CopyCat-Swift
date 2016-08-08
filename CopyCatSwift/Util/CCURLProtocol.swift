//
//  CCURLProtocol.swift
//  CopyCatSwift
//
//  Created by Baiqi Zhang on 6/10/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import Foundation

var requestCount = 0

class CCURLProtocol: NSURLProtocol {
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        let url = request.URL!.absoluteString
//        print("Request #\(requestCount++): URL = \(url)")

        if let _ = url.rangeOfString("https://encrypted-tbn[\\s\\S]*", options: .RegularExpressionSearch) {
            CCCrawlViewController.sharedInstance().appendURL(url)
            print("Image : \(url)")
        }

        
        return false
    }
}