//
//  InstagramLoginViewController.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 2/4/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class CCCrawlViewController: UIViewController, UIWebViewDelegate {
    var url = "https://www.google.com/imghp?as_st=y&tbm=isch&hl=en&as_q=&as_epq=&as_oq=&as_eq=&cr=&as_sitesearch=&safe=active&tbs=sur:f"  //"http://www.bing.com/images"

    static let sharedVC = CCCrawlViewController()
    private var crawledURL : [String] = []
    
    private let closeButton = UIButton()
    private var webView = UIWebView()
    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView : UICollectionView?
    
    
    //MARK: Crawl
    static func sharedInstance() -> CCCrawlViewController{
        return sharedVC
    }
    func appendURL(url:String){
        dispatch_async(dispatch_get_main_queue()) {
            if self.crawledURL.contains(url){
                return
            }
            self.crawledURL.insert(url, atIndex: 0)
            
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
        }
        
    }
    
    
    
    //MARK: Actions
    func closeAction() {
        self.dismissViewControllerAnimated(true, completion: { _ in })
        resetBrowser()
    }
    func resetBrowser(){
        let preferredLanguage = NSLocale.preferredLanguages()[0] as String
        if preferredLanguage == "zh-Hans-CN" {
            url = "http://image.baidu.com/"
        }
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
    
    //MARK: Lifecycle
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CCCrawlViewController.sharedInstance().crawledURL = []
        
        //Webview
        let len = 2*(self.view.frame.size.width-4)/4.0+3
        webView.frame = CGRectMake(0, 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-len-30-30)
        webView.delegate = self
        self.view.addSubview(webView)
        
        let label = UILabel(frame:CGRectMake(0,UIScreen.mainScreen().bounds.height-len-30,UIScreen.mainScreen().bounds.width,30))
        label.text = NSLocalizedString("Crawled Image", comment: "")
        label.textColor = UIColor(hex: 0x222222)
        label.font = UIFont.systemFontOfSize(14)
        view.addSubview(label)
        
        let bar1 = UIView(frame:CGRectMake(0,UIScreen.mainScreen().bounds.height-len-30,UIScreen.mainScreen().bounds.width,1))
        bar1.backgroundColor = UIColor(hex: 0x888888)
        view.addSubview(bar1)
        
        let bar2 = UIView(frame:CGRectMake(0,UIScreen.mainScreen().bounds.height-len,UIScreen.mainScreen().bounds.width,1))
        bar2.backgroundColor = UIColor(hex: 0x888888)
        view.addSubview(bar2)
        
        //Close
        closeButton.frame = CGRectMake(5, -5, 40, 40)
        closeButton.setBackgroundImage(UIImage(named: "close.png")?.maskWithColor(UIColor(hex:0x111111)), forState: .Normal)
        closeButton.setBackgroundImage(UIImage(named: "close_highlight.png"), forState: .Highlighted)
        closeButton.addTarget(self, action: #selector(CCCrawlViewController.closeAction), forControlEvents: .TouchUpInside)
        view!.addSubview(closeButton)
        

        
        //Collection
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 2
        flowLayout.scrollDirection = .Horizontal
        
        collectionView = CCCollectionView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - len, self.view.frame.size.width, len), collectionViewLayout: self.flowLayout)
        collectionView!.registerClass(CCCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = .clearColor()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        self.view!.addSubview(self.collectionView!)
        
        view.backgroundColor = .whiteColor()
        
        resetBrowser()
        
        let alert = UIAlertView(title: NSLocalizedString("Photo Crawler", comment: ""), message: NSLocalizedString("The upper part is a web browser. Click on crawled photo below to start CopyCatting", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Got it", comment: ""))
        alert.show()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
    }
    
    
}




// MARK: UICollectionViewDelegate

extension CCCrawlViewController:UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let url = crawledURL[indexPath.row]
        CCNetUtil.loadImage(url) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else {
                    print(error)
                    return
                }
                let overlayImage = UIImage(data: data)
                
                // show animation each time user re-enter categoryview
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.removeObjectForKey("isFirstTimeUser")
                userDefault.synchronize()
                
                let detailedView = CCInspireDetailViewController(image: overlayImage!)
                detailedView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                detailedView.parent = self
                self.presentViewController(detailedView, animated: true, completion: { _ in })
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension CCCrawlViewController:UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return crawledURL.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CCCollectionViewCell
        
//        cell.backgroundColor = .clearColor()
        cell.initWithNetworkUrlWithoutCache(crawledURL[indexPath.row])

        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CCCrawlViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 0, 0, 0)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let len = (self.view.frame.size.width-5)/4.0
        let retval = CGSizeMake(len, len)
        return retval
    }
}

