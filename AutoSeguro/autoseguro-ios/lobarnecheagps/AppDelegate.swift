//
//  AppDelegate.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var gps_id :String = String()
    var patente_id :String = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        sleep(2);
        
        Parse.setApplicationId("8sACuF9TPHKNhQyYEeAXJNRpbXIaBJYQiPZk1vit", clientKey: "FgVvg50qfx2O7cltplhbSSImWLHw4gVBC8at5ZNH")
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        if #available(iOS 8.0, *)
        {
            
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else if iOS7 {
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
        
        if(UserDefaults.standard.object(forKey: "usuario") != nil)
        {
            var usuarioDataEncoded: [Data] = UserDefaults.standard.object(forKey: "usuario") as! [Data]
            var unpackedUsuario: String = String("Masivo")
            
            let unpackedIlogin: String = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[0] as Data) as! String
            let unpackedIpassword: String = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[1] as Data) as! String
            let unpackedTipo: Int = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[2] as Data) as! Int
            let unpackedRecordar: Int = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[3] as Data) as! Int
            let unpackedDemo: Int = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[4] as Data) as! Int

            if usuarioDataEncoded.count > 5 {
                unpackedUsuario = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[5] as Data) as! String
            }
            let usuario: Usuario = Usuario(ilogin: unpackedIlogin, ipassword: unpackedIpassword, tipo: unpackedTipo, recordar: unpackedRecordar, usuario: unpackedUsuario, demo: unpackedDemo)
            
            LibraryAPI.sharedInstance.setUsuario(usuario)
            
            if let options = launchOptions {
                if (options[UIApplicationLaunchOptionsKey.remoteNotification] != nil) {
                    if let launchOptions = launchOptions {
                        
                        
                        
                        let notificationPayload: NSDictionary = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as! NSDictionary
                        let notificacion_id :String = notificationPayload["notificacionId"] as! String
                        let patente_id: String = notificationPayload["patente_id"] as! String
                        
                        if  !notificacion_id.isEmpty {
        
                            let gps_id: String = notificacion_id
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "MapaUbicacionViewController") as! MapaUbicacionViewController
                            let viewController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "FrontViewController") as! UINavigationController
                            
                            vc._vehiculoDTO = Vehiculo(patente_id: patente_id, gps_id: gps_id, nombre_id: "")
                            self.window?.rootViewController = viewController
                            self.window?.makeKeyAndVisible()
                            self.window?.rootViewController?.present(vc, animated: false, completion: nil)
                            
                            return true
                        }
                        else if patente_id == "0000"
                        {
                            
                            
                            let aps: NSDictionary = notificationPayload["aps"] as! NSDictionary
                            let alert_msg: String = aps["alert"] as! String
                            
                            if #available(iOS 8.0, *)
                            {
                                let sosAlert = UIAlertController(title: "Alerta", message: alert_msg , preferredStyle: UIAlertControllerStyle.alert)
                                sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.window?.makeKeyAndVisible()
                                self.window?.rootViewController?.present(sosAlert, animated: false, completion: nil)
                            }
                            else if iOS7
                            {
                                
                                let sosAlert: UIAlertView = UIAlertView()
                                sosAlert.delegate = self
                                sosAlert.title = "Alerta"
                                sosAlert.message = alert_msg
                                sosAlert.tag = 2
                                sosAlert.addButton(withTitle: "OK")
                                sosAlert.show()
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            if usuario.recordar == 1 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "FrontViewController") as! UINavigationController
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
                
            }
        }
        
        return true
    }
    
    func mostrarMapa(_ gps_id :String, patente_id:String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapaUbicacionViewController") as! MapaUbicacionViewController
        
        vc._vehiculoDTO = Vehiculo(patente_id: patente_id, gps_id: gps_id, nombre_id: "")
        self.window?.rootViewController?.present(vc, animated: false, completion: nil)
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        /*PARSE*/
        let installation = PFInstallation.current()
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
        
        /*SAMTECH*/
        LibraryAPI.sharedInstance.InsertaDeviceToken(deviceToken)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error.code == 3010 {
            //println("Push notifications are not supported in the iOS Simulator.")
        } else {
            //println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        /**
        Reconocimiento de GPS_ID/PATENTE_ID
        **/
        
        if let notificacion_id: String = userInfo["notificacionId"] as? String {
            
            let patente_id: String = userInfo["patente_id"] as! String
            let gps_id: String = notificacion_id
            let aps: NSDictionary = userInfo["aps"] as! NSDictionary
            let alert_msg: String = aps["alert"] as! String
            
            
            if (!gps_id.isEmpty && !patente_id.isEmpty) {
                
                let state : UIApplicationState = application.applicationState
                if state == UIApplicationState.inactive {
                    if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                        let viewController: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FrontViewController") as! UINavigationController
                        window?.rootViewController = viewController
                        self.mostrarMapa(gps_id, patente_id: patente_id)
                    }
                }
                if state == UIApplicationState.active
                {
                    if #available(iOS 8.0, *)
                    {
                        let sosAlert = UIAlertController(title: "Alerta", message: alert_msg , preferredStyle: UIAlertControllerStyle.alert)
                        sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                            if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                                self.mostrarMapa(gps_id, patente_id: patente_id)
                            }
                            
                        }))
                        self.window?.rootViewController?.present(sosAlert, animated: false, completion: nil)
                    }
                    else if iOS7
                    {
                        
                        let sosAlert: UIAlertView = UIAlertView()
                        sosAlert.delegate = self
                        sosAlert.title = "Alerta"
                        sosAlert.message = alert_msg
                        sosAlert.addButton(withTitle: "OK")
                        sosAlert.show()
                        self.gps_id = gps_id
                        self.patente_id = patente_id
                        
                    }
                }
                
                if state == UIApplicationState.background {
                    if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                        let viewController: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FrontViewController") as! UINavigationController
                        window?.rootViewController = viewController
                        self.mostrarMapa(gps_id, patente_id: patente_id)
                    }
                }
                
            }
            else if patente_id == "0000"
            {
                if #available(iOS 8.0, *)
                {
                    let sosAlert = UIAlertController(title: "Alerta", message: alert_msg , preferredStyle: UIAlertControllerStyle.alert)
                    sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.window?.rootViewController?.present(sosAlert, animated: false, completion: nil)
                }
                else if iOS7
                {
                    
                    let sosAlert: UIAlertView = UIAlertView()
                    sosAlert.delegate = self
                    sosAlert.title = "Alerta"
                    sosAlert.message = alert_msg
                    sosAlert.tag = 2
                    sosAlert.addButton(withTitle: "OK")
                    sosAlert.show()
                    
                }
                
            }
        }
        
        
    }
    
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
            
        case 0:
            if View.tag != 2 {
                if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                    self.mostrarMapa(gps_id, patente_id: patente_id)
                }
            }
            
            break;
        default:
            break;
            
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.applicationIconBadgeNumber = 0;
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



}

