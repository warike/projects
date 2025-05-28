//
//  VehiculoViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/19/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VehiculoViewController: UIViewController {
    
    @IBOutlet var labelGPS: UILabel!
    @IBOutlet var labelPatente: UILabel!
    @IBOutlet var textFieldNombre: UITextField!
    
    let _priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    var _vehiculo : Vehiculo = Vehiculo()
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    @IBAction func guardarCambios(sender: UIButton) {
        let nombre_id :String = self.textFieldNombre!.text!
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        self._activity.startAnimating()
        
        LibraryAPI.sharedInstance.ActualizarNombrePorPatente(self._vehiculo._ID, patente_id: self._vehiculo._Patente, nombre_id: nombre_id)
        
    }
    
    func respuestaGuardarCambios(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool
        
        self._activity.stopAnimating()
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(VehiculoViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        if respuesta {
            LibraryAPI.sharedInstance.NombrePorPatente("", patente_id: "", nombre_id: "", accion_id: "1")
            self.navigationController?.popViewControllerAnimated(true)
        
        }else {
            
            if #available(iOS 8.0, *) {
                let sosAlert = UIAlertController(title: "ERROR", message: "Ha ocurrido un error, por favor intente de nuevo", preferredStyle: UIAlertControllerStyle.Alert)
                sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) in
                }))
                presentViewController(sosAlert, animated: true, completion: nil)
            } else if iOS7{
                
            }
        }
    
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VehiculoViewController.respuestaGuardarCambios(_:)), name: "respuestaActualizacion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VehiculoViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VehiculoViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VehiculoViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        self.cargarDatos()

    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Vehiculo"
        
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(VehiculoViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
    }
    
    func cargarDatos() -> Void {
        self.labelGPS?.text = self._vehiculo._ID
        self.labelPatente?.text = self._vehiculo._Patente
        self.textFieldNombre?.text = self._vehiculo._Nombre
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
