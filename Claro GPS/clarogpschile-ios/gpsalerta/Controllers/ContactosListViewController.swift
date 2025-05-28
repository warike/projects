//
//  ContactosListViewController.swift
//  gpsalerta
//
//  Created by RWBook Retina on 10/30/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class ContactosListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var tableContactos: UITableView!
    var _contactos : [Contacto] = [Contacto]()
    let _editarContactoSegue: String = "EditarContactoNombre"
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self._editarContactoSegue {
            if let destino = segue.destinationViewController as? ContactoViewController {
                if let IndexEvento = self.tableContactos.indexPathForSelectedRow?.row
                {
                    destino._contacto = self._contactos[IndexEvento]
                    destino.isNew = false
                }
                else
                {
                    destino.isNew = true
                    destino._contacto = Contacto()
                }
                
            }
        }
    }
    @IBAction func returnSegue()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.cargarUI()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func crearContactoBtn(sender: AnyObject){
        if let index = self.tableContactos.indexPathForSelectedRow
        {
            self.tableContactos.deselectRowAtIndexPath(index, animated: true)
        }
        self.performSegueWithIdentifier(self._editarContactoSegue, sender: self)
    }
    
    func cargarUI()
    {
        let titulo = "Contactos"
        let btnNuevo :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(ContactosListViewController.crearContactoBtn(_:)))
        
        self.navigationItem.title = titulo
        self.navigationItem.rightBarButtonItem = btnNuevo
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._contactos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.editarContacto()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableContactos.dequeueReusableCellWithIdentifier("CellContacto")!
        let v : Contacto = self._contactos[indexPath.row]
        let nombre :String = v.Nombre.isEmpty ? v.Mail : v.Nombre
        
        cell.textLabel?.text = nombre
        cell.detailTextLabel?.text = v.Telefono
        
        return cell
    }
    
    deinit
    {
        self.desvincularNotificaciones()
    }
    
    func desvincularNotificaciones() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func editarContacto() -> Void
    {
        self.performSegueWithIdentifier(self._editarContactoSegue, sender: self)
    }
    
    func cargarDatos() -> Void
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ContactosListViewController.poblarTabla(_:)), name: "actualizarTablaContactos", object: nil)
        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
        
        dispatch_async(dispatch_get_global_queue(priority, 0))
            {
                LibraryAPI.sharedInstance.ContactoList("", nombre_id: "", telefono_id: "", mail_id: "", accion_id: "1")
        }
    }
    
    func poblarTabla(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _contactosDTO = userInfo["contactosDTO"] as! [Contacto]
        
        dispatch_async(dispatch_get_main_queue())
            {
                self._contactos.removeAll(keepCapacity: true)
                self._contactos = _contactosDTO
                self.tableContactos?.reloadData()
        }
        
        
    }


}
