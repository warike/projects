//
//  VelocidadesListViewController.swift
//  Claro GPS Alerta
//
//  Created by RWBook Retina on 8/19/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VelocidadesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var _vehiculos : [Vehiculo] = [Vehiculo]()
    var _indexPath : NSIndexPath?
    let _mensajeVelocidadMinima : String = "Velocidad no puede ser menor a 50 Km/Hr"

    @IBOutlet var tableVehiculos: UITableView!
    
    @IBAction func guardarCambios(sender :UIBarButtonItem) {
        self.GuardarCambios()
    }
    @IBAction func returnSegue() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Velocidades Máx."
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func generarAlerta(mensaje :String, titulo :String, btnTitulo :String)
    {
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.Cancel, handler: nil ))
            presentViewController(sosAlert, animated: true, completion: nil)
            
        } else if iOS7 {
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = titulo
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(btnTitulo)
            sosAlert.show()
        }
    }

    
    func GuardarCambios() -> Void
    {
        let indexPath = self._indexPath
        if(indexPath != nil){
            let cell : UITableViewCell = self.tableVehiculos.cellForRowAtIndexPath(indexPath!)!
            let textField : UITextField = cell.accessoryView as! UITextField
            let velocidad : Int = NSString(string: textField.text!).integerValue
            let velocidad_actual : Int = NSString(string: self._vehiculos[indexPath!.row]._Velocidad).integerValue
            
            if velocidad <= 50
            {
                generarAlerta(self._mensajeVelocidadMinima, titulo: "Alerta", btnTitulo: "OK")
                return
            }
            
            if velocidad_actual != velocidad
            {
                
                cell.detailTextLabel?.text = "Velocidad Max: \(velocidad)"
                let vehiculo :Vehiculo = self._vehiculos[indexPath!.row]
                vehiculo._Velocidad = "\(velocidad)"
                LibraryAPI.sharedInstance.actualizarControlVelocidad(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : "", velocidad_id: vehiculo._Velocidad, accion_id: "2")
            }
            cell.accessoryView = nil
        }
        self.DismissKeyboard()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._vehiculos.count
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell : UITableViewCell = self.tableVehiculos.cellForRowAtIndexPath(indexPath)!
        cell.accessoryView = nil
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        self._indexPath = indexPath
        
        let textField = UITextField()
        textField.keyboardType = UIKeyboardType.NumberPad
        textField.placeholder = "0"
        textField.text = self._vehiculos[indexPath.row]._Velocidad
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.frame = CGRectMake(30, 30, 70, 20)
        textField.delegate = self
        
        cell.accessoryView = (textField)
        textField.becomeFirstResponder()
        
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(VelocidadesListViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.GuardarCambios()
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCellWithIdentifier("CellVelocidad")!
        let v: Vehiculo = self._vehiculos[indexPath.row]
        let velMax :String = (v._Velocidad == "") ? "0" : v._Velocidad
        
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        cell.detailTextLabel?.text = "Velocidad Max: \(velMax)"

        return cell
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cargarDatos()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(VelocidadesListViewController.poblarTabla(_:)), name: "actualizarTablaVehiculos", object: nil)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            LibraryAPI.sharedInstance.getListaVehiculoTodos()
        }
    }
    
    func poblarTabla(notification: NSNotification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _vehiculosDTO = userInfo["vehiculos"] as! [Vehiculo]
        
        self._vehiculos.removeAll(keepCapacity: true)
        self._vehiculos = _vehiculosDTO
        self.tableVehiculos.reloadData()
    }
    
}
