//
//  ControlUsoListViewController.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/19/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class ControlUsoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var _vehiculos = [Vehiculo]()
    var _notificaciones = [Notificacion]()
    
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ControlUsoConf" {
            if let destino = segue.destinationViewController as? ControlUsoConfiguracionViewController {
                if let IndexEvento = self.tableView.indexPathForSelectedRow?.row {
                    destino._notificacion = self._notificaciones[IndexEvento]
                }
            }
        }
    }

    @IBAction func returnMainMenu() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Control de Uso"
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._activity.startAnimating()
        
        LibraryAPI.sharedInstance.listaControlDeUso()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ControlUsoListViewController.poblarTabla(_:)), name: "actualizarTablaControlUso", object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func poblarTabla(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let vehiculos = userInfo["vehiculos"] as! [Vehiculo]!
        let notificaciones = userInfo["notificaciones"] as! [Notificacion]!
        
        self._vehiculos.removeAll(keepCapacity: false)
        self._notificaciones.removeAll(keepCapacity: false)
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        self._notificaciones = notificaciones
        self._vehiculos = vehiculos
        self.tableView.reloadData()
    }
    
    /* IMPLEMENTACION LOGICA TABLA*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._vehiculos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.tag = indexPath.row
        
        
        let v: Vehiculo = self._vehiculos[indexPath.row]
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        return cell
    }
    
}