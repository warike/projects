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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == _editarVehiculoSegue {
            if let destino = segue.destinationViewController as? VehiculoViewController {
                if let IndexEvento = self.tableVehiculos.indexPathForSelectedRow?.row {
                    destino._vehiculo = self._vehiculos[IndexEvento]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lista Vehiculos"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._vehiculos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCellWithIdentifier("CellVehiculo")!
        let v : Vehiculo = self._vehiculos[indexPath.row]
        let nombre :String = v._Nombre.isEmpty ? v._Patente : v._Nombre
        
        cell.textLabel?.text = nombre
        cell.detailTextLabel?.text = v._ID
        
        return cell
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cargarDatos()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VehiculosListViewController.poblarTabla(_:)), name: "actualizarTablaVehiculos", object: nil)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.NombrePorPatente("", patente_id: "", nombre_id: "", accion_id: "1")
        }
    }
    
    func poblarTabla(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _vehiculosDTO = userInfo["vehiculosDTO"] as! [Vehiculo]
        
        dispatch_async(dispatch_get_main_queue())
            {
                self._vehiculos.removeAll(keepCapacity: true)
                self._vehiculos = _vehiculosDTO
                self.tableVehiculos.reloadData()
        }
    }

}
