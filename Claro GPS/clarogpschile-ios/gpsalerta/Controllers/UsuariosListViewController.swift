//
//  UsuariosListViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/18/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class UsuariosListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet var tableUsuarios: UITableView!
    var _usuarios : [Usuario] = [Usuario]()
    let _verUsuarioSegue : String = "verUsuario"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == _verUsuarioSegue {
            if let destino = segue.destinationViewController as? UsuarioViewController {
                if let IndexEvento = tableUsuarios.indexPathForSelectedRow?.row {
                    destino._usuario = self._usuarios[IndexEvento]
                    destino._isEditing = true
                    destino._textTitulo = "Editar Usuario"
                }else{
                    destino._isEditing = false
                    destino._textTitulo = "Crear Usuario"
                }
            }
        }
    }
    
    @IBAction func crearUsuarioBtn(sender: UIBarButtonItem) {
        if let index = self.tableUsuarios.indexPathForSelectedRow {
            self.tableUsuarios.deselectRowAtIndexPath(index, animated: true)
        }
        
        self.performSegueWithIdentifier(_verUsuarioSegue, sender: self)
    }
    
    func editarUsuario(){
        self.performSegueWithIdentifier(_verUsuarioSegue, sender: self)
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lista"
        
        let btnNuevo :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(UsuariosListViewController.crearUsuarioBtn(_:)))
        self.navigationItem.rightBarButtonItem = btnNuevo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._usuarios.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        editarUsuario()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableUsuarios.dequeueReusableCellWithIdentifier("CellUsuario")!
        let u : Usuario = self._usuarios[indexPath.row]
        let nombre : String =  u.nombre == "" ?  u.ilogin : u.nombre
        
        cell.textLabel?.text = nombre
        
        return cell
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cargarDatos()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(UsuariosListViewController.poblarTabla(_:)), name: "actualizarTablaUsuarios", object: nil)
        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.getListaUsuarios()
        }
    }
    
    func poblarTabla(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _usuariosDTO = userInfo["usuariosDTO"] as! [Usuario]
        
        dispatch_async(dispatch_get_main_queue())
            {
                self._usuarios.removeAll(keepCapacity: true)
                self._usuarios = _usuariosDTO
                self.tableUsuarios.reloadData()
        }
    }
}
