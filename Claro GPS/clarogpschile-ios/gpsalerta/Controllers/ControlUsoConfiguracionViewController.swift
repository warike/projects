//
//  ControlUsoConfiguracionViewController.swift
//  gpsalerta
//
//  Created by RWBook Retina on 9/21/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class ControlUsoConfiguracionViewController: UIViewController, UIPickerViewDelegate {
    
    var _notificacion : Notificacion = Notificacion()
    
    let dias : [String] = ["Domingo", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
    let horas : [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
    let minutos : [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
    
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    var _indexFechaIni : Int = 0
    var _indexFechaTer : Int = 0
    
    var _indexHoraIniHor : Int = 0
    var _indexHoraIniMin : Int = 0
    
    var _indexHoraTerHor : Int = 0
    var _indexHoraTerMin : Int = 0
    var _tipoDia : Bool = true
    
    
    @IBOutlet var gps_id: UILabel!
    @IBOutlet var patente_id: UILabel!
    @IBOutlet var fechaIni: UILabel!
    @IBOutlet var fechaTer: UILabel!
    @IBOutlet var horaIni: UILabel!
    @IBOutlet var horaTer: UILabel!

    @IBOutlet var btnFechaIni: UIButton!
    @IBOutlet var btnFechaTer: UIButton!

    @IBOutlet var btnHoraIni: UIButton!
    @IBOutlet var btnHoraTer: UIButton!
    
    @IBOutlet var pickerDias: UIPickerView!

    
    @IBAction func GuardarCambios(sender: AnyObject) {
        
        let patente = self.patente_id.text!
        let gps = self.gps_id.text!
        let fechaIni :String = String(self._indexFechaIni)
        let fechaTer :String = String(self._indexFechaTer)
        
        let horaIni :String = String(self.horaIni.text!+":00").stringByReplacingOccurrencesOfString(":", withString: "-")
        let horaTer :String = String(self.horaTer.text!+":00").stringByReplacingOccurrencesOfString(":", withString: "-")
        
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
        self._activity.startAnimating()
        
        
        LibraryAPI.sharedInstance.actualizarControlUso(gps, patente_id :patente, estado_id : "1", fechaIni : fechaIni, fechaTer : fechaTer, horaIni :horaIni, horaTer : horaTer, accion_id: "2")
        
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return (self._tipoDia) ? 1 : 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        if self._tipoDia {
            return self.dias.count
        }else{
        
            if component == 0
            {
                return self.horas.count
            }
            else
            {
                return self.minutos.count
            }
        }
        
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self._tipoDia {
            return self.dias[row]
        } else {
            if component == 0
            {
                return self.horas[row]
            }
            else
            {
                return self.minutos[row]
            }
        }
        
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        
        if self._tipoDia {
            let value : String = self.dias[row]
            if self.pickerDias.tag == 0 {
                self.fechaIni.text = value
                self._indexFechaIni = row
            } else if pickerDias.tag == 1 {
                self.fechaTer.text = value
                self._indexFechaTer = row
            }
    
        } else {
            
            if component == 0
            {
                let value : String = self.horas[row]
                if pickerDias.tag == 2 {
                    self._indexHoraIniHor = Int(value)!
                } else if self.pickerDias.tag == 3 {
                    self._indexHoraTerHor = Int(value)!
                }
            }
            else
            {
                let value : String = self.minutos[row]
                if pickerDias.tag == 2 {
                    self._indexHoraIniMin = Int(value)!
                    
                } else if self.pickerDias.tag == 3 {
                    self._indexHoraTerMin = Int(value)!
                }
            }
            
            if self.pickerDias.tag == 2 {
                let hora = (self._indexHoraIniHor < 10) ? "0\(self._indexHoraIniHor)" : "\(self._indexHoraIniHor)"
                let min = (self._indexHoraIniMin < 10) ? "0\(self._indexHoraIniMin)" : "\(self._indexHoraIniMin)"
                
                self.horaIni?.text = String("\(hora):\(min)")
                
            } else if self.pickerDias.tag == 3 {
                let hora = (self._indexHoraTerHor < 10) ? "0\(self._indexHoraTerHor)" : "\(self._indexHoraTerHor)"
                let min = (self._indexHoraTerMin < 10) ? "0\(self._indexHoraTerMin)" : "\(self._indexHoraTerMin)"
                
                self.horaTer?.text = String("\(hora):\(min)")
            }
        }
    }
    
    @IBAction func CambiarFecha(sender: UIButton) {

        self.pickerDias.alpha = 0
    
        if sender.tag == 0 {
            self._tipoDia = true
            self.pickerDias.tag = sender.tag
            self.pickerDias.selectRow(self._indexFechaIni, inComponent: 0, animated: true)
            self.pickerDias.reloadAllComponents()
            self.pickerDias.alpha = 1
            
        } else if sender.tag == 1 {
            self._tipoDia = true
            self.pickerDias.tag = sender.tag
            self.pickerDias.selectRow(self._indexFechaTer, inComponent: 0, animated: true)
            self.pickerDias.reloadAllComponents()
            self.pickerDias.alpha = 1
            
        } else if sender.tag == 2 {
            self._tipoDia = false
            self.pickerDias.tag = sender.tag
            self.pickerDias.reloadAllComponents()
            self.pickerDias.selectRow(self._indexHoraIniHor, inComponent: 0, animated: true)
            self.pickerDias.selectRow(self._indexHoraIniMin, inComponent: 1, animated: true)
            self.pickerDias.alpha = 1
            
        } else if  sender.tag == 3 {
            self._tipoDia = false
            self.pickerDias.tag = sender.tag
            self.pickerDias.reloadAllComponents()
            self.pickerDias.selectRow(self._indexHoraTerHor, inComponent: 0, animated: true)
            self.pickerDias.selectRow(self._indexHoraTerMin, inComponent: 1, animated: true)
            self.pickerDias.alpha = 1
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cargarDatos()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Vehiculo"
        
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ControlUsoConfiguracionViewController.GuardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        self.pickerDias.alpha = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ControlUsoConfiguracionViewController.mensajeControlUso(_:)), name: "actualizarControlUso", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func returnSegue(){
    
        LibraryAPI.sharedInstance.listaControlDeUso()
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func mensajeControlUso(notification: NSNotification){
        
        let userInfo = notification.userInfo as! [String: AnyObject]
        let mensaje = userInfo["mensaje"] as! String
        let respuesta = userInfo["respuesta"] as! Bool
        let title = "Respuesta Actualización"
        let title_btn = "OK"
        
        self._activity.stopAnimating()
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ControlUsoConfiguracionViewController.GuardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
        
        
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: title, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: title_btn, style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) in
                if respuesta{
                    self.returnSegue()
                }
            }))
            self.presentViewController(sosAlert, animated: true, completion: nil)
        }
        else if iOS7
        {
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = title
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(title_btn)
            sosAlert.show()
            sosAlert.tag = (respuesta) ? 1 : 0
        }
        
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 0:
            if View.tag == 1 {
                self.returnSegue()
            }
            
            break;
        default:
            break;
            
        }
    }
    
    deinit {
        self.desvincularNotificaciones()
    }
    
    override func viewWillDisappear(animated: Bool){
        self.desvincularNotificaciones()
    }
    
    func desvincularNotificaciones()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cargarDatos() -> Void {
        self.gps_id?.text = self._notificacion.GPS
        self.patente_id?.text = self._notificacion.Patente
        
        if !self._notificacion.FechaIni.isEmpty {
            self.fechaIni?.text = self.dias[Int(self._notificacion.FechaIni)!]
            self._indexFechaIni = Int(self._notificacion.FechaIni)!
        }else {
            self.fechaIni?.text = self.dias[0]
            self._indexFechaIni = 0
        }
        
        if !self._notificacion.FechaTer.isEmpty {
            self.fechaTer?.text = self.dias[Int(self._notificacion.FechaTer)!]
            self._indexFechaTer = Int(self._notificacion.FechaTer)!
        } else {
            self.fechaTer?.text = self.dias[0]
            self._indexFechaTer = 0
        }
        
        
        
        

        if self._notificacion.HoraIni.characters.count > 5 &&  self._notificacion.HoraTer.characters.count > 5{

            let horaIniRange = Range(start: self._notificacion.HoraIni.startIndex, end: self._notificacion.HoraIni.startIndex.advancedBy(2))
            let horaTerRange = Range(start: self._notificacion.HoraTer.startIndex, end: self._notificacion.HoraTer.startIndex.advancedBy(2))
            
            let minIniRange = Range(start: self._notificacion.HoraIni.startIndex.advancedBy(3), end: self._notificacion.HoraIni.startIndex.advancedBy(5))
            let minTerRange = Range(start: self._notificacion.HoraTer.startIndex.advancedBy(3), end: self._notificacion.HoraTer.startIndex.advancedBy(5))
            
            
            self._indexHoraIniHor = Int(self._notificacion.HoraIni.substringWithRange(horaIniRange))!
            self._indexHoraTerHor = Int(self._notificacion.HoraTer.substringWithRange(horaTerRange))!
            
            self._indexHoraIniMin = Int(self._notificacion.HoraIni.substringWithRange(minIniRange))!
            self._indexHoraTerMin = Int(self._notificacion.HoraTer.substringWithRange(minTerRange))!
            
            let minutosIni = (self._indexHoraIniMin < 10) ? "0\(self._indexHoraIniMin)" : "\(self._indexHoraIniMin)"
            let minutosTer = (self._indexHoraTerMin < 10) ? "0\(self._indexHoraTerMin)" : "\(self._indexHoraTerMin)"
            
            let horasIni = (self._indexHoraIniHor < 10) ? "0\(self._indexHoraIniHor)" : "\(self._indexHoraIniHor)"
            let horasTer = (self._indexHoraTerHor < 10) ? "0\(self._indexHoraTerHor)" : "\(self._indexHoraTerHor)"
            
            
            self.horaIni?.text = String("\(horasIni):\(minutosIni)")
            self.horaTer?.text = String("\(horasTer):\(minutosTer)")
            
        }
        
        
        
        
    }


}
