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
    
    let _priority = DispatchQueue.GlobalQueuePriority.default
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var _vehiculo : Vehiculo = Vehiculo()
    
    @IBAction func guardarCambios(_ sender: UIButton) {
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        self._activity.startAnimating()
        
        DispatchQueue.global(priority: self._priority).async {
            LibraryAPI.sharedInstance.ActualizarNombrePorPatente(self._vehiculo._ID, patente_id: self._vehiculo._Patente, nombre_id: self.textFieldNombre!.text!)
        }
        
    }
    
    func respuestaGuardarCambios(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool
        
        self._activity.stopAnimating()
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VehiculoViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        if respuesta {
            LibraryAPI.sharedInstance.NombrePorPatente("", patente_id: "", nombre_id: "", accion_id: "1")
            self.navigationController?.popViewController(animated: true)
        
        }else {
            let mensaje = "Ha ocurrido un error, por favor intente de nuevo"
            let titulo = "ERROR"
            let titulo_accion = "OK"
            
            if #available(iOS 8.0, *) {
                let sosAlert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                sosAlert.addAction(UIAlertAction(title: titulo_accion, style: UIAlertActionStyle.cancel, handler: nil))
                present(sosAlert, animated: true, completion: nil)
            }else if iOS7 {
                
                let sosAlert: UIAlertView = UIAlertView()
                sosAlert.delegate = self
                sosAlert.title = titulo
                sosAlert.message = mensaje
                sosAlert.addButton(withTitle: titulo_accion)
                sosAlert.show()
            }
        }
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(VehiculoViewController.respuestaGuardarCambios(_:)), name: NSNotification.Name(rawValue: "respuestaActualizacion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VehiculoViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(VehiculoViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VehiculoViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        self.cargarDatos()

    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y += 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Vehiculo"
        
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VehiculoViewController.guardarCambios(_:)))
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
