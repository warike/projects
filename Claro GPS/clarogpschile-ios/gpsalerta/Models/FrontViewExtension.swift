//
//  FrontViewExtension.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/16/15.
//  Copyright (c) 2015 Samtech SA. All rights reserved.
//

import UIKit
import Parse

extension FrontViewController {
    
    
    @IBAction func configuracion(sender: AnyObject) {
        self.performSegueWithIdentifier("verConfiguracion", sender: self)
    }
    
    @IBAction func cambiareModoEstacionado(sender: UIButton) {
        let tipoApp: String = LibraryAPI.sharedInstance.getCurrentUser().usuario.lowercaseString
        let tipoUser: Bool = LibraryAPI.sharedInstance.isSuperUser()
        
        if  (tipoApp == "pyme" && tipoUser == true) {
            self.performSegueWithIdentifier("ControlUsoSegue", sender: self)
        }else {
            self.performSegueWithIdentifier("ModoEstacionadoSegue", sender: self)
        }
    }
    
    func actualizarImagenes(vel: String, est: String, uso: String){
        
        if vel == "0" {
            let image :UIImage = UIImage(named: "boton_menu_velocidad_a")!
            self.velocidadBtn.setImage(image, forState: UIControlState.Normal)
        }
        else {
            let image :UIImage = UIImage(named: "boton_menu_velocidad_d")!
            self.velocidadBtn.setImage(image, forState: UIControlState.Normal)
        }
        
        
        let tipoApp: String = LibraryAPI.sharedInstance.getCurrentUser().usuario.lowercaseString
        let tipoUser: Bool = LibraryAPI.sharedInstance.isSuperUser()
        
        if  (tipoApp == "pyme" && tipoUser == true) {
            if uso == "0" {
                let image :UIImage = UIImage(named: "boton_menu_controluso")!
                self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
            }
            else {
                let image :UIImage = UIImage(named: "boton_menu_controluso_a")!
                self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
            }
        }else {
            if est == "0" {
                let image :UIImage = UIImage(named: "boton_menu_estacionado_a")!
                self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
            }
            else {
                let image :UIImage = UIImage(named: "boton_menu_estacionado_d")!
                self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
            }
        }

        
    }
    
    func refrescarEstados(notification: NSNotification){
        
        let velocidad :String = LibraryAPI.sharedInstance.tieneVelocidadActivado()
        let estado :String = LibraryAPI.sharedInstance.tieneEstacionadoActivado()
        let controluso :String = LibraryAPI.sharedInstance.tieneControlUsoActivado()
        
        self.actualizarImagenes(velocidad, est: estado, uso: controluso)
    }
    
    func cargarFront()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 183/255.0, green: 28/255.0, blue: 28/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if UIScreen.mainScreen().bounds.size.height == 480.0 {
            
            let image :UIImage = UIImage(named: "boton_menu_ubicacion_s")!
            self.ubicacionBtn.setImage(image, forState: UIControlState.Normal)
            
            
        }
        let tipoApp: String = LibraryAPI.sharedInstance.getCurrentUser().usuario.lowercaseString
        let tipoUser: Bool = LibraryAPI.sharedInstance.isSuperUser()
        
        if  (tipoApp == "pyme" && tipoUser == true) {
            let image :UIImage = UIImage(named: "boton_menu_controluso")!
            self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
            
        }
        else {
            let image :UIImage = UIImage(named: "boton_menu_estacionado_a")!
            self.modoEstacionadoBtn.setImage(image, forState: UIControlState.Normal)
        }
        
        self.modoEstacionadoBtn.addTarget(self, action: #selector(FrontViewController.cambiareModoEstacionado(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FrontViewController.mensajeSOSAlert(_:)), name: "mensajeSOS", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FrontViewController.refrescarEstados(_:)), name: "respuestaEstados", object: nil)
        LibraryAPI.sharedInstance.consultaEstados()
        
    }
    
    func cargarDatos()
    {
        let image :UIImage = UIImage(named: "logo_gpsalert")!
        let imageView :UIImageView = UIImageView(image: image)
        self.navigationItem.titleView = imageView
        
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                let u :Ubicacion = Ubicacion(_lat: geoPoint!.latitude, _lon: geoPoint!.longitude, _latDelta: 0.05, _lonDelta: 0.05, _ubic: "Mi ubicación actual", _fecha: "", _hora: "")
                LibraryAPI.sharedInstance.setUserLocation(u)
            }
        }
        
        self._currentUser = LibraryAPI.sharedInstance.getCurrentUser()
        LibraryAPI.sharedInstance.contadorVehiculo()
        
    }
    
    func desvincularNotificaciones()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
