//
//  VelocidadViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VelocidadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var switchActivarTodos: UISwitch!
    
    let priority = DispatchQueue.GlobalQueuePriority.default
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    var _vehiculos = [Vehiculo]()
    var _isSearching :Bool = false
    var _searchingVehiculos = [Vehiculo]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty {
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
        let accion: String = (sender.isOn) ? "4" : "5"
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.actualizarControlVelocidad("", patente_id : "", estado_id : "",velocidad_id: "", accion_id: accion)
        }
    }
    @IBAction func EstadoPatente(_ sender: UISwitch) {
        var vehiculo :Vehiculo
        let estado: String = (sender.isOn) ? "1" : "0"
        
        if self._isSearching == true {
            
            vehiculo =  self._searchingVehiculos[sender.superview!.tag]
            self._searchingVehiculos[sender.superview!.tag]._Estado = String(sender.tag)
            
        }else{
             vehiculo =  self._vehiculos[sender.superview!.tag]
        }
        
        DispatchQueue.global(priority: self.priority).async {
            LibraryAPI.sharedInstance.actualizarControlVelocidad(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : estado,velocidad_id: "", accion_id: "3")
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._isSearching = false
        NotificationCenter.default.addObserver(self, selector:#selector(VelocidadViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarListaControlVelocidad"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Velocidad Máxima"
        
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.listaControlVelocidad()
            self._activity.startAnimating()
        }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let btn = UISwitch(frame: CGRect(x: 30, y: 30, width: 50, height: 30))
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        
        cell.tag = indexPath.row
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        
        let estado : Bool = (v._Estado == "1") ? true : false
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(VelocidadViewController.EstadoPatente(_:)), for:.touchUpInside)
        
        if v._Estado == "1" {
            if self.switchActivarTodos.isOn == false {
                self.switchActivarTodos.isOn = true
            }
        }
        
        
        cell.accessoryView = btn
        return cell
        
    }
    
}
