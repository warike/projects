//
//  VehiculoService.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VehiculoService: NSObject, IVehiculoService {
    var _vehiculos: [Vehiculo]
    let _manager: AFHTTPRequestOperationManager
    
    override init(){
        _vehiculos = [Vehiculo]()
        _manager = AFHTTPRequestOperationManager()
    }
    
    init(vehiculos: [Vehiculo], manager: AFHTTPRequestOperationManager){
        _vehiculos = vehiculos
        _manager = manager
    }
    
    
    func getUltimoEstado(_ gps_id: String, patente_id: String) -> Void
    {
    
        let url: String = "http://libs.samtech.cl/movil/EstadoVehiculo.asp?"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id , "patente": patente_id ]
        
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let estados : NSArray = responseObject.object(forKey: "estadovehiculo") as? NSArray {
                    
                    for estado in estados {
                        let estadoDTO = ["estadoDTO": estado["estado"] as! String, "corteDTO" : estado["corte"] as! String ]
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "estadoVehiculo"), object: self, userInfo: estadoDTO)
                        break
                    }
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //print("Error: " + error.localizedDescription)
        })
    
    }
    
    
    /*
    http://libs.samtech.cl/movil/AlarmaSOS.asp
    
    Parametros:
    ilogin: Corresponde al nombre de usuario o cliente que desea consultar
    ipassword: Corresponde a la clave del usuario o cliente que desea consultar.
    gps: Corresponde al id gps del vehículo que desea cambiar estado de modo estacionado.
    patente: Corresponde a la patente.
    
    */
    
    func AlarmaSOS(_ latitud: String, longitud: String) -> Void{
        
        let url: String = "http://libs.samtech.cl/movil/AlarmaSOS.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "latitud": latitud , "longitud": longitud ]

        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let mensajes : NSArray = responseObject.object(forKey: "SOS") as? NSArray {
                    
                    for mensaje in mensajes {
                        let mensajeDTO = ["mensaje": mensaje["mensaje"] as! String ]
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "mensajeSOS"), object: self, userInfo: mensajeDTO)
                        break
                    }
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
        
    }
    
    
    /*
    http://libs.samtech.cl/movil/ContadorVehiculo.asp

    Parámetros:
    
    ilogin: Corresponde al nombre de usuario o cliente que desea consultar.
    ipassword: Corresponde a la clave del usuario o cliente que desea consultar.
    Respuesta WS:
    
    El webservice devolverá un string con el total de GPS y la patente separados por una coma.
    */
    
    func ContadorVehiculo() -> Void {
    
        let url: String = "http://libs.samtech.cl/movil/ContadorVehiculos.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        self._vehiculos.removeAll(keepingCapacity: false)
        
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.object(forKey: "vehiculo") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO :Vehiculo = Vehiculo(patente_id : vehiculo["patente"] as! String, gps_id: vehiculo["gps"] as! String, estado_id :vehiculo["estado"] as! String, velocidad_id: String(""))
                        self._vehiculos.append(vehiculoDTO)
                    }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "contarVehiculos"), object: self, userInfo: ["vehiculo": self._vehiculos.last!])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
    }
    /*
    http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp
    
    Parámetros:
    
    Id: Corresponde al id gps del vehículo que desea cambiar estado de modo estacionado.
    Patente: Corresponde a la patente.
    Estado: Se debe enviar un valor entero entre 0 y 1. Donde 1 corresponde a estacionado y 0 corresponde a no estacionado.
    ilogin: Corresponde nombre de inicio de sesión del cliente o usuario.
    ipassword: Corresponde a la clave del cliente o usuario.
    Respuesta WS:
    
    Si el valor es modificado se enviara la leyenda 'Modo estacionado activo' o 'Modo estacionado desactivado' según corresponda.
    */
    
    func ModoEstacionadoVehiculo(_ gps_id: String, patente_id :String, estado_id: String, device_token: String, corta_corr: String, genAlert: Bool) -> Void{
        
        let url: String = "http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        var respuesta : String = String()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "patente": patente_id, "estado": estado_id, "dtoken" : device_token, "app" : "Lobarnechea", "corta_corr" : corta_corr]
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if estado_id == "2" || estado_id == "3"  {
                    self.getListaVehiculoTodos()
                }
                if let respuestas : NSArray = responseObject.object(forKey: "ME") as? NSArray{
                    for respt in respuestas {
                        respuesta = respt["mensaje"] as! String
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "respuestaME"), object: self, userInfo: ["respuesta": respuesta, "genAlert" : genAlert])
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //print("Error: " + error.localizedDescription)
        })
        
    }
    
   
    
    /****
    http://libs.samtech.cl/movil/ControlDeVelocidad.asp
    ---
    Parámetros
    
    - id: Corresponde al ID GPS.
    - patente: Corresponde a la patente del vehículo.
    - spd: Velocidad máxima.
    - estado:
    - 0 = inactivo
    - 1 = activado
    - accion:
    - 1 = Listar control de velocidad.
    - 2 = actualizar velocidad
    - 3 = activar o desactivar según valor de estado
    ***/
    
    func actualizarControlVelocidad(_ gps_id : String, patente_id :String, estado_id : String, velocidad_id :String, accion_id: String) -> Void {
        
        let url: String = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "patente": patente_id, "estado": estado_id, "accion": accion_id, "spd": velocidad_id]

        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if accion_id == "4" || accion_id == "5"  {
                    self.listaControlVelocidad()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                
        })
    }
    
    
    
    func listaControlVelocidad() -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"accion": 1] as [String : Any]
        
        self._vehiculos.removeAll(keepingCapacity: false)
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.object(forKey: "ControlVelocidad") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO = Vehiculo(
                            patente_id: vehiculo["Patente"] as! String,
                            gps_id:  vehiculo["GPS"] as! String,
                            nombre_id: vehiculo["Nombre"] as! String,
                            velocidad_id: vehiculo["Velocidad"] as! String,
                            estado_id: vehiculo["Estado"] as! String)
                        
                        self._vehiculos.append(vehiculoDTO)
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "actualizarListaControlVelocidad"), object: self, userInfo: ["vehiculos": self._vehiculos])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                // println("Error: " + error.localizedDescription)
        })
    }
    
    func getListaVehiculoTodos() -> Void
    {
        
        var vehiculoDTO: Vehiculo = Vehiculo()
        let url: String = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        
        self._vehiculos.removeAll(keepingCapacity: true)
        
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.object(forKey: "lista") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        vehiculoDTO = Vehiculo(patente_id: vehiculo["Patente"] as! String, gps_id:  vehiculo["ID"] as! String,  nombre_id: vehiculo["Nombre"] as! String, velocidad_id: vehiculo["Velocidad"] as! String, estado_id: vehiculo["Estado"] as! String, ccontacto: vehiculo["Corte"] as! String)
                        self._vehiculos.append(vehiculoDTO)
                        
                    }

                    NotificationCenter.default.post(name: Notification.Name(rawValue: "actualizarTablaVehiculos"), object: self, userInfo: ["vehiculos": self._vehiculos])
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
        
    }
    
    
    func getListaVehiculoEstacionados() -> Void
    {
        
        
        let url: String = "http://libs.samtech.cl/movil/ListaVehiculoEstacionados.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        
        
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.object(forKey: "lista") as? NSArray {
                    for vehiculo in vehiculos {
                        let vehiculoDTO: Vehiculo = Vehiculo(patente_id: vehiculo["Patente"] as! String, gps_id: vehiculo["ID"] as! String, estado_id: vehiculo["Estado"] as! String, velocidad_id: "")
                        self._vehiculos.append(vehiculoDTO)
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "actualizarTablaVehiculos"), object: self, userInfo: ["vehiculos": self._vehiculos])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
    }
}
