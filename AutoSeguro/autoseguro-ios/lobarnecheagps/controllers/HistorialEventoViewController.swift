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
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    
    @IBAction func returnSegue(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == _EventoSegueIdentifier {
            if let destino = segue.destination as? MapaEventoViewController {
                if let IndexEvento = tableEventos.indexPathForSelectedRow?.row {
                    destino._eventoDTO = self._eventos[IndexEvento]
                    destino._patente = _vehiculo._Patente
                }
            }
        }
    }
    
    func cargarDatos(_ _patente: String, gps_id: String){
        
        let priority = DispatchQueue.GlobalQueuePriority.high
        DispatchQueue.global(priority: priority).async {
            self._activity.startAnimating()
            LibraryAPI.sharedInstance.getEventos(_patente,gps_id: gps_id)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(HistorialEventoViewController.llenarTablaEventos(_:)), name: NSNotification.Name(rawValue: "actualizarTablaEventos"), object: nil)
        self.navigationItem.title = "Eventos"
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func llenarTablaEventos(_ notification: Notification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let eventos = userInfo["eventos"] as! [Evento]!
        self._activity.stopAnimating()
        self._activity.alpha = 0
        
        DispatchQueue.main.async
            {
                self._eventos.removeAll(keepingCapacity: true)
                self._eventos = eventos!
                self.tableEventos.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._eventos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell = self.tableEventos.dequeueReusableCell(withIdentifier: "CellEvento")!
        cell.tag = indexPath.row
        cell.textLabel?.text = "Evento:  \(self._eventos[indexPath.row].tipo)     \(self._eventos[indexPath.row].hora)"
        cell.detailTextLabel?.text = "Ubicación:    \(self._eventos[indexPath.row].ubicacion)"
        
        return cell
    }
}
