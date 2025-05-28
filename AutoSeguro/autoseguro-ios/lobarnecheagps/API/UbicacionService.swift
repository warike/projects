//
//  UbicacionService.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/7/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class UbicacionService: NSObject, IUbicacionService {
   
    let _manager: AFHTTPRequestOperationManager
    var _ubicaciones :[Ubicacion]
    var _vehiculos :[Flota]
    
    
    override init(){
        _ubicaciones = [Ubicacion]()
        _vehiculos = [Flota]()
        _manager = AFHTTPRequestOperationManager()
    }
    
    init(ubicaciones: [Ubicacion], vehiculos: [Flota], manager: AFHTTPRequestOperationManager){
        _ubicaciones = ubicaciones
        _vehiculos = vehiculos
        _manager = manager
    }
    
    /***
    http://libs.samtech.cl/movil/DatosPorFlota.asp
    ---
    Parámetros:
    
    - Usuario: Corresponde al nombre de usuario o cliente  a consultar.
    - Pass: Corresponde a la clave del usuario o cliente a consultar.

    ***/
    
    func DatosPorFlota() -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/DatosPorFlota.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        self._vehiculos.removeAll(keepingCapacity: true)
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                if let vehiculos : NSArray = responseObject.object(forKey: "DatoFlota") as? NSArray {
                    for vehiculo in vehiculos {
                        
                        let vehiculoDTO: Flota = Flota(
                            modelo: vehiculo["Modelo"] as! String,
                            patente: vehiculo["Patente"] as! String,
                            estado: vehiculo["Estado"] as! String,
                            velocidad: vehiculo["Velocidad"] as! String,
                            ubicacion: vehiculo["Ubicacion"] as! String,
                            fecha: vehiculo["Fecha"] as! String,
                            latitud: vehiculo["Latitud"] as! String,
                            longitud: vehiculo["Longitud"] as! String,
                            nombre: vehiculo["NomPatente"] as! String,
                            gps: vehiculo["GPS"] as! String,
                            ignicion: vehiculo["Ignicion"] as! String)
                        self._vehiculos.append(vehiculoDTO)
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "actualizarFlotaVehiculos"), object: self, userInfo: ["vehiculos": self._vehiculos])
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                
        })
    
    }
    
    
    /***

    Parámetros:

    Id: Corresponde al id gps del vehículo que desea consultar.
    ilogin Corresponde nombre de inicio de sesión del cliente o usuario.
    ipassword: Corresponde a la clave del cliente o usuario.
    Respuesta WS:
    - El webservice devolverá un string con la ubicación del vehículo. Los datos serán mostrados en el siguiente orden: latitud, longitud, velocidad, fecha-hora, chofer, ubicación, faena, id gps y hdg separados por coma. Cada registros será separado por #/n.
    
    ***/
    
    func UltimaUbicacion(_ gps_id: String, patente_id: String, ilogin: String, ipassword: String)-> Void {
        
        let url: String = "http://libs.samtech.cl/movil/UltimaUbicacion.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"Id":gps_id, "Patente": patente_id]
        _manager.post( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in

                
                if let ubicaciones : NSArray = responseObject.object(forKey: "ubicacion") as? NSArray {
                    for ubicacion in ubicaciones {
                        
                        let ubicacionDTO: Ubicacion = Ubicacion(
                            _lon: NSString(string: ubicacion["longitud"] as! String).doubleValue,
                            _lat: NSString(string: ubicacion["latitud"] as! String).doubleValue,
                            _latDelta: 0.08,
                            _lonDelta: 0.08,
                            _vel: ubicacion["velocidad"] as! String,
                            _ubi : ubicacion["ubicacion"]as! String,
                            _fecha: ubicacion["fecha"] as! String,
                            _hora: ubicacion["hora"] as! String,
                            _chofer: ubicacion["chofer"] as! String,
                            _faena: ubicacion["faena"] as! String,
                            _gps_id: ubicacion["id"] as! String,
                            _hdg: ubicacion["sentido"] as! String,
                            _tipo: "Vehiculo"
                        )
                        self._ubicaciones.append(ubicacionDTO)
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "actualizarMapaUbicacion"), object: self, userInfo: ["ubicacion": self._ubicaciones.last!])
                }

            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })

    
    }
    
    
}
