//
//  MapaUbicacionViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/7/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class MapaUbicacionViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UINavigationBarDelegate {

    @IBOutlet var mapaUbicacion: MKMapView!
    @IBOutlet var btnModoEstacionado: UIButton!
    @IBOutlet var btnSos: UIButton!
    
    
    var _vehiculoDTO: Vehiculo = Vehiculo()
    var _vehiculosDTO = [Flota]()
    var _verTodos :Bool = false
    
    var _ubicacionDTO: Ubicacion = Ubicacion()
    var _manager : CLLocationManager!
    var _userLocation : Ubicacion = Ubicacion()
    var _flagUbicacion : Bool = false
    var _timer = NSTimer()
    var _estadoME :String = "0"
    
    let _regionRadius: CLLocationDistance = 1000
    let _btnUbicacion : String = "boton_ubicacion_sos_a"
    let _mapaActivado : String = "boton_ubicacion_tipomapa_d"
    let _mapaDesactivado: String = "boton_ubicacion_tipomapa_a"
    let _estacionadoDesactivado: String = "boton_ubicacion_estacionado_d"
    let _estacionadoActivado: String = "boton_ubicacion_estacionado_a"
    
    
    @IBAction func cambiarTipoMapa(sender: UIBarButtonItem?) {
        
        let image_on = UIImage(named: self._mapaActivado) as UIImage?
        let image_off = UIImage(named: self._mapaDesactivado) as UIImage?
        
        if mapaUbicacion.mapType == MKMapType.Standard {
            sender!.image = image_on
            mapaUbicacion.mapType = MKMapType.Hybrid
        } else {
            sender!.image = image_off
            mapaUbicacion.mapType = MKMapType.Standard
        }
    }
    
    @IBAction func activarSos(sender: UIButton) {
        let title_alert :String = "Mensaje SOS"
        let mensaje_alert :String = "¿Está seguro que desea solicitar ayuda?"
        let title_ok :String = "SI"
        let title_cancel :String = "NO"
        
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: title_alert, message: mensaje_alert, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: title_cancel, style: UIAlertActionStyle.Cancel, handler: nil))
            sosAlert.addAction(UIAlertAction(title: title_ok, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                LibraryAPI.sharedInstance.alarmaSOS(self._userLocation.latitud, longitud: self._userLocation.longitud)
            }))
            self.presentViewController(sosAlert, animated: true, completion: nil)
        }
        else if iOS7
        {
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = title_alert
            sosAlert.message = mensaje_alert
            sosAlert.addButtonWithTitle(title_cancel)
            sosAlert.addButtonWithTitle(title_ok)
            sosAlert.show()
            sosAlert.tag = 1
            
        }
        
        
        
        
    }
    @IBAction func verUbicacionUsuario() {
        self.centerMapOnLocation(CLLocation(latitude: self._userLocation.latitud, longitude: self._userLocation.longitud))
    }
    
    @IBAction func verPosicionVehiculo() {
        if !_verTodos{
            self.centerMapOnLocation(CLLocation(latitude: self._ubicacionDTO.latitud, longitude: self._ubicacionDTO.longitud))
        }
        
    }
   
    @IBAction func cambiarModoEstacionado(sender: UIButton) {
        
        var estado :String
        
        if _verTodos {
            estado = (self._estadoME == "1") ? "2": "3"
            self._estadoME = (self._estadoME == "0") ? "1" : "0"
            LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : estado, cortacont: "0", genAlert: false)
            
        }else {
            estado = (self._vehiculoDTO._Estado == "0") ? "1": "0"
            self._vehiculoDTO._Estado = estado
            self.actualizarModoEstacionado()
            confirmar(_vehiculoDTO, activarTodos: false)
        }

    }
    
    @IBAction func returnSegue(sender: UIBarButtonItem?) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            self._regionRadius * 4.0, self._regionRadius * 4.0)
        mapaUbicacion.setRegion(coordinateRegion, animated: true)
    }
    
    func generarAlerta(mensaje :String, title :String, title_btn :String, tagUiAlertView: Int)
    {
        
        if #available(iOS 8.0, *) {
            let sosAlert = UIAlertController(title: title, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            sosAlert.addAction(UIAlertAction(title: title_btn, style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(sosAlert, animated: true, completion: nil)
        }else if iOS7{

            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.tag = tagUiAlertView
            sosAlert.delegate = self
            sosAlert.title = title
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(title_btn)
            sosAlert.show()
        }
    }
    
    
    func alertaSOS(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let mensaje = userInfo["mensaje"] as! String
        let title = "Respuesta SOS"
        let title_btn = "OK"
        
        self.generarAlerta(mensaje,title: title, title_btn: title_btn,tagUiAlertView :1)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MapaUbicacionViewController.procesarModoEstacionado(_:)), name: "respuestaME", object: nil)

    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
            
        case 1:
            if(View.tag == 1)
            {
                LibraryAPI.sharedInstance.alarmaSOS(self._userLocation.latitud, longitud: self._userLocation.longitud )
            }
            break;
        default:
            break;
            
        }
    }
    
    func actualizarModoEstacionado()
    {
        var image: UIImage!
        
        if !self._verTodos {
            if _vehiculoDTO._Estado == "0" {
                image = (UIImage(named: self._estacionadoDesactivado) as UIImage?)!
            } else {
                image = (UIImage(named: self._estacionadoActivado) as UIImage?)!
            }
        }else {
            if _estadoME == "0" {
                image = (UIImage(named: self._estacionadoDesactivado) as UIImage?)!
            } else {
                image = (UIImage(named: self._estacionadoActivado) as UIImage?)!
            }
        }
        
        self.btnModoEstacionado.setImage(image, forState: UIControlState.Normal)
        
    }
    
    func agregarPin(ubicacion :MKAnnotation){
        mapaUbicacion.addAnnotation(ubicacion)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let location: CLLocation = locations[0] 
        self._userLocation = Ubicacion(_lat: location.coordinate.latitude, _lon: location.coordinate.longitude, _latDelta: 0.05, _lonDelta: 0.05, _ubic: "Mi ubicación actual", _fecha: "\(NSDate())", _hora: "")
        LibraryAPI.sharedInstance.setUserLocation(self._userLocation)
 
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Configuración de admin de localización
        
        self._manager = CLLocationManager()
        self._manager.delegate = self
        self._manager.desiredAccuracy = kCLLocationAccuracyBest
        
     
        if #available(iOS 8.0, *) {
            self._manager.requestWhenInUseAuthorization()
        }
        LibraryAPI.sharedInstance.setIsMapaUbicacion(true)
        self._manager.startUpdatingLocation()
        
        //Configuración de mapa
        
        self.mapaUbicacion.delegate = self
        self.mapaUbicacion.showsUserLocation = true
        
        
        self.cargarDatos()
        if !self._verTodos {
            self._timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(MapaUbicacionViewController.actualizarMapa), userInfo: nil, repeats: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self._timer.invalidate()
        LibraryAPI.sharedInstance.setIsMapaUbicacion(false)
    }
    
    func actualizarMapa(){
        cargarDatos()
    }
    
    func cargarDatos(){
        if self._verTodos {
            self.mapaUbicacion.removeAnnotations(self.mapaUbicacion.annotations)
            for v in self._vehiculosDTO {
                if v._estado == "1" {
                    self._estadoME = "1"
                }
                self.agregarPin(v)
                if let primer = self._vehiculosDTO.first {
                    let lat = (primer._latitud as NSString).doubleValue
                    let lon = (primer._longitud as NSString).doubleValue
                    self.centerMapOnLocation(CLLocation(latitude: lat, longitude: lon))
                    
                }
                
            }
            
        } else {
            LibraryAPI.sharedInstance.getUltimoEstado(self._vehiculoDTO._ID, patente_id: self._vehiculoDTO._Patente)
            LibraryAPI.sharedInstance.getUltimaUbicacion(self._vehiculoDTO._ID, patente_id: self._vehiculoDTO._Patente)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self._timer.invalidate()
        LibraryAPI.sharedInstance.setIsMapaUbicacion(false)
    }
    
    func actualizarEstado(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let estado = userInfo["estadoDTO"] as! String
        let corte = userInfo["corteDTO"] as! String
        
        self._vehiculoDTO._Estado = estado
        self._vehiculoDTO._CortaContacto = corte
        self.actualizarModoEstacionado()
    }

    
    func poblarMapa(notification: NSNotification)
    {
        let userInfo = notification.userInfo as! [String: AnyObject]
        self._ubicacionDTO = userInfo["ubicacion"] as! Ubicacion
        
        mapaUbicacion.removeAnnotations(self.mapaUbicacion.annotations)
        agregarPin(_ubicacionDTO)
        
        if !self._flagUbicacion {
            centerMapOnLocation(CLLocation(latitude: self._ubicacionDTO.latitud, longitude: self._ubicacionDTO.longitud))
            self._flagUbicacion = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.actualizarModoEstacionado()
        self.navigationItem.title = "Mapa"
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: self._mapaDesactivado), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MapaUbicacionViewController.cambiarTipoMapa(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MapaUbicacionViewController.poblarMapa(_:)), name: "actualizarMapaUbicacion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MapaUbicacionViewController.alertaSOS(_:)), name: "mensajeSOS", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MapaUbicacionViewController.actualizarEstado(_:)), name: "estadoVehiculo", object: nil)

        
        if self.navigationController == nil {
            
            let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
            let navigationItem = UINavigationItem()
            let leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(MapaUbicacionViewController.returnSegue(_:)))
            
            navigationBar.barTintColor = UIColor(red: 183/255.0, green: 28/255.0, blue: 28/255.0, alpha: 1)
            navigationBar.tintColor = UIColor.whiteColor()
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            navigationBar.delegate = self;
            
            navigationItem.title = "Mapa"
            navigationItem.leftBarButtonItem = leftButton
            navigationItem.rightBarButtonItem = rightButton
            
            navigationBar.items = [navigationItem]
            self.view.addSubview(navigationBar)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func procesarModoEstacionado(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! String
        let genalert = userInfo["genAlert"] as! Bool
        if(genalert){
            self.genAlerta("Respuesta", mensaje: respuesta, btnTitulo: "OK")
            }
        }
    
    func genAlerta(frameTitulo: String, mensaje: String, btnTitulo: String)
    {
    if #available(iOS 8.0, *) {
        let alert = UIAlertController(title: frameTitulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }else if iOS7{
        let sosAlert: UIAlertView = UIAlertView()
        sosAlert.delegate = self
        sosAlert.title = frameTitulo
        sosAlert.message = mensaje
        sosAlert.addButtonWithTitle(btnTitulo)
        sosAlert.show()
    }
    }
    
    func confirmar(vehiculo: Vehiculo, activarTodos: Bool){
        
        let title = "Activar Modo Estacionado"
        let message = "Desea Cortar Contacto de vehículo?"
        
        if(vehiculo._Estado == "1"){
            if(Int(vehiculo._CortaContacto) >= 1) {
                if #available(iOS 8.0, *) {
                    
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "NO" ,style: .Default, handler: { (action: UIAlertAction)in
                    if(Int(vehiculo._Estado) >= 2){
                    LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : vehiculo._Estado, cortacont: "0", genAlert: true )
                    } else if(Int(vehiculo._Estado) < 2){
                    LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : vehiculo._Estado, cortacont: "0", genAlert: true)
                    }
                    } )
                    
                    alert.addAction(cancelAction)
                    alert.addAction(UIAlertAction(title: "SI", style: .Default, handler:{ (alertAction:UIAlertAction) in
                    if(Int(vehiculo._Estado) >= 2){
                        LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo("", patente_id : "", estado_id : vehiculo._Estado, cortacont: "1", genAlert: true )
                    } else if(Int(vehiculo._Estado) < 2){
                        LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : vehiculo._Estado, cortacont: "1", genAlert: true)
                    }
                    }))
                    
                    self.presentViewController(alert,
                    animated: true,
                    completion: nil)
                    } else if iOS7{
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                    alert.title = title
                    alert.message = message
                    alert.addButtonWithTitle("NO")
                    alert.addButtonWithTitle("SI")
                    alert.setValue(vehiculo._ID, forKey: "id")
                    alert.setValue(vehiculo._Patente, forKey: "patente")
                    alert.setValue(vehiculo._Estado, forKey: "estado")
                    alert.show()
                    }
                } else {
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : vehiculo._Estado, cortacont: "0", genAlert: false)
                }
            } else {
            if(Int(vehiculo._CortaContacto) >= 1){
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : vehiculo._Estado, cortacont: "1", genAlert: false)
                } else {
                LibraryAPI.sharedInstance.actualizarModoEstacionadoVehiculo(vehiculo._ID, patente_id : vehiculo._Patente, estado_id : vehiculo._Estado, cortacont: "0", genAlert: false)
                }
            }
        }
}