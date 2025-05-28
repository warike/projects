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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func llenarTabla(notification: NSNotification)
    {
        let user_info = notification.userInfo as! [String: AnyObject]
        var vehiculos = user_info["vehiculos"] as! [Flota]!
        
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
        if searchBar.text.isEmpty
        {
            self._isSearching = false
            self.tableView.reloadData()
        } else {
            self._isSearching = true
            self._searchingVehiculos.removeAll(keepCapacity: true)
            for var index = 0; index < self._vehiculos.count; index++
            {
                var v = self._vehiculos[index] as Flota
                if v._patente.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil  || v._nombre.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    self._searchingVehiculos.append(v)
                }
            }
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell.tag = indexPath.row
        
        let v: Flota = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]

        cell.textLabel?.text = "\(v._modelo) -  \(v._ignicion)"
        cell.detailTextLabel?.text = "\(v._ubicacion)"
        
        return cell
    }
    
}