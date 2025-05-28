//
//  ConfiguracionViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/14/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class ConfiguracionViewController: UIViewController {

    
    @IBOutlet var btnUno: UIButton!
    @IBOutlet var btnDos: UIButton!
    @IBOutlet var btnTres: UIButton!
    @IBOutlet var btnCuatro: UIButton!
    @IBOutlet var btnCinco: UIButton!
    
    let _vehiculosSegue : String = "verVehiculos"
    let _usuariosSegue : String = "verUsuarios"
    let _velocidadesSegue : String = "verVelocidades"
    let _contactosSegue :String = "verContactos"

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self._vehiculosSegue {
            if let destino = segue.destination as? VehiculosListViewController {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._velocidadesSegue {
            if let destino = segue.destination as? VelocidadesListViewController {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._usuariosSegue {
            if let destino = segue.destination as? UsuariosListViewController {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._contactosSegue {
            if let destino = segue.destination as? ContactosListViewController {
                destino.cargarDatos()
            }
        }
    }
    
    @IBAction func verVehiculos(_ sender: AnyObject) {
        if(LibraryAPI.sharedInstance.getCurrentUser().demo == 1){
            generarAlerta()
        } else {
            self.performSegue(withIdentifier: self._vehiculosSegue, sender: self)
        }
    }
    
    @IBAction func verVelocidades(_ sender: AnyObject) {
        if(LibraryAPI.sharedInstance.getCurrentUser().demo == 1){
            generarAlerta()
        } else {
            self.performSegue(withIdentifier: self._velocidadesSegue, sender: self)
        }
    }

    @IBAction func verUsuarios(_ sender: AnyObject) {
        if(LibraryAPI.sharedInstance.getCurrentUser().demo == 1){
            generarAlerta()
        } else {
            self.performSegue(withIdentifier: self._usuariosSegue, sender: self)
        }
    }
    
    @IBAction func abrirSafari(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string:"http://www.autoseguro24siete.cl/ayuda")!)
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verContactos(_ sender: AnyObject) {
        self.performSegue(withIdentifier: self._contactosSegue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(ConfiguracionViewController.procesarSolicitaEjecutivo(_:)), name: NSNotification.Name(rawValue: "respuestaSolicitarEjecutivo"), object: nil)
        LoadBotones(LibraryAPI.sharedInstance.isSuperUser())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Configuración"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func LoadBotones(_ _isSuperUser: Bool) -> Void
    {
        if _isSuperUser {
            
            self.btnUno.addTarget(self, action: #selector(ConfiguracionViewController.verVehiculos(_:)), for: UIControlEvents.touchUpInside)
            self.btnDos.addTarget(self, action: #selector(ConfiguracionViewController.verUsuarios(_:)), for: UIControlEvents.touchUpInside)
            self.btnTres.addTarget(self, action: #selector(ConfiguracionViewController.abrirSafari(_:)), for: UIControlEvents.touchUpInside)
            self.btnCuatro.addTarget(self, action: #selector(ConfiguracionViewController.verVelocidades(_:)), for: UIControlEvents.touchUpInside)
            self.btnCinco.addTarget(self, action: #selector(ConfiguracionViewController.verContactos(_:)), for: UIControlEvents.touchUpInside)
        
        }
        else {
            self.btnUno.addTarget(self, action: #selector(ConfiguracionViewController.verVelocidades(_:)), for: UIControlEvents.touchUpInside)
            self.btnUno.setImage(self.btnCuatro.imageView?.image, for: UIControlState())

            self.btnDos.addTarget(self, action: #selector(ConfiguracionViewController.verContactos(_:)), for: UIControlEvents.touchUpInside)
            self.btnDos.setImage(self.btnCinco.imageView?.image, for: UIControlState())
            
            self.btnTres.addTarget(self, action: #selector(ConfiguracionViewController.abrirSafari(_:)), for: UIControlEvents.touchUpInside)
            
            
            self.btnCuatro.alpha = 0
            self.btnCinco.alpha = 0
            
        }
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
    
    func procesarSolicitaEjecutivo(_ notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool!
        let mensaje = userInfo["mensaje"] as! String!
        if (respuesta == true)  {
            self.generarAlerta("Alerta", mensaje: mensaje!)
        } else {
            self.generarAlerta("Error", mensaje: mensaje!)
        }
    }
}
