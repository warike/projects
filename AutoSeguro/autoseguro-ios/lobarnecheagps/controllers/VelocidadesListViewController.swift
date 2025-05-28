//
//  VelocidadesListViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/19/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VelocidadesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var _vehiculos : [Vehiculo] = [Vehiculo]()
    var _indexPath : IndexPath?
    let _mensajeVelocidadMinima : String = "Velocidad no puede ser menor a 50 Km/Hr"
    
    
    @IBOutlet var tableVehiculos: UITableView!
    
    
    @IBAction func guardarCambios(_ sender :UIBarButtonItem) {
        self.GuardarCambios()
    }
    
    @IBAction func returnSegue() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func generarAlerta(_ mensaje :String, titulo :String, btnTitulo :String)
    {
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            sosAlert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.cancel, handler: nil ))
            present(sosAlert, animated: true, completion: nil)
        
        } else if iOS7 {
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = titulo
            sosAlert.message = mensaje
            sosAlert.addButton(withTitle: btnTitulo)
            sosAlert.show()
        }
    }
    
    func GuardarCambios() -> Void
    {
        let indexPath = self._indexPath
        if(indexPath != nil){
            let cell : UITableViewCell = self.tableVehiculos.cellForRow(at: indexPath!)!
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._vehiculos.count
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let cell : UITableViewCell = self.tableVehiculos.cellForRow(at: indexPath)!
        cell.accessoryView = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        self._indexPath = indexPath
        
        let textField = UITextField()
        textField.keyboardType = UIKeyboardType.numberPad
        textField.placeholder = "0"
        textField.text = self._vehiculos[indexPath.row]._Velocidad
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.frame = CGRect(x: 30, y: 30, width: 70, height: 20)
        textField.delegate = self
        
        cell.accessoryView = (textField)
        textField.becomeFirstResponder()
        
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VelocidadesListViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.GuardarCambios()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableVehiculos.dequeueReusableCell(withIdentifier: "CellVelocidad")!
        let v: Vehiculo = self._vehiculos[indexPath.row]
        let velMax :String = (v._Velocidad == "") ? "0" : v._Velocidad
        
        cell.textLabel?.text = (v._Nombre == "") ? v._Patente : v._Nombre
        cell.detailTextLabel?.text = "Velocidad Max: \(velMax)"

        return cell
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func cargarDatos()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(VelocidadesListViewController.poblarTabla(_:)), name: NSNotification.Name(rawValue: "actualizarTablaVehiculos"), object: nil)
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            LibraryAPI.sharedInstance.getListaVehiculoTodos()
        }
    }
    
    func poblarTabla(_ notification: Notification) -> Void
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let _vehiculosDTO = userInfo["vehiculos"] as! [Vehiculo]
        
        self._vehiculos.removeAll(keepingCapacity: true)
        self._vehiculos = _vehiculosDTO
        self.tableVehiculos.reloadData()
    }
    
}
