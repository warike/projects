//
//  NavBarButtonsExtension.swift
//  scoodit
//
//  Created by Sergio Cardenas on 4/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import SideMenu


extension UIViewController {
    
    func addMenuButton()
    {
        let menuButton = UIBarButtonItem(image: UIImage(named: bar_button_item_image), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.viewMenu(_:)))
        menuButton.tintColor = scoodit_color
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func addUserProfileButton()
    {
    
    let userButton = UIBarButtonItem(image: UIImage(named: bar_button_item_profile), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.viewProfile(_:)))
    userButton.tintColor = yellowApp
    self.navigationItem.rightBarButtonItem = userButton
    
    }
    
    func addCloseButton()
    {
        
        let closeButton = UIBarButtonItem(image: UIImage(named: bar_button_item_close), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.closeController(_:)))
        closeButton.tintColor = .white
        
        self.navigationItem.leftBarButtonItem = closeButton
        
    }
    
    @IBAction func closeController(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func logOut(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        var current = UIApplication.shared.keyWindow?.rootViewController
        while ((current?.presentedViewController) != nil) {
            current = current?.presentedViewController
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func viewMenu(_ sender: AnyObject){
        
        
        let appScreenRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NavMenuControllerMenu") as! UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
 
        

        
        
        SideMenuManager.menuWidth = max(round(min((appScreenRect.width), (appScreenRect.height)) * 0.9), 240)
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.present(vc, animated: true, completion: nil)

        
        
        
        
    }
    
    
    @IBAction func viewProfile(_ sender: AnyObject){
        
        let appScreenRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NavProfileControllerProfile") as! UISideMenuNavigationController
        
        
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuWidth = max(round(min((appScreenRect.width), (appScreenRect.height)) * 0.9), 240)
        
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(vc, animated: true, completion: nil)
        
    }
    
}
