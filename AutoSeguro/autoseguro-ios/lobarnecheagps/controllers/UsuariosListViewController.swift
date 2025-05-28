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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == _verUsuarioSegue {
            if let destino = segue.destination as? UsuarioViewController {
                if let IndexEvento = tableUsuarios.indexPathForSelectedRow?.row
                {
                    destino._usuario = self._usuarios[IndexEvento]
                    destino._isEditing = true
                    destino._textTitulo = "Editar Usuario"
                }
                else
                {
                    destino._isEditing = false
                    destino._textTitulo = "Crear Usuario"
                }
            }
        }
    }
    
    @IBAction func crearUsuarioBtn(_ sender: UIBarButtonItem) {
        if let index = self.tableUsuarios.indexPathForSelectedRow
        {
            self.tableUsuarios.deselectRow(at: index, animated: true)
        }
        
        self.performSegue(withIdentifier: _verUsuarioSegue, sender: self)
    }
    
    func editarUsuario(){
        self.performSegue(withIdentifier: _verUsuarioSegue, sender: self)
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Lista"
        
        let btnNuevo :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(UsuariosListViewController.crearUsuarioBtn(_:)))
        self.navigationItem.rightBarButtonItem = btnNuevo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._usuarios.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editarUsuario()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableUsuarios.dequeueReusableCell(withIdentifier: "CellUsuario")!
        let u : Usuario = self._usuarios[indexPath.row]
        let nombre : String =  u.nombre == "" ?  u.ilogin : u.nombre
        
        cell.textLabel?.text = nombre
        return cell
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func cargarDatos()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(UsuariosListViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaUsuarios"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.high
        
        DispatchQueue.global(priority: priority).async
        {
            LibraryAPI.sharedInstance.getListaUsuarios()
        }
    }
    
    func poblarTabla(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _usuariosDTO = userInfo["usuariosDTO"] as! [Usuario]
        
        DispatchQueue.main.async
        {
                self._usuarios.removeAll(keepingCapacity: true)
                self._usuarios = _usuariosDTO
                self.tableUsuarios.reloadData()
        }
    }
}
