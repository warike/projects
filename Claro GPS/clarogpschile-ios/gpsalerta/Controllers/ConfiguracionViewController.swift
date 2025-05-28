//
//  ConfiguracionViewController.swift
//  gpsalert
//
//  Created by RWBook Retina on 8/14/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class ConfiguracionViewController: UIViewController
{

    
    @IBOutlet var btnUno: UIButton!
    @IBOutlet var btnDos: UIButton!
    @IBOutlet var btnTres: UIButton!
    @IBOutlet var btnCuatro: UIButton!
    @IBOutlet var btnCinco: UIButton!
    @IBOutlet var btnSeis: UIButton!
    
    
    let _vehiculosSegue : String = "verVehiculos"
    let _usuariosSegue : String = "verUsuarios"
    let _velocidadesSegue : String = "verVelocidades"
    let _controlUsoSegue :String = "ControlUsoSegue"
    let _contactosSegue :String = "verContactos"
    let _tipoApp : String = "pyme"
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self._vehiculosSegue
        {
            if let destino = segue.destinationViewController as? VehiculosListViewController
            {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._velocidadesSegue
        {
            if let destino = segue.destinationViewController as? VelocidadesListViewController
            {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._usuariosSegue
        {
            if let destino = segue.destinationViewController as? UsuariosListViewController
            {
                destino.cargarDatos()
            }
        }
        if segue.identifier == self._contactosSegue
        {
            if let destino = segue.destinationViewController as? ContactosListViewController
            {
                destino.cargarDatos()
            }
        }

    }
    
    
    @IBAction func verContactos(sender: AnyObject) {
        self.performSegueWithIdentifier(self._contactosSegue, sender: self)
    }

    @IBAction func abrirSafari(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.gpsalerta.cl/ayuda")!)
    }
    
    
    @IBAction func ControlUsoSegue(sender: AnyObject) {
        self.performSegueWithIdentifier(self._controlUsoSegue, sender: self)
    }
    
    @IBAction func verVehiculos(sender: AnyObject) {
        self.performSegueWithIdentifier(self._vehiculosSegue, sender: self)
    }
    
    @IBAction func verVelocidades(sender: AnyObject) {
        self.performSegueWithIdentifier(self._velocidadesSegue, sender: self)
    }

    @IBAction func verUsuarios(sender: AnyObject) {
        self.performSegueWithIdentifier(self._usuariosSegue, sender: self)
    }
    
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadBotones(LibraryAPI.sharedInstance.isSuperUser())
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Configuración"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func LoadBotones(_isSuperUser: Bool) -> Void
    {
        let tipoApp: String = LibraryAPI.sharedInstance.getCurrentUser().usuario.lowercaseString
        
        if tipoApp == self._tipoApp && _isSuperUser == true {
            
            btnUno.addTarget(self, action: #selector(ConfiguracionViewController.verVehiculos(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btnDos.addTarget(self, action: #selector(ConfiguracionViewController.verUsuarios(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btnTres.addTarget(self, action: #selector(ConfiguracionViewController.abrirSafari(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btnCuatro.addTarget(self, action: #selector(ConfiguracionViewController.verVelocidades(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btnCinco.addTarget(self, action: #selector(ConfiguracionViewController.ControlUsoSegue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btnSeis.addTarget(self, action: #selector(ConfiguracionViewController.verContactos(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        }else{
            
            self.btnUno.addTarget(self, action: #selector(ConfiguracionViewController.verVelocidades(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.btnUno.setImage(btnCuatro.imageView?.image, forState: UIControlState.Normal)
            
            self.btnDos.addTarget(self, action: #selector(ConfiguracionViewController.verContactos(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.btnDos.setImage(btnSeis.imageView?.image, forState: UIControlState.Normal)
            self.btnDos.frame = CGRectMake(137.0, 101.0, 46.0, 57.0)
            
            
            self.btnCuatro.alpha = 0
            self.btnCinco.alpha = 0
            self.btnSeis.alpha = 0
            
        }
        
        
    }

}
