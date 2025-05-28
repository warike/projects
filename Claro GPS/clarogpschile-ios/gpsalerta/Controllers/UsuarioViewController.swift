//
//  UsuarioViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/18/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class UsuarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var textFieldNumero: UITextField!
    @IBOutlet var textFieldUsuario: UITextField!
    @IBOutlet var textFieldNombre: UITextField!
    @IBOutlet var textFieldContrasena: UITextField!
    @IBOutlet var textFieldEmail: UITextField!
    @IBOutlet var tableVehiculos: UITableView!
    @IBOutlet var confirmarContrasena: UITextField!
    
    @IBOutlet var btnEliminar: UIButton!
    
    var _usuario : Usuario = Usuario()
    var _patenteList : [Vehiculo] = [Vehiculo]()
    var _patentesPendientes : [Vehiculo] = [Vehiculo]()
    var _isEditing : Bool = false
    var _textTitulo: String = ""
    
    let crear_usuario :String = "1"
    let editar_usuario :String = "2"
    let eliminar_usuario :String = "3"
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    @IBAction func guardarCambios(sender: AnyObject) {
        let contrasena :String = (self.textFieldContrasena?.text)!
        let confirmarContrasena :String = (self.confirmarContrasena?.text)!
        
        if contrasena != confirmarContrasena {
            if #available(iOS 8.0, *) {
                let sosAlert = UIAlertController(title: "Alerta", message: "Las contraseñas deben ser iguales", preferredStyle: UIAlertControllerStyle.Alert)
                sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                presentViewController(sosAlert, animated: true, completion: nil)
            } else if iOS7 {
                
                let sosAlert: UIAlertView = UIAlertView()
                sosAlert.delegate = self
                sosAlert.title = "Alerta"
                sosAlert.message = "Las contraseñas deben ser iguales"
                sosAlert.addButtonWithTitle("OK")
                sosAlert.show()
            }
            
            return
        }

        
        
        let accion_id : String = (self._isEditing) ? self.editar_usuario : self.crear_usuario
        self.InsertaUsuario(accion_id)
    }
    
    @IBAction func EliminarUsuario(sender: UIButton) {
        self.InsertaUsuario(self.eliminar_usuario)
    }
    
    
    func InsertaUsuario(accion_id:String)
    {
        let usuario_id :String = self.textFieldUsuario!.text!
        let nombre_id :String = self.textFieldNombre!.text!
        let password_id :String = self.textFieldContrasena!.text!
        let mail_id :String = self.textFieldEmail!.text!
        let numero_id :String = self.textFieldNumero!.text!
        
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        self._activity.startAnimating()
        
        LibraryAPI.sharedInstance.InsertaUsuario(usuario_id, nombre_id: nombre_id, password_id: password_id, mail_id: mail_id, numero_id: numero_id, tipo_id: accion_id)
    
    }
    
    func cargarDatos()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(UsuarioViewController.poblarTabla(_:)), name: "actualizarTablaVehiculos", object: nil)
        let user_id :String = (self._isEditing) ? _usuario.ilogin : ""
        LibraryAPI.sharedInstance.AsignaVehiculosPorUsuario(user_id, gps_id: "", patente_id: "", estado_id: "", accion_id: "1")
    }
    
    func poblarTabla(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let vehiculos = userInfo["vehiculos"] as! [Vehiculo]
        
        self._patenteList.removeAll(keepCapacity: true)
        self._patentesPendientes.removeAll(keepCapacity: true)
        
        self._patenteList = vehiculos
        self.tableVehiculos.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._patenteList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCellWithIdentifier("CellVehiculo")!
        let btn = UISwitch(frame: CGRectMake(30, 30, 50, 30))
        cell.tag = indexPath.row
    
        let v: Vehiculo = self._patenteList[indexPath.row]
        cell.textLabel?.text = v._Patente
        
        let estado : Bool = (v._Estado == "1") ? true : false
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(UsuarioViewController.AsignarPatente(_:)), forControlEvents:.TouchUpInside)
        cell.accessoryView = btn
        
        return cell
    }
    
    func AsignarPatente(sender: UISwitch)
    {
        let vehiculo :Vehiculo = self._patenteList[sender.superview!.tag]
        vehiculo._Estado = (sender.on) ? "1" : "0"
        self._patentesPendientes.append(vehiculo)
    }
    
    
    func respuestaGuardarCambios(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool
        
        self._activity.stopAnimating()
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UsuarioViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        
        
        if respuesta {
            let usuario_id :String = self.textFieldUsuario!.text!
            for v: Vehiculo in self._patentesPendientes {
                LibraryAPI.sharedInstance.ActualizarAsignaVehiculosPorUsuario(usuario_id, gps_id: v._ID, patente_id: v._Patente, estado_id: v._Estado, accion_id: "2")
            }
            self.returnSegue()
            
        }else {
            let mensaje = userInfo["mensaje"] as! String
            if #available(iOS 8.0, *) {
                let sosAlert = UIAlertController(title: "Alerta", message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
                sosAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) in
                    self.returnSegue()
                }))
                presentViewController(sosAlert, animated: true, completion: nil)
            } else if iOS7 {
            
                let sosAlert: UIAlertView = UIAlertView()
                sosAlert.delegate = self
                sosAlert.title = "Alerta"
                sosAlert.message = mensaje
                sosAlert.addButtonWithTitle("OK")
                sosAlert.show()
            }
            
            
        }
    }

    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
        case 0:
            self.returnSegue()
            break;
        default:
            break;
            
        }
    }
    
    
    func returnSegue()
    {
        LibraryAPI.sharedInstance.getListaUsuarios()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /* Observers*/
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(UsuarioViewController.respuestaGuardarCambios(_:)), name: "respuestaActualizacionUsuario", object: nil)

        /*  */
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UsuarioViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self._patenteList.removeAll(keepCapacity: true)
        self._patentesPendientes.removeAll(keepCapacity: true)
        
        if self._isEditing
        {
            self.EditarUsuario()
        }
        
    }
    
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Usuario"
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UsuarioViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        if !self._isEditing
        {
            self.btnEliminar.alpha = 0
        }
        
        self.cargarDatos()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func EditarUsuario()
    {
        self.textFieldNombre?.text = self._usuario.nombre
        self.textFieldContrasena?.text = self._usuario.ipassword
        self.confirmarContrasena?.text = self._usuario.ipassword
        self.textFieldUsuario?.text = self._usuario.ilogin
        self.textFieldEmail?.text = self._usuario.email
        self.textFieldNumero?.text = self._usuario.fono
    }
    

}
