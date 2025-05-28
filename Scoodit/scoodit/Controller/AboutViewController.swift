//
//  AboutViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 1/22/17.
//  Copyright © 2017 Sergio Cardenas. All rights reserved.
//

import UIKit



class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goTofacebook()
    {
        let facebook_link = "https://www.facebook.com/scoodit"
        
        let url = URL(string: facebook_link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func goToTwitter()
    {
        let twitter_link = "https://twitter.com/Scoodit"
        
        let url = URL(string: twitter_link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    
    }
    
    @IBAction func goToInstagram()
    {
        let instagram_link = "https://www.instagram.com/scoodit/"
        
        let url = URL(string: instagram_link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    
    }
    
    @IBAction func goToYoutube()
    {
        let youtube_link = "https://www.youtube.com/scoodit"
        
        let url = URL(string: youtube_link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    
    }
    
    @IBAction func goToPinterest()
    {
        let pinterest_link = "https://ro.pinterest.com/scoodit/"
        
        let url = URL(string: pinterest_link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    

}
