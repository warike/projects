//
//  ModoEstacionadoViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class ModoEstacionadoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var switchActivarTodos: UISwitch!
    
    
    var _vehiculos = [Vehiculo]()
    var _isSearching :Bool = false
    var _searchingVehiculos = [Vehiculo]()
    
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty{
            self._isSearching = false
            self.tableView.reloadData()
        } else {
            self._isSearching = true
            self._searchingVehiculos.removeAll(keepCapacity: true)
            for index in 0 ..< self._vehiculos.count
            {
                let v = self._vehiculos[index] as Vehiculo
                if v._Patente.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil  || v._Nombre.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    self._searchingVehiculos.append(v)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func ActivarTodos(sender: UISwitch) {
        let estado: String = (sender.on) ? "3" : "2"
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "0", genAlert: false )

        }
    }
    
    @IBAction func EstadoPatente(sender: UISwitch) {
        confirmar(sender, activarTodos: false)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillDisappear(animated: Bool){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Modo Estacionado"
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ModoEstacionadoViewController.poblarTabla(_:)), name: "actualizarTablaVehiculos", object: nil)
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.getListaVehiculoTodos()
            self._activity.startAnimating()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._isSearching = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ModoEstacionadoViewController.procesarModoEstacionado(_:)), name: "respuestaME", object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func poblarTabla(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let vehiculos = userInfo["vehiculos"] as! [Vehiculo]!
        self._vehiculos.removeAll(keepCapacity: false)
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
        {
            self._vehiculos = vehiculos
            self.tableView.reloadData()
        }
    }
    
    /* IMPLEMENTACION LOGICA TABLA*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.tag = indexPath.row
        let btn = UISwitch(frame: CGRectMake(30, 30, 50, 30))  
        
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        let estado : Bool = (v._Estado == "1") ? true : false
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(ModoEstacionadoViewController.EstadoPatente(_:)), forControlEvents:.TouchUpInside)
        
        if v._Estado == "1" {
            if self.switchActivarTodos.on == false {
                self.switchActivarTodos.on = true
            }
        }
        
        cell.accessoryView = btn
        return cell
    }
    
    func confirmar(sender: UISwitch, activarTodos: Bool){
        var vehiculo: Vehiculo
        var estado: String

            if(self._isSearching == true){
                vehiculo =  self._searchingVehiculos[sender.superview!.tag]
                vehiculo._Estado = String(sender.tag)
            }else{
                vehiculo =  self._vehiculos[sender.superview!.tag]
            }
        
        if (activarTodos) { estado = (sender.on) ? "3" : "2" }
        else { estado = (sender.on) ? "1" :"0" }
        
        let title = "Activar Modo Estacionado"
        let message = "Desea Cortar Contacto de vehículo?"

        if(sender.on){
            if(Int(vehiculo._CortaContacto) >= 1) {
                if #available(iOS 8.0, *) {
                    
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "NO" ,style: .Default, handler: { (action: UIAlertAction)in
                        if(Int(estado) >= 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "0", genAlert: true )
                        } else if(Int(estado) < 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "0", genAlert: true)
                        }
                    } )
                    
                    alert.addAction(cancelAction)
                        alert.addAction(UIAlertAction(title: "SI", style: .Default, handler:{ (alertAction:UIAlertAction) in
                    if(Int(estado) >= 2){
                        LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "1", genAlert: true )
                    } else if(Int(estado) < 2){
                        LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "1", genAlert: true)
                        }
                    }))
                    
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else if iOS7{
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                    alert.title = title
                    alert.message = message
                    alert.addButtonWithTitle("NO")
                    alert.addButtonWithTitle("SI")
                    alert.setValue(vehiculo._ID, forKey: "id")
                    alert.setValue(vehiculo._Patente, forKey: "patente")
                    alert.setValue(estado, forKey: "estado")
                    alert.show()
                    }
                } else {
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "0", genAlert: false)
                }
            } else {
            if(Int(vehiculo._CortaContacto) >= 1){
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "1", genAlert: false)
                } else {
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "0", genAlert: false)
                }
            }
        }

    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        let id: String = View.valueForKey("id") as! String
        let patente : String = View.valueForKey("patente") as! String
        let estado: String = View.valueForKey("estado") as! String
        
        switch buttonIndex{
            case 0:
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(id, patente_id : patente, estado_id : estado, cortacont: "0", genAlert: true)
                break;
            case 1:
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(id, patente_id : patente, estado_id : estado, cortacont: "1", genAlert: true)
                break;
            default:
                break;
            }
        }

    func procesarModoEstacionado(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! String
        let genalert = userInfo["genAlert"] as! Bool
        if(genalert){
            self.generarAlerta("Respuesta", mensaje: respuesta, btnTitulo: "OK")
            }
        }
    
    func generarAlerta(frameTitulo: String, mensaje: String, btnTitulo: String)
    {
    if #available(iOS 8.0, *) {
    let alert = UIAlertController(title: frameTitulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
    }else if iOS7{
        let sosAlert: UIAlertView = UIAlertView()
        sosAlert.delegate = self
        sosAlert.title = frameTitulo
        sosAlert.message = mensaje
        sosAlert.addButtonWithTitle(btnTitulo)
        sosAlert.show()
    }
    
    }
}