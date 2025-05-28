//
//  VehiculoService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class VehiculoService: NSObject, IVehiculoService {
    var _vehiculos: [Vehiculo]
    var _notificacion : [Notificacion]
    let _manager: AFHTTPRequestOperationManager
    
    
    override init(){
        _vehiculos = [Vehiculo]()
        _notificacion = [Notificacion]()
        _manager = AFHTTPRequestOperationManager()
    }
    
    init(vehiculos: [Vehiculo], notificacion :[Notificacion], manager: AFHTTPRequestOperationManager){
        _vehiculos = vehiculos
        _manager = manager
        _notificacion = notificacion
    }
    
    
    func getUltimoEstado(gps_id: String, patente_id: String) -> Void
    {
        
        let url: String = "http://libs.samtech.cl/movil/EstadoVehiculo.asp?"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id , "patente": patente_id ]
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let estados : NSArray = responseObject.objectForKey("estadovehiculo") as? NSArray {
                    
                    for estado in estados {
                        let estadoDTO = ["estadoDTO": estado["estado"] as! String, "corteDTO" : estado["corte"] as! String ]
                        NSNotificationCenter.defaultCenter().postNotificationName("estadoVehiculo", object: self, userInfo: estadoDTO)
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
    latitud=-070.32654
    longitud=-30.25422
    
    */
    
    func AlarmaSOS(latitud: String, longitud: String) -> Void{
        
        let url: String = "http://libs.samtech.cl/movil/AlarmaSOS.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "latitud": latitud , "longitud": longitud ]
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let mensajes : NSArray = responseObject.objectForKey("SOS") as? NSArray {
                    
                    for mensaje in mensajes {
                        let mensajeDTO = ["mensaje": mensaje["mensaje"] as! String ]
                        NSNotificationCenter.defaultCenter().postNotificationName("mensajeSOS", object: self, userInfo: mensajeDTO)
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
        self._vehiculos.removeAll(keepCapacity: false)
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.objectForKey("vehiculo") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO :Vehiculo = Vehiculo(patente_id : vehiculo["patente"] as! String, gps_id: vehiculo["gps"] as! String, estado_id :vehiculo["estado"] as! String, velocidad_id: String(""))
                        self._vehiculos.append(vehiculoDTO)
                    }
                NSNotificationCenter.defaultCenter().postNotificationName("contarVehiculos", object: self, userInfo: ["vehiculo": self._vehiculos.last!])
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
    
    func ModoEstacionadoVehiculo(gps_id: String, patente_id :String, estado_id: String, device_token: String, corta_corr: String, genAlert: Bool) -> Void{
        
        let url: String = "http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "patente": patente_id, "estado": estado_id, "dtoken" : device_token, "app" : "claro", "corta_corr" : corta_corr]
        var respuesta : String = String()
        
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if estado_id == "2" || estado_id == "3"  {
                    self.getListaVehiculoTodos()
                }
                if let respuestas : NSArray = responseObject.objectForKey("ME") as? NSArray{
                    for respt in respuestas {
                        respuesta = respt["mensaje"] as! String
                        }
                    }
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaME", object: self, userInfo: ["respuesta": respuesta, "genAlert" : genAlert])
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
    
    func actualizarControlVelocidad(gps_id : String, patente_id :String, estado_id : String, velocidad_id :String, accion_id: String) -> Void {
        
        let url: String = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "patente": patente_id, "estado": estado_id, "accion": accion_id, "spd": velocidad_id]

        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if accion_id == "4" || accion_id == "5"  {
                    self.listaControlVelocidad()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
    }
    
    
    
    func listaControlVelocidad() -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"accion": 1]
        
        self._vehiculos.removeAll(keepCapacity: false)
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.objectForKey("ControlVelocidad") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO = Vehiculo(
                            patente_id: vehiculo["Patente"] as! String,
                            gps_id:  vehiculo["GPS"] as! String,
                            nombre_id: vehiculo["Nombre"] as! String,
                            velocidad_id: vehiculo["Velocidad"] as! String,
                            estado_id: vehiculo["Estado"] as! String)
                        
                        self._vehiculos.append(vehiculoDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarListaControlVelocidad", object: self, userInfo: ["vehiculos": self._vehiculos])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                // println("Error: " + error.localizedDescription)
        })
    }
    
    func getListaVehiculoTodos() -> Void
    {
        
        
        let url: String = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        
        self._vehiculos.removeAll(keepCapacity: true)
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.objectForKey("lista") as? NSArray {
                    for vehiculo in vehiculos {
                        let vehiculoDTO = Vehiculo(patente_id: vehiculo["Patente"] as! String, gps_id:  vehiculo["ID"] as! String,  nombre_id: vehiculo["Nombre"] as! String, velocidad_id: vehiculo["Velocidad"] as! String, estado_id: vehiculo["Estado"] as! String, ccontacto: vehiculo["Corte"] as! String)
                        self._vehiculos.append(vehiculoDTO)
                        
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaVehiculos", object: self, userInfo: ["vehiculos": self._vehiculos])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in

        })
    }
    
    
    func getListaVehiculoEstacionados() -> Void
    {
        
        let vehiculoDTO: Vehiculo = Vehiculo()
        
        let url: String = "http://libs.samtech.cl/movil/ListaVehiculoEstacionados.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.objectForKey("lista") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        vehiculoDTO._Estado = vehiculo["Estado"] as! String
                        vehiculoDTO._Patente = vehiculo["Patente"] as! String
                        vehiculoDTO._ID = vehiculo["ID"] as! String
                        self._vehiculos.append(vehiculoDTO)
                        
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaVehiculos", object: self, userInfo: ["vehiculos": self._vehiculos])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
    }
    
    /*****
    http://libs.samtech.cl/movil/ControlDeUso.asp
    ---
    Parámetros
    
    - GPS: Corresponde al id gps del vehículo. Si el tipo de acción es 1, no necesita enviar este parámetro.
    - Patente: Corresponde a la patente del vehículo. Si el tipo de acción es 1, no necesita enviar este parámetro.
    - Fecha_ini: Corresponde a la fecha de inicio para control de uso. Si el tipo de acción es 1 ó 3, no necesita enviar este parámetro.
    - Fecha_fin: Corresponde a la fecha de inicio para control de uso. Si el tipo de acción es 1 ó 3, no necesita enviar este parámetro.
    - Estado: Corresponde al estado del control de uso que desea configurar. Si estado=0, el control de uso se desactivará. Si el estado=1, el control de uso se activará.
    - Acción: Corresponde a las acciones que puede realizar en este método. Donde; 1=Listar todo los vehículos con su respectiva configuración, 2=Actualizar la configuración de un control de uso y 3=Cambiar estado del control de uso (definido en el punto n.v.)
    - ilogin: Corresponde nombre de inicio de sesión del cliente  o usuario.
    - ipassword: Corresponde a la clave del cliente o usuario.
    */
    
    func actualizarControlDeUso(gps_id : String, patente_id :String, estado_id : String, fechaIni :String, fechaTer :String, horaIni :String, horaTer :String, accion_id :String) -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/ControlDeUso.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "patente": patente_id, "estado": estado_id, "dia_ini":fechaIni,"dia_fin":fechaTer,"hora_ini":horaIni,"hora_fin":horaTer, "accion": accion_id]
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.objectForKey("ControlDeUso") as? NSArray {
                    for vehiculo in vehiculos {
                        let mensaje :String = vehiculo["GPS"] as! String
                        let respuesta = (mensaje == "Control de uso actualizado") ? true : false
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("actualizarControlUso", object: self, userInfo: ["mensaje": mensaje, "respuesta": respuesta])
                        if(accion_id == "4" || accion_id == "5"){
                            self.listaControlDeUso()
                        }
                    }
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //print("Error: " + error.localizedDescription)
        })
    }
    
    
    
    func listaControlDeUso() -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/ControlDeUso.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"accion": 1]
        
        self._notificacion.removeAll(keepCapacity: false)
        self._vehiculos.removeAll(keepCapacity: false)
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.objectForKey("ControlDeUso") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO = Vehiculo(patente_id: vehiculo["Patente"] as! String, gps_id:  vehiculo["GPS"] as! String,  nombre_id: vehiculo["NomPatente"] as! String, velocidad_id: "", estado_id: vehiculo["Estado"] as! String)
                        
                        let notificacionDTO = Notificacion(gps: vehiculo["GPS"] as! String, descripcion: "", leyenda: "", estado: vehiculo["Estado"] as! String, esu_id: "", patente: vehiculo["Patente"] as! String, fechaIni: vehiculo["Fecha_ini"] as! String, fechaTer: vehiculo["Fecha_fin"] as! String, horaIni : vehiculo["Hora_ini"] as! String, horaTer: vehiculo["Hora_fin"] as! String)
                        
                        self._notificacion.append(notificacionDTO)
                        self._vehiculos.append(vehiculoDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaControlUso", object: self, userInfo: ["vehiculos": self._vehiculos, "notificaciones": self._notificacion])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //print("Error: " + error.localizedDescription)
        })
    }
}
