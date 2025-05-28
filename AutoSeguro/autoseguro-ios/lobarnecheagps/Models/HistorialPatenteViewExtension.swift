//
//  HistorialPatenteViewExtension.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 9/25/15.
//  Copyright © 2015 SAMTECH SA. All rights reserved.
//

import UIKit

extension HistorialPatenteViewController{
    
    func iniciarHistorialPantete() -> Void
    {
        NotificationCenter.default.addObserver(self, selector:#selector(HistorialPatenteViewController.llenarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaVehiculos"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.default
        
        DispatchQueue.global(priority: priority).async
            {
                self._activity.startAnimating()
                LibraryAPI.sharedInstance.getListaVehiculoTodos()
        }
    }
    
    func llenarTabla(_ notification: Notification)
    {
        let user_info = notification.userInfo as! [String: AnyObject]
        let vehiculos = user_info["vehiculos"] as! [Vehiculo]!
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        DispatchQueue.main.async
            {
                self._vehiculos.removeAll(keepingCapacity: true)
                self._vehiculos = vehiculos!
                self.tableVehiculos.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty {
            self._isSearching = false
            self.tableVehiculos.reloadData()
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
            tableVehiculos.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self._EventoSegueIdentifier {
            if let destino = segue.destination as? HistorialEventoViewController {
                if let IndexVehiculo = tableVehiculos.indexPathForSelectedRow?.row {
                    let v: Vehiculo = self._vehiculos[IndexVehiculo]
                    destino.cargarDatos(v._Patente,gps_id: v._ID)
                    destino._vehiculo = v
                }
            }
        }
    }
    
    @IBAction func returnMainMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count : Int = ((self._isSearching == true) ? self._searchingVehiculos.count : self._vehiculos.count)
        
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCell(withIdentifier: "Cell")!
        cell.tag = indexPath.row
        
        let v: Vehiculo = (self._isSearching == true) ? self._searchingVehiculos[indexPath.row] : self._vehiculos[indexPath.row]
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        
        return cell
    }
}
