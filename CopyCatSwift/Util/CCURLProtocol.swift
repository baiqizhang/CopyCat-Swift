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
        print("Request #\(requestCount++): URL = \(request.URL!.absoluteString)")
        return false
    }
}