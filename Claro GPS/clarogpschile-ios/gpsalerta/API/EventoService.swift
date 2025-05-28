//
//  EventoService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class EventoService: NSObject, IEventoService {
   
    var _eventos : [Evento]
    let _manager : AFHTTPRequestOperationManager
    
    override init()
    {
        self._eventos = [Evento]()
        self._manager = AFHTTPRequestOperationManager()
    }
    
    /**
    http://libs.samtech.cl/movil/Historia.asp
    ---
    Parámetros:
    
    - Id: Corresponde al ID GPS que desea consultar.
    - Patente: Corresponde a la patente que desea consultar.
    - ilogin: Corresponde al nombre de usuario o cliente  que desea  consultar.
    - ipassword: Corresponde al nombre de usuario asociado al cliente principal.
    
    Respuesta WS:
    -El webservice devolverá un string de registros separados por #/n. Los datos entregados en orden son: Fecha Hora, estado motor, ubicación, latitud y longitud.
    **/
    
    
    func getEventos(patente_id: String, gps_id: String){
        
        
        let url: String = "http://libs.samtech.cl/movil/Historia.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"Id":gps_id,"patente":patente_id]
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                self._eventos.removeAll(keepCapacity: true)
                if let eventos : NSArray = responseObject.objectForKey("historia") as? NSArray {
                    for evento in eventos {
                        
                        let eventoDTO: Evento = Evento()
                        
                        eventoDTO.fecha = evento["Fecha"] as! String
                        eventoDTO.ubicacion = evento["Ubicacion"] as! String
                        eventoDTO.latitud = evento["Latitud"] as! String
                        eventoDTO.longitud = evento["Longitud"] as! String
                        eventoDTO.hora = evento["Hora"] as! String
                        eventoDTO.tipo = evento["Evento"] as! String
                        eventoDTO.vehiculo._Patente = patente_id
                        eventoDTO.vehiculo._ID = gps_id
                        
                        self._eventos.append(eventoDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaEventos", object: self, userInfo: ["eventos": self._eventos])
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
        
    }
}
