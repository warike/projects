//
//  ContactosListViewController.swift
//  TrackliteCL
//
//  Created by RWBook Retina on 10/20/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class ContactosListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableContactos: UITableView!
    var _contactos : [Contacto] = [Contacto]()
    let _editarContactoSegue: String = "EditarContactoNombre"

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self._editarContactoSegue {
            if let destino = segue.destination as? ContactoViewController {
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
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.cargarUI()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func crearContactoBtn(_ sender: AnyObject){
        if let index = self.tableContactos.indexPathForSelectedRow
        {
            self.tableContactos.deselectRow(at: index, animated: true)
        }
        self.performSegue(withIdentifier: self._editarContactoSegue, sender: self)
    }
    
    func cargarUI()
    {
        let titulo = "Contactos"
        let btnNuevo :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ContactosListViewController.crearContactoBtn(_:)))
        
        self.navigationItem.title = titulo
        self.navigationItem.rightBarButtonItem = btnNuevo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._contactos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editarContacto()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableContactos.dequeueReusableCell(withIdentifier: "CellContacto")!
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
        NotificationCenter.default.removeObserver(self)
    }

    func editarContacto() -> Void
    {
        self.performSegue(withIdentifier: self._editarContactoSegue, sender: self)
    }
    
    func cargarDatos() -> Void
    {
        NotificationCenter.default.addObserver(self, selector:#selector(ContactosListViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaContactos"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.high
        
        DispatchQueue.global(priority: priority).async
        {
            LibraryAPI.sharedInstance.ContactoList("", nombre_id: "", telefono_id: "", mail_id: "", accion_id: "1")
        }
    }
    
    func poblarTabla(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _contactosDTO = userInfo["contactosDTO"] as! [Contacto]
        
        DispatchQueue.main.async
        {
            self._contactos.removeAll(keepingCapacity: true)
            self._contactos = _contactosDTO
            self.tableContactos?.reloadData()
        }
        

    }
    
}
