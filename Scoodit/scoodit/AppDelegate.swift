//
//  AppDelegate.swift
//  scoodit
//
//  Created by RWBook Retina on 1/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import UserNotifications

import FBSDKCoreKit
import TwitterKit

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AWSCore
import AWSS3
let statusBarBackgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AmazonHelper {
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        LibraryAPI.sharedInstance.initLoading()
        
        AWSServiceManager.default().defaultServiceConfiguration = getConfiguration(from: regionType, pool_id: pool_id)
    
        
        UITabBar.appearance().backgroundColor = scoodit_menu_color
        UITabBar.appearance().tintColor = scoodit_color
        UITabBar.appearance().shadowImage = UIImage()
        
        if let font = UIFont(name: "TitilliumWeb", size: 20) {
            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], for: .selected)
        }
        
    
        
        UINavigationBar.appearance().barTintColor = scoodit_menu_color
        UINavigationBar.appearance().tintColor = scoodit_color
        UINavigationBar.appearance().shadowImage = UIImage()
        
        
        
        application.statusBarStyle = .default
        
        statusBarBackgroundView.backgroundColor = scoodit_menu_color
        statusBarBackgroundView.tintColor = .black
        
        window?.rootViewController?.view.addSubview(statusBarBackgroundView)
        window?.rootViewController?.view.addConstraintsWithFormat("H:|[v0]|", views: statusBarBackgroundView)
        window?.rootViewController?.view.addConstraintsWithFormat("V:|[v0(20)]", views: statusBarBackgroundView)
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Twitter.sharedInstance().start(withConsumerKey: <CONSUMER_KEY>, consumerSecret: <CONSUMER_SECRET>)
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            UNUserNotificationCenter.current().delegate = self
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: .firInstanceIDTokenRefresh, object: nil)
        
        if LibraryAPI.sharedInstance.existUserInMemory()
        {
            let maintabbarcontroller = "MainTabBarController"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: maintabbarcontroller) as! UITabBarController
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }else
        {
            
            INotificationView.shared.showInitLoading((window?.rootViewController?.view)!, text: "Initializing")
        }
        
        return true
    }
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let push_3010 = "Push notifications are not supported in the iOS Simulator."
        let push_success = "application:didFailToRegisterForRemoteNotificationsWithError: %@"
        if error._code == 3010 {
            print( push_3010 )
        } else {
            print( push_success , error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        print("%@", userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        LibraryAPI.sharedInstance.setDeviceToken(deviceToken)
        
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let _ = FIRInstanceID.instanceID().token() {
            
        }
        connectToFcm()
    }
    
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let _ = notification.request.content.userInfo

    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
    }
}
