//
//  ContactoViewController.swift
//  gpsalerta
//
//  Created by RWBook Retina on 10/21/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class ContactoViewController: UIViewController {
    
    var _contacto : Contacto = Contacto()
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    var isNew :Bool = true
    
    @IBOutlet var btnEliminar: UIButton!
    @IBOutlet var textFieldEmail: UITextField!
    @IBOutlet var textFieldNumero: UITextField!
    @IBOutlet var textFieldNombre: UITextField!
    
    
    @IBAction func borrarContacto(sender: AnyObject) {
        let titulo = "Alerta"
        let mensaje :String = "Confirma que desea eliminar el contacto?"
        let btnOK :String = "OK"
        let btnCancelar :String = "Cancelar"
        
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: btnCancelar, style: UIAlertActionStyle.Cancel, handler: nil))
            sosAlert.addAction(UIAlertAction(title: btnOK, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.borrarContactoAccion()
            }))
            
            presentViewController(sosAlert, animated: true, completion: nil)
        } else if iOS7 {
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = titulo
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(btnCancelar)
            sosAlert.addButtonWithTitle(btnOK)
            sosAlert.show()
        }
    }
    
    func GuardarCambios(sender: AnyObject?)
    {
        let nombre :String = self.textFieldNombre.text!
        let numero :String = self.textFieldNumero.text!
        let mail :String = self.textFieldEmail.text!
        let contactoDTO :Contacto = Contacto(_id: self._contacto.ID, _nombre: nombre, _telefono: numero, _mail: mail)
        let accion_id :String = (self.isNew) ? "2" : "3"
        
        if self.validarValores(nombre, numero: numero, mail: mail) {
            
            let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
            self.navigationItem.rightBarButtonItem = btnActivity
            self._activity.startAnimating()
            
            LibraryAPI.sharedInstance.ContactoActualizar(contactoDTO.ID, nombre_id: contactoDTO.Nombre, telefono_id: contactoDTO.Telefono, mail_id: contactoDTO.Mail, accion_id: accion_id)
        }
    }
    
    func borrarContactoAccion()
    {
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        let accion_id = "4"
        
        self.navigationItem.rightBarButtonItem = btnActivity
        self._activity.startAnimating()
        LibraryAPI.sharedInstance.ContactoActualizar(_contacto.ID, nombre_id: _contacto.Nombre, telefono_id: _contacto.Telefono, mail_id: _contacto.Mail, accion_id: accion_id)
        
    }
    
    func respuestaActualizacion(notification: NSNotification) -> Void
    {
        
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool
        
        self._activity.stopAnimating()
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ContactoViewController.GuardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        if respuesta
        {
            self.returnSegue()
            
        }else {
            let mensaje = userInfo["mensaje"] as! String
            if #available(iOS 8.0, *) {
                let sosAlert = UIAlertController(title: "Alerta", message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
                sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(sosAlert, animated: true, completion: nil)
            } else if iOS7 {
                
                let sosAlert: UIAlertView = UIAlertView()
                sosAlert.delegate = self
                sosAlert.title = "Alerta"
                sosAlert.message = mensaje
                sosAlert.addButtonWithTitle("OK")
                sosAlert.tag = 3
                sosAlert.show()
            }
        }
        
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
        case 0:
            break;
        default:
            break;
            
        }
    }
    
    func returnSegue()
    {
        LibraryAPI.sharedInstance.ContactoList("", nombre_id: "", telefono_id: "", mail_id: "", accion_id: "1")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ContactoViewController.respuestaActualizacion(_:)), name: "respuestaActualizacion", object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactoViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.cargaUI()
        self.cargaDatos()
    }
    
    deinit
    {
        self.desvincularNotificaciones()
    }
    
    override func viewWillDisappear(animated: Bool){
        self.desvincularNotificaciones()
    }
    
    func DismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func desvincularNotificaciones() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func validarValores(nombre: String, numero: String, mail: String) -> Bool{
        
        if !nombre.isEmpty && !numero.isEmpty && !mail.isEmpty {
            return true
        }
        return false
    }
    
    func cargaUI() -> Void {
        
        self.navigationItem.title = "Contacto"
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ContactoViewController.GuardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        if(self.isNew){
            self.btnEliminar.alpha = 0
        }
        
    }
    
    func cargaDatos() -> Void {
        
        self.textFieldNombre?.text = self._contacto.Nombre
        self.textFieldNumero?.text = self._contacto.Telefono
        self.textFieldEmail?.text = self._contacto.Mail
        
    }

    
}
