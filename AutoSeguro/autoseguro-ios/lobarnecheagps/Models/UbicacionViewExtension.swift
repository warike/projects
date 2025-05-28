//
//  UbicacionExtension.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/10/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit


extension UbicacionViewController{
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func llenarTabla(_ notification: Notification)
    {
        let user_info = notification.userInfo as! [String: AnyObject]
        let vehiculos = user_info["vehiculos"] as! [Flota]!
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        DispatchQueue.main.async
        {
                self._vehiculos.removeAll(keepingCapacity: true)
                self._vehiculos = vehiculos!
                self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty
        {
            self._isSearching = false
            self.tableView.reloadData()
        } else {
            self._isSearching = true
            self._searchingVehiculos.removeAll(keepingCapacity: true)
            for index in 0 ..< self._vehiculos.count
            {
                let v = self._vehiculos[index] as Flota
                if v._patente.lowercased().range(of: searchText.lowercased())  != nil  || v._nombre.lowercased().range(of: searchText.lowercased())  != nil {
                    self._searchingVehiculos.append(v)
                }
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filas :Int = ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
        return filas+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        
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
