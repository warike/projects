//
//  NotificacionViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/14/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class NotificacionViewController: UIViewController, UITableViewDelegate{

    @IBOutlet var tablaNotificaciones: UITableView!
    
    var _notificaciones : [Notificacion] = [Notificacion]()
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

    @IBAction func CambiarEstado(_ sender: UISwitch) {
        if self.validarNotificaciones(sender) {
            let estado_id :String = (sender.isOn) ? "1" : "0"
            LibraryAPI.sharedInstance.ActualizarNotificaciones("2", estado_id: estado_id, notificacion_id: "\(sender.tag)")
        }
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(NotificacionViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaNotificaciones"), object: nil)
        LibraryAPI.sharedInstance.ActualizarNotificaciones("1", estado_id: "", notificacion_id: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Notificaciones"
        
        self._activity.startAnimating()
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validarNotificaciones(_ sender: UISwitch) -> Bool
    {
        var flag : Bool = true
        if sender.tag == 1 || sender.tag == 2 {
            let cell : UITableViewCell = self.tablaNotificaciones.cellForRow(at: IndexPath(row: 0, section: 0))!
            let cellMovimiento : UITableViewCell = self.tablaNotificaciones.cellForRow(at: IndexPath(row: 1, section: 0))!
            
            let btnSwitch : UISwitch = cell.accessoryView as! UISwitch
            let btnSwitchMovimiento : UISwitch = cellMovimiento.accessoryView as! UISwitch
            
            if !btnSwitch.isOn && !btnSwitchMovimiento.isOn
            {
                flag = false
                sender.isOn = true
            }
        }
        return flag
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._notificaciones.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tablaNotificaciones.dequeueReusableCell(withIdentifier: "CellNotificacion")!
        cell.textLabel?.text = "\(self._notificaciones[indexPath.row].Descripcion)"
        cell.detailTextLabel?.text = "\(self._notificaciones[indexPath.row].Leyenda)"
        
        
        let btn = UISwitch(frame: CGRect(x: 30, y: 30, width: 50, height: 30))
        let n: Notificacion = self._notificaciones[indexPath.row]
        let estado : Bool = (n.Estado == "1") ? true : false
        

        btn.tag = Int(n.GPS)!
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(NotificacionViewController.CambiarEstado(_:)), for:.touchUpInside)
        cell.accessoryView = btn
        
        return cell
    }
    
    func poblarTabla(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _notificacionesDTO = userInfo["notificacionesDTO"] as! [Notificacion]
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        DispatchQueue.main.async
            {
                self._notificaciones.removeAll(keepingCapacity: true)
                self._notificaciones = _notificacionesDTO
                self.tablaNotificaciones.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
