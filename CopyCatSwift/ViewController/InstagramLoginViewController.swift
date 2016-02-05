//
//  InstagramLoginViewController.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 2/4/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class InstagramLoginViewController: UIViewController, UIWebViewDelegate {
    
    private var webView = UIWebView()
    private let CLIENTID = "ea2679a4073c4809919836b18e91b257"
    private let redirect_uri = "http://ec2-52-21-52-152.compute-1.amazonaws.com:8080/api/instagram/login"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let authorize_url = "https://api.instagram.com/oauth/authorize/?client_id=\(CLIENTID)&redirect_uri=\(redirect_uri)&response_type=code"
        webView.loadRequest(NSURLRequest(URL: NSURL(string: authorize_url)!))
        webView.delegate = self;
        self.view.addSubview(webView)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let body = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")
        let a = JSON.parse(body!)
        if let _ = a["access_token"].string {
            
            self.dismissViewControllerAnimated(true, completion: { })
            CCUserManager.instagramUserInfo = a;
            
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    

}
