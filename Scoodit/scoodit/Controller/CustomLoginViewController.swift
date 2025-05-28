//
//  CustomLoginViewController.swift
//  scoodit
//
//  Created by RWBook Retina on 1/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import Foundation
import ParseUI

class CustomLoginViewController : PFLogInViewController {
    
    var backgroundImage : UIImageView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let logo = UILabel()
        logo.text = "Scoodit"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "Pacifico", size: 70)
        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        
        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.logInButton?.backgroundColor = UIColor(red: 52/255, green: 191/255, blue: 73/255, alpha: 1)
        
        
        logInView?.passwordForgottenButton?.titleLabel?.shadowColor = UIColor.lightGrayColor()
        logInView?.passwordForgottenButton?.titleLabel?.shadowOffset = CGSizeMake(2, 2)
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        logInView?.passwordForgottenButton?.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        
        customizeButton(logInView?.facebookButton!)
        customizeButton(logInView?.twitterButton!)
        customizeButton(logInView?.signUpButton!)
        
       
        backgroundImage = UIImageView(image: UIImage(named: "salmon_background"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.logInView!.insertSubview(backgroundImage, atIndex: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)

        backgroundImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
    }
    
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    }
    
}