//
//  UbicacionExtension.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/10/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit


extension UbicacionViewController{
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func llenarTabla(notification: NSNotification)
    {
        let user_info = notification.userInfo as! [String: AnyObject]
        let vehiculos = user_info["vehiculos"] as! [Flota]!
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
        {
                self._vehiculos.removeAll(keepCapacity: true)
                self._vehiculos = vehiculos
                self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty
        {
            self._isSearching = false
            self.tableView.reloadData()
        } else {
            self._isSearching = true
            self._searchingVehiculos.removeAll(keepCapacity: true)
            for index in 0 ..< self._vehiculos.count
            {
                let v = self._vehiculos[index] as Flota
                if v._patente.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil  || v._nombre.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    self._searchingVehiculos.append(v)
                }
            }
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filas :Int = ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
        return filas+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Todos los Vehiculos"
            cell.detailTextLabel?.text = ""
            
            return cell
        } else {
            
            let index :Int = indexPath.row - 1
            cell.tag = index
            
            let v: Flota = (self._isSearching == true) ? self._searchingVehiculos[index] : self._vehiculos[index]
            
            let nombre: String = (v._nombre == "") ? v._patente : v._nombre
            cell.textLabel?.text = "\(nombre) -  \(v._ignicion)"
            cell.detailTextLabel?.text = "\(v._ubicacion)"
        
        }
        
        
        return cell
    }
    
}