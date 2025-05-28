//
//  ControlUsoViewController.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/15/15.
//  Copyright (c) 2015 Samtech SA. All rights reserved.
//

import UIKit

class ControlUsoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
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
        let accion_id: String = (sender.on) ? "4" : "5"
        
        LibraryAPI.sharedInstance.actualizarControlUso("", patente_id :"", estado_id : "", fechaIni :"", fechaTer :"", horaIni :"", horaTer :"", accion_id: accion_id)
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
        LibraryAPI.sharedInstance.actualizarControlUso(vehiculo._ID, patente_id :vehiculo._Patente, estado_id : estado, fechaIni :"", fechaTer :"", horaIni :"", horaTer :"", accion_id: "3")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillDisappear(animated: Bool){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Control de Uso"
        self._activity.startAnimating()
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._isSearching = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ControlUsoViewController.poblarTabla(_:)), name: "actualizarTablaControlUso", object: nil)
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.listaControlDeUso()
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
        btn.addTarget(self, action: #selector(ControlUsoViewController.EstadoPatente(_:)), forControlEvents:.TouchUpInside)
        
        if v._Estado == "1" {
            if self.switchActivarTodos.on == false {
                self.switchActivarTodos.on = true
            }
        }
        
        cell.accessoryView = btn
        return cell
    }

}
