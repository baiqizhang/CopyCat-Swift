//
//  InstagramLoginViewController.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 2/4/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit

class InstagramLoginViewController: UIViewController, UIWebViewDelegate {
    private let closeButton = UIButton()
    
    private var webView = UIWebView()
    private let CLIENTID = "ea2679a4073c4809919836b18e91b257"
    private let redirect_uri = "http://ec2-52-21-52-152.compute-1.amazonaws.com:8080/api/instagram/login"
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Close
        closeButton.frame = CGRectMake(5, -5, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png"), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: "closeAction", forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        
        
        
        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        //        let randomtail = random() % 10;
        let authorize_url = "https://api.instagram.com/oauth/authorize/?client_id=\(CLIENTID)&redirect_uri=\(redirect_uri)&response_type=code&scope=public_content"
        print(authorize_url)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: authorize_url)!))
        webView.delegate = self;
        self.view.addSubview(webView)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let body = webView.stringByEvaluatingJavaScriptFromString("document.body.firstChild.innerHTML")
        let a = JSON.parse(body!)
        if let token = a["access_token"].string {
            webView.loadHTMLString("<html></html>", baseURL: nil)
            NSLog("token = "+token)
            self.dismissViewControllerAnimated(true, completion: { })
            CCUserManager.instagramUserInfo = a;
        } else if let code = a["code"].int32 {
            webView.loadHTMLString("<html></html>", baseURL: nil)
            // alert
            let alertController = UIAlertController(
                title: "Error \(code)",
                message: "\(a["error_message"])",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            // add action
            alertController.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default,
                handler: {(paramAction:UIAlertAction!) in
                    // log out
                    CCUserManager.instagramUserInfo = nil
                    let url = NSURL(string: "http://instagram.com/accounts/logout")
                    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { _ in }
                    task.resume()
                    
                    // dismiss webView
                    self.dismissViewControllerAnimated(true, completion: { _ in })
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    
}
