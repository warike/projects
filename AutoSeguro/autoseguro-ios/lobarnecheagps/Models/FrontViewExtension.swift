//
//  FrontViewExtension.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 9/16/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import Parse

extension FrontViewController {


    @IBAction func configuracion(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "verConfiguracion", sender: self)
    }
    
    func actualizarImagenes(_ vel: String, est: String){
    
        if vel == "0" {
            let image :UIImage = UIImage(named: "boton_menu_velocidad_a")!
            self.velocidadBtn.setImage(image, for: UIControlState())
        }else {
            let image :UIImage = UIImage(named: "boton_menu_velocidad_d")!
            self.velocidadBtn.setImage(image, for: UIControlState())
        }
        
        if est == "0" {
            let image :UIImage = UIImage(named: "boton_menu_estacionado_a")!
            self.modoEstacionadoBtn.setImage(image, for: UIControlState())
        }else{
            let image :UIImage = UIImage(named: "boton_menu_estacionado_d")!
            self.modoEstacionadoBtn.setImage(image, for: UIControlState())
        }
    
    }
    
    func refrescarEstados(_ notification: Notification){
        let velocidad :String = LibraryAPI.sharedInstance.tieneVelocidadActivado()
        let estado :String = LibraryAPI.sharedInstance.tieneEstacionadoActivado()
    
        self.actualizarImagenes(velocidad, est: estado)
    }
    
    func cargarFront()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 183/255.0, green: 28/255.0, blue: 28/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        if UIScreen.main.bounds.size.height == 480.0 {
            let image :UIImage = UIImage(named: "boton_menu_ubicacion_s")!
            self.ubicacionBtn.setImage(image, for: UIControlState())
        }

        NotificationCenter.default.addObserver(self, selector:"mensajeSOSAlert:", name: NSNotification.Name(rawValue: "mensajeSOS"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(FrontViewController.refrescarEstados(_:)), name: NSNotification.Name(rawValue: "respuestaEstados"), object: nil)
        LibraryAPI.sharedInstance.consultaEstados()
    
    }
    
    func cargarDatos()
    {
        let image :UIImage = UIImage(named: "logo_gpsalert")!
        let imageView :UIImageView = UIImageView(image: image)
        self.navigationItem.titleView = imageView
        
        
        PFGeoPoint.geoPointForCurrentLocation {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    func generarAlerta()
    {
        let titulo = "No Disponible"
        let mensaje = "Desea que lo contacte un ejecutivo para adquirir esta función?"
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "SI", style: UIAlertActionStyle.default, handler: {
                (alertAction:UIAlertAction) in
                LibraryAPI.sharedInstance.SolicitarEjecutivo(LibraryAPI.sharedInstance.getCurrentUser().ilogin, ipassword: LibraryAPI.sharedInstance.getCurrentUser().ipassword)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = titulo
            sosAlert.message = mensaje
            sosAlert.addButton(withTitle: "NO")
            sosAlert.addButton(withTitle: "SI")
            sosAlert.show()
        }
    }
    
    func generarAlerta(_ titulo: String, mensaje: String )
    {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = titulo
            sosAlert.message = mensaje
            sosAlert.addButton(withTitle: "OK")
            sosAlert.show()
        }
    }
}
