//
//  AppDelegate.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/15/15.
//  Copyright (c) 2015 Samtech SA. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var gps_id :String = String()
    var patente_id :String = String()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
    
        sleep(2);
        
        Parse.setApplicationId("vBtN0sFvKWvGoA4ir12S00tb0Q4wy9nRv0gywrtg", clientKey: "y1AXKtmFU391m0sPexQt4ijzqm4R0oNoZMSv5Bwz")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //REGISTRAR NOTIFICACIONES
        if #available(iOS 8.0, *)
        {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else if iOS7 {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("usuario") != nil)
        {
            var usuarioDataEncoded: [NSData] = NSUserDefaults.standardUserDefaults().objectForKey("usuario") as! [NSData]
            var unpackedUsuario: String = String("Masivo")
            
            let unpackedIlogin: String = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[0] as NSData) as! String
            let unpackedIpassword: String = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[1] as NSData) as! String
            let unpackedTipo: Int = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[2] as NSData) as! Int
            let unpackedRecordar: Int = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[3] as NSData) as! Int
            
            if usuarioDataEncoded.count > 4 {
                unpackedUsuario = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[4] as NSData) as! String
            }
            
            let usuario: Usuario = Usuario(ilogin: unpackedIlogin, ipassword: unpackedIpassword, tipo: unpackedTipo, recordar: unpackedRecordar, usuario: unpackedUsuario)
            
            LibraryAPI.sharedInstance.setUsuario(usuario)
            
            if let options = launchOptions {
                if (options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
                    if let launchOptions = launchOptions {
                        
                        let notificationPayload: NSDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary
                        let notificacion_id :String = notificationPayload["notificacionId"] as! String
                        
                        if  !notificacion_id.isEmpty {
                            
                            let patente_id: String = notificationPayload["patente_id"] as! String
                            let gps_id: String = notificacion_id
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("MapaUbicacionViewController") as! MapaUbicacionViewController
                            let viewController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("FrontViewController") as! UINavigationController
                            
                            vc._vehiculoDTO = Vehiculo(patente_id: patente_id, gps_id: gps_id, nombre_id: "")
                            self.window?.rootViewController = viewController
                            self.window?.makeKeyAndVisible()
                            self.window?.rootViewController?.presentViewController(vc, animated: false, completion: nil)
                            
                            return true
                        }
                    }
                    
                }
            }
            
            if usuario.recordar == 1 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("FrontViewController") as! UINavigationController
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
                
            }
        }
        
        return true
    }
    
    
    func mostrarMapa(gps_id :String, patente_id:String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MapaUbicacionViewController") as! MapaUbicacionViewController
        
        vc._vehiculoDTO = Vehiculo(patente_id: patente_id, gps_id: gps_id, nombre_id: "")
        self.window?.rootViewController?.presentViewController(vc, animated: false, completion: nil)
        self.window?.makeKeyAndVisible()
    }
    

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        
        /*PARSE*/
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        /*SAMTECH*/
        LibraryAPI.sharedInstance.InsertaDeviceToken(deviceToken)
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            //println("Push notifications are not supported in the iOS Simulator.")
        } else {
            //println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        /**
        Reconocimiento de GPS_ID/PATENTE_ID
        **/
        
        if let notificacion_id: String = userInfo["notificacionId"] as? String {
            
            let patente_id: String = userInfo["patente_id"] as! String
            let gps_id: String = notificacion_id
            let aps: NSDictionary = userInfo["aps"] as! NSDictionary
            let alert_msg: String = aps["alert"] as! String
            
            
            if (!gps_id.isEmpty && !patente_id.isEmpty)
            {
                
                let state : UIApplicationState = application.applicationState
                if state == UIApplicationState.Inactive
                {
                    if !LibraryAPI.sharedInstance.isMapaUbicacion()
                    {
                        let viewController: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FrontViewController") as! UINavigationController
                        window?.rootViewController = viewController
                        self.mostrarMapa(gps_id, patente_id: patente_id)
                    }
                }
                if state == UIApplicationState.Active {
                    if #available(iOS 8.0, *) {
                        let sosAlert = UIAlertController(title: "Alerta", message: alert_msg , preferredStyle: UIAlertControllerStyle.Alert)
                        sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                            if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                                self.mostrarMapa(gps_id, patente_id: patente_id)
                            }
                            
                        }))
                        self.window?.rootViewController?.presentViewController(sosAlert, animated: false, completion: nil)
                    } else if iOS7 {
                        
                        let sosAlert: UIAlertView = UIAlertView()
                        sosAlert.delegate = self
                        sosAlert.title = "Alerta"
                        sosAlert.message = alert_msg
                        sosAlert.addButtonWithTitle("OK")
                        sosAlert.show()
                        self.gps_id = gps_id
                        self.patente_id = patente_id
                        
                    }
                }
                
                if state == UIApplicationState.Background {
                    if !LibraryAPI.sharedInstance.isMapaUbicacion() {
                        let viewController: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FrontViewController") as! UINavigationController
                        window?.rootViewController = viewController
                       self.mostrarMapa(gps_id, patente_id: patente_id)
                    }
                }
                
            }
            
        }
        
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
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
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.applicationIconBadgeNumber = 0;
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

