//
//  NutritionsViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 9/29/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RecipeDirectionsViewController: UIViewController, IndicatorInfoProvider, UIWebViewDelegate  {

    var itemInfo: IndicatorInfo = "View"
    var url = "http://web.intelag.net"
    var webView = UIWebView(frame: CGRect(x:0,y: 0,width: 0, height: 0))
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.loadWebsite()
        self.view.addSubview(webView)

    }
    
    func loadWebsite()
    {
        let urlRequest = URL(string: url)!
        let request = NSURLRequest(url: urlRequest) as URLRequest
        webView.loadRequest(request)
        webView.scalesPageToFit = true
        webView.delegate = self;
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillLayoutSubviews() {
        
        let width = view.frame.size.width
        let height = view.frame.size.height + 20
        webView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
    }


}
