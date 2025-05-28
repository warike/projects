//
//  Vehiculo.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class Vehiculo: NSObject
{
    var _ID : String = String()
    var _Patente : String = String()
    var _Estado : String = String()
    var _Velocidad : String = String()
    var _Nombre : String = String()
    var _CortaContacto : String =  String()
    
    init(patente_id :String, gps_id: String, estado_id :String, velocidad_id: String){
        self._Patente = patente_id
        self._ID = gps_id
        self._Estado = estado_id
        self._Velocidad = velocidad_id
    }
    
    init(patente_id: String, gps_id: String, nombre_id: String, velocidad_id: String, estado_id: String, ccontacto: String) {
            self._Patente = patente_id
            self._ID = gps_id
            self._Nombre = nombre_id
            self._Velocidad = velocidad_id
            self._Estado = estado_id
            self._CortaContacto = ccontacto
        }
    
    init(patente_id :String, gps_id: String,  nombre_id: String){
        self._Patente = patente_id
        self._ID = gps_id
        self._Nombre = nombre_id
        self._Velocidad = String("000")
        self._Estado = String("0")
    }
    init(patente_id :String, gps_id: String,  nombre_id: String, velocidad_id:String, estado_id: String){
        self._Patente = patente_id
        self._ID = gps_id
        self._Nombre = nombre_id
        self._Velocidad = velocidad_id
        self._Estado = estado_id
    }
    
    override init(){
        self._Patente = String("")
        self._ID = String("0")
        self._Estado = String("0")
        self._Velocidad = String("0")
        self._Nombre = String("")
        self._CortaContacto = String("0")
    }
}
