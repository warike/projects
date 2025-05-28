//
//  HistorialEventoViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class HistorialEventoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableEventos: UITableView!
    var _eventos = [Evento]()
    var _vehiculo :Vehiculo = Vehiculo()
    let _EventoSegueIdentifier = "verUbicacionEvento"
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    
    @IBAction func returnSegue(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == _EventoSegueIdentifier {
            if let destino = segue.destinationViewController as? MapaEventoViewController {
                if let IndexEvento = tableEventos.indexPathForSelectedRow?.row {
                    destino._eventoDTO = self._eventos[IndexEvento]
                    destino._patente = _vehiculo._Patente
                }
            }
        }
    }
    
    func cargarDatos(_patente: String, gps_id: String){
        
        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self._activity.startAnimating()
            LibraryAPI.sharedInstance.getEventos(_patente,gps_id: gps_id)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HistorialEventoViewController.llenarTablaEventos(_:)), name: "actualizarTablaEventos", object: nil)
        self.navigationItem.title = "Eventos"
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func llenarTablaEventos(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let eventos = userInfo["eventos"] as! [Evento]!
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
            {
                self._eventos.removeAll(keepCapacity: true)
                self._eventos = eventos
                self.tableEventos.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._eventos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell = self.tableEventos.dequeueReusableCellWithIdentifier("CellEvento")!
        cell.tag = indexPath.row
        cell.textLabel?.text = "Evento:  \(self._eventos[indexPath.row].tipo)     \(self._eventos[indexPath.row].hora)"
        cell.detailTextLabel?.text = "Ubicación:    \(self._eventos[indexPath.row].ubicacion)"
        
        return cell
    }
}
