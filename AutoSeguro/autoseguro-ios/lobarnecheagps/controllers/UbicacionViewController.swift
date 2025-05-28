//
//  UbicacionViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class UbicacionViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    
    let _mapaVehiculoSegue = "verMapaVehiculo"
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

    var _isSearching:Bool = false
    var _searchingVehiculos = [Flota]()
    var _vehiculos = [Flota]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self._mapaVehiculoSegue {
            if let destino = segue.destination as? MapaUbicacionViewController {
                if let IndexVehiculo = tableView.indexPathForSelectedRow?.row {
                    
                    if IndexVehiculo == 0{
                        destino._vehiculosDTO = self._vehiculos
                        destino._verTodos = true
                    }else {
                        let v: Flota = self._vehiculos[IndexVehiculo-1]
                        destino._vehiculoDTO = Vehiculo(patente_id: v._patente, gps_id: v._gps, nombre_id: v._nombre, velocidad_id: v._velocidad, estado_id: v._estado)
                        destino._verTodos = false
                    }
                    
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Ubicación"
        self._activity.startAnimating()
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        self.iniciarUbicacionVehiculo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func iniciarUbicacionVehiculo() -> Void
    {
        NotificationCenter.default.addObserver(self, selector:"llenarTabla:", name: NSNotification.Name(rawValue: "actualizarFlotaVehiculos"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.default
        
        DispatchQueue.global(priority: priority).async
            {
                LibraryAPI.sharedInstance.DatosPorFlota()
        }
    }
}
