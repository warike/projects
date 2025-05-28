//
//  HistorialPatenteViewExtension.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/25/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

extension HistorialPatenteViewController{
    
    func iniciarHistorialPantete() -> Void
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HistorialPatenteViewController.llenarTabla(_:)), name: "actualizarTablaVehiculos", object: nil)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        dispatch_async(dispatch_get_global_queue(priority, 0))
            {
                self._activity.startAnimating()
                LibraryAPI.sharedInstance.getListaVehiculoTodos()
        }
    }
    
    func llenarTabla(notification: NSNotification)
    {
        let user_info = notification.userInfo as! [String: AnyObject]
        let vehiculos = user_info["vehiculos"] as! [Vehiculo]!
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
            {
                self._vehiculos.removeAll(keepCapacity: true)
                self._vehiculos = vehiculos
                self.tableVehiculos.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty {
            self._isSearching = false
            self.tableVehiculos.reloadData()
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
            tableVehiculos.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self._EventoSegueIdentifier {
            if let destino = segue.destinationViewController as? HistorialEventoViewController {
                if let IndexVehiculo = tableVehiculos.indexPathForSelectedRow?.row {
                    let v: Vehiculo = self._vehiculos[IndexVehiculo]
                    destino.cargarDatos(v._Patente,gps_id: v._ID)
                    destino._vehiculo = v
                }
            }
        }
    }
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count : Int = ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
        
        return count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCellWithIdentifier("Cell")!
        cell.tag = indexPath.row
        
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        
        return cell
    }
}
