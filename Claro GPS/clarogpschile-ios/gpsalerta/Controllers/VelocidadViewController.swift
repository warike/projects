//
//  VelocidadViewController.swift
//  Claro GPS Alerta
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VelocidadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var switchActivarTodos: UISwitch!
    
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    var _vehiculos = [Vehiculo]()
    var _isSearching :Bool = false
    var _searchingVehiculos = [Vehiculo]()
    
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
        let accion: String = (sender.on) ? "4" : "5"
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.actualizarControlVelocidad("", patente_id : "", estado_id : "",velocidad_id: "", accion_id: accion)
        }
    }
    @IBAction func EstadoPatente(sender: UISwitch) {
        var vehiculo :Vehiculo
        let estado: String = (sender.on) ? "1" : "0"
        
        if(self._isSearching == true){
            vehiculo =  self._searchingVehiculos[sender.superview!.tag]
            self._searchingVehiculos[sender.superview!.tag]._Estado = String(sender.tag)
            
        }else{
             vehiculo =  self._vehiculos[sender.superview!.tag]
        }
        
        dispatch_async(dispatch_get_global_queue(self.priority, 0)) {
            LibraryAPI.sharedInstance.actualizarControlVelocidad(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado,velocidad_id: "", accion_id: "3")
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._isSearching = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Velocidad Máxima"
        
        
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VelocidadViewController.poblarTabla(_:)), name: "actualizarListaControlVelocidad", object: nil)
        dispatch_async(dispatch_get_global_queue(self.priority, 0)) {
            self._activity.startAnimating()
            LibraryAPI.sharedInstance.listaControlVelocidad()
        }
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")!
        let btn = UISwitch(frame: CGRectMake(30, 30, 50, 30))
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        
        cell.tag = indexPath.row
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        
        let estado : Bool = (v._Estado == "1") ? true : false
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(VelocidadViewController.EstadoPatente(_:)), forControlEvents:.TouchUpInside)
        
        if v._Estado == "1" {
            if self.switchActivarTodos.on == false {
                self.switchActivarTodos.on = true
            }
        }
        
        
        cell.accessoryView = btn
        return cell
        
    }
    
}
