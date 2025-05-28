//
//  VehiculosListViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/19/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VehiculosListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var _vehiculos : [Vehiculo] = [Vehiculo]()
    let _editarVehiculoSegue: String = "EditarVehiculoNombre"

    @IBOutlet var tableVehiculos: UITableView!
    
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == _editarVehiculoSegue {
            if let destino = segue.destination as? VehiculoViewController {
                if let IndexEvento = self.tableVehiculos.indexPathForSelectedRow?.row {
                    destino._vehiculo = self._vehiculos[IndexEvento]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Lista Vehiculos"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._vehiculos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCell(withIdentifier: "CellVehiculo")!
        let v : Vehiculo = self._vehiculos[indexPath.row]
        let nombre :String = v._Nombre.isEmpty ? v._Patente : v._Nombre
        
        cell.textLabel?.text = nombre
        cell.detailTextLabel?.text = v._ID
        
        return cell
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func cargarDatos()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(VehiculosListViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaVehiculos"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.NombrePorPatente("", patente_id: "", nombre_id: "", accion_id: "1")
        }
    }
    
    func poblarTabla(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _vehiculosDTO = userInfo["vehiculosDTO"] as! [Vehiculo]
        
        DispatchQueue.main.async
        {
            self._vehiculos.removeAll(keepingCapacity: true)
            self._vehiculos = _vehiculosDTO
            self.tableVehiculos.reloadData()
        }
    }

}
