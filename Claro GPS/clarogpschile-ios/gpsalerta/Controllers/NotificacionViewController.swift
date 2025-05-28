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
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    @IBAction func CambiarEstado(sender: UISwitch) {
        if self.validarNotificaciones(sender) {
            let estado_id :String = (sender.on) ? "1" : "0"
            LibraryAPI.sharedInstance.ActualizarNotificaciones("2", estado_id: estado_id, notificacion_id: "\(sender.tag)")
        }
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NotificacionViewController.poblarTabla(_:)), name: "actualizarTablaNotificaciones", object: nil)
        LibraryAPI.sharedInstance.ActualizarNotificaciones("1", estado_id: "", notificacion_id: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Notificaciones"
        
        self._activity.startAnimating()
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func validarNotificaciones(sender: UISwitch) -> Bool
    {
        var flag : Bool = true
        if sender.tag == 1 || sender.tag == 2 {
            let cell : UITableViewCell = self.tablaNotificaciones.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
            let cellMovimiento : UITableViewCell = self.tablaNotificaciones.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))!
            
            let btnSwitch : UISwitch = cell.accessoryView as! UISwitch
            let btnSwitchMovimiento : UISwitch = cellMovimiento.accessoryView as! UISwitch
            
            if !btnSwitch.on && !btnSwitchMovimiento.on {
                flag = false
                sender.on = true
            }
            
        }
        return flag
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._notificaciones.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tablaNotificaciones.dequeueReusableCellWithIdentifier("CellNotificacion")!
        cell.textLabel?.text = "\(self._notificaciones[indexPath.row].Descripcion)"
        cell.detailTextLabel?.text = "\(self._notificaciones[indexPath.row].Leyenda)"
        
        
        let btn = UISwitch(frame: CGRectMake(30, 30, 50, 30))
        let n: Notificacion = self._notificaciones[indexPath.row]
        let estado : Bool = (n.Estado == "1") ? true : false
        

        btn.tag = Int(n.GPS)!
        btn.setOn(estado, animated: true)
        btn.addTarget(self, action: #selector(NotificacionViewController.CambiarEstado(_:)), forControlEvents:.TouchUpInside)
        cell.accessoryView = btn
        
        return cell
    }
    
    func poblarTabla(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _notificacionesDTO = userInfo["notificacionesDTO"] as! [Notificacion]
        
        
        self._activity.stopAnimating()
        self._activity.alpha = 0
        dispatch_async(dispatch_get_main_queue())
            {
                self._notificaciones.removeAll(keepCapacity: true)
                self._notificaciones = _notificacionesDTO
                self.tablaNotificaciones.reloadData()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
