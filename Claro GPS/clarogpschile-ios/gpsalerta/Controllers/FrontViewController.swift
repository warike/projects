//
//  FrontViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import Parse

class FrontViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var modoEstacionadoBtn: UIButton!
    @IBOutlet var sosBtn: UIButton!
    @IBOutlet var historialBtn: UIButton!
    @IBOutlet var velocidadBtn: UIButton!
    @IBOutlet var ubicacionBtn: UIButton!

    var _userLocation : Ubicacion = Ubicacion()
    var _currentUser : Usuario = Usuario()
    var _vehiculo : Vehiculo = Vehiculo()
    
    let _manager = CLLocationManager()
    let _isSuperUser : Bool = LibraryAPI.sharedInstance.isSuperUser()
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    /**
    SEGUES PARA MENU INFERIOR
    **/
    
    @IBAction func notificaciones(sender: AnyObject) {
        self.performSegueWithIdentifier("verNotificaciones", sender: self)
    }

    @IBAction func salirApp(sender: AnyObject) {
        LibraryAPI.sharedInstance.SalirApp()
        performSegueWithIdentifier("logOut_segue", sender: self)
    }
    
    @IBAction func verUbicacion(sender: AnyObject) {
        self.performSegueWithIdentifier("verUbicacion", sender: self)
    }
    
    @IBAction func activarSos(sender: AnyObject) {
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                let _lat = geoPoint!.latitude as Double
                let _lon = geoPoint!.longitude as Double
                
                self._userLocation = Ubicacion(_lat: _lat, _lon: _lon, _latDelta: 0.05, _lonDelta: 0.05, _ubic: "Mi ubicación actual", _fecha: "", _hora: "")
                LibraryAPI.sharedInstance.setUserLocation(self._userLocation)
                
                let title_alert :String = "Mensaje SOS"
                let mensaje_alert :String = "¿Está seguro que desea solicitar ayuda?"
                let title_ok :String = "SI"
                let title_cancel :String = "NO"
                
                if #available(iOS 8.0, *) {
                    let sosAlert = UIAlertController(title: title_alert, message: mensaje_alert, preferredStyle: UIAlertControllerStyle.Alert)
                    sosAlert.addAction(UIAlertAction(title: title_cancel, style: UIAlertActionStyle.Cancel, handler: nil))
                    sosAlert.addAction(UIAlertAction(title: title_ok, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                        LibraryAPI.sharedInstance.alarmaSOS(_lat, longitud: _lon )
                    }))
                    self.presentViewController(sosAlert, animated: true, completion: nil)
                }
                else if iOS7
                {
                    let sosAlert: UIAlertView = UIAlertView()
                    sosAlert.delegate = self
                    sosAlert.title = title_alert
                    sosAlert.message = mensaje_alert
                    sosAlert.addButtonWithTitle(title_cancel)
                    sosAlert.addButtonWithTitle(title_ok)
                    sosAlert.show()
                    
                }
            }
        }
        
    }
    
    func mensajeSOSAlert(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let mensaje = userInfo["mensaje"] as! String
        let title = "Respuesta SOS"
        let title_btn = "OK"
        
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: title, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: title_btn, style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(sosAlert, animated: true, completion: nil)
        }
        else if iOS7
        {
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = title
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(title_btn)
            sosAlert.show()
        }
        
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 1:
            LibraryAPI.sharedInstance.alarmaSOS(self._userLocation.latitud, longitud: self._userLocation.longitud )
            break;
        default:
            break;
            
        }
    }
    
    deinit {
        self.desvincularNotificaciones()
    }
    
    override func viewWillDisappear(animated: Bool){
        self.desvincularNotificaciones()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cargarFront()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cargarDatos()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
