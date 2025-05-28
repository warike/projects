//
//  ModoEstacionadoViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ModoEstacionadoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var switchActivarTodos: UISwitch!
    
    
    var _vehiculos = [Vehiculo]()
    var _isSearching :Bool = false
    var _searchingVehiculos = [Vehiculo]()
    
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let priority = DispatchQueue.GlobalQueuePriority.default
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty{
            self._isSearching = false
            self.tableView.reloadData()
        } else {
            self._isSearching = true
            self._searchingVehiculos.removeAll(keepingCapacity: true)
            for index in 0 ..< self._vehiculos.count
            {
                let v = self._vehiculos[index] as Vehiculo
                if v._Patente.lowercased().range(of: searchText.lowercased())  != nil  || v._Nombre.lowercased().range(of: searchText.lowercased())  != nil {
                    self._searchingVehiculos.append(v)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ActivarTodos(_ sender: UISwitch) {
        let estado: String = (sender.isOn) ? "3" : "2"
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "0", genAlert: false )
            //self.confirmar(sender, activarTodos: true)
        }
    }
    
    @IBAction func EstadoPatente(_ sender: UISwitch) {
        /**
        var vehiculo :Vehiculo
        let estado: String = (sender.on) ? "1" : "0"
        
        if(self._isSearching == true){
            vehiculo =  self._searchingVehiculos[sender.superview!.tag]
            vehiculo._Estado = String(sender.tag)
            
        }else{
            vehiculo =  self._vehiculos[sender.superview!.tag]
        }
        
        LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado)
**/
        confirmar(sender, activarTodos: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool){
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Modo Estacionado"
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        NotificationCenter.default.addObserver(self, selector:#selector(ModoEstacionadoViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaVehiculos"), object: nil)
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.getListaVehiculoTodos()
            self._activity.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._isSearching = false
        NotificationCenter.default.addObserver(self, selector:#selector(ModoEstacionadoViewController.procesarModoEstacionado(_:)), name: NSNotification.Name(rawValue: "respuestaME"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func poblarTabla(_ notification: Notification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let vehiculos = userInfo["vehiculos"] as! [Vehiculo]!
        self._vehiculos.removeAll(keepingCapacity: false)
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        DispatchQueue.main.async
            {
                self._vehiculos = vehiculos!
                self.tableView.reloadData()
        }
    }
    
    /* IMPLEMENTACION LOGICA TABLA*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.tag = indexPath.row
        let btn = UISwitch(frame: CGRect(x: 30, y: 30, width: 50, height: 30))  
        
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        let estado : Bool = (v._Estado == "1") ? true : false
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(ModoEstacionadoViewController.EstadoPatente(_:)), for:.touchUpInside)
        
        if v._Estado == "1" {
            if self.switchActivarTodos.isOn == false {
                self.switchActivarTodos.isOn = true
            }
        }
        
        cell.accessoryView = btn
        return cell
    }
    
    func confirmar(_ sender: UISwitch, activarTodos: Bool){
        var vehiculo: Vehiculo
        var estado: String
        
        if(self._isSearching == true){
            vehiculo =  self._searchingVehiculos[sender.superview!.tag]
            vehiculo._Estado = String(sender.tag)
        }else{
            vehiculo =  self._vehiculos[sender.superview!.tag]
        }
        
        if (activarTodos) { estado = (sender.isOn) ? "3" : "2" }
        else { estado = (sender.isOn) ? "1" :"0" }
        
        let title = "Activar Modo Estacionado"
        let message = "Desea Cortar Contacto de vehículo?"
        
        if(sender.isOn){
            if(Int(vehiculo._CortaContacto) >= 1) {
                if #available(iOS 8.0, *) {
                    
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "NO" ,style: .default, handler: { (action: UIAlertAction)in
                        if(Int(estado) >= 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "0", genAlert: true )
                        } else if(Int(estado) < 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "0", genAlert: true)
                        }
                    } )
                    
                    alert.addAction(cancelAction)
                    alert.addAction(UIAlertAction(title: "SI", style: .default, handler:{ (alertAction:UIAlertAction) in
                        if(Int(estado) >= 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "1", genAlert: true )
                        } else if(Int(estado) < 2){
                            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado, cortacont: "1", genAlert: true)
                        }
                    }))
                    
                    self.present(alert,
                        animated: true,
                        completion: nil)
                } else if iOS7{
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.alertViewStyle = UIAlertViewStyle.plainTextInput
                    alert.title = title
                    alert.message = message
                    alert.addButton(withTitle: "NO")
                    alert.addButton(withTitle: "SI")
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
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        let id: String = View.value(forKey: "id") as! String
        let patente : String = View.value(forKey: "patente") as! String
        let estado: String = View.value(forKey: "estado") as! String
        
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
    
    func procesarModoEstacionado(_ notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! String
        let genalert = userInfo["genAlert"] as! Bool
        if(genalert){
            self.generarAlerta("Respuesta", mensaje: respuesta, btnTitulo: "OK")
        }
    }
    
    func generarAlerta(_ frameTitulo: String, mensaje: String, btnTitulo: String)
    {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: frameTitulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if iOS7{
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = frameTitulo
            sosAlert.message = mensaje
            sosAlert.addButton(withTitle: btnTitulo)
            sosAlert.show()
        }
    }
}
