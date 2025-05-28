//
//  Notificacion.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 9/9/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class Notificacion: NSObject {
    var GPS :String
    var Patente :String
    var FechaIni :String
    var FechaTer :String
    var HoraIni :String
    var HoraTer :String
    var Descripcion :String
    var Leyenda :String
    var Estado :String
    var EsuID :String
    
    override init()
    {
        self.GPS = ""
        self.Descripcion = ""
        self.Leyenda = ""
        self.Estado = ""
        self.EsuID = ""
        self.Patente = ""
        self.FechaIni = ""
        self.FechaTer = ""
        self.HoraIni = ""
        self.HoraTer = ""
        
    }
    
    
    init(gps :String, descripcion :String, leyenda :String, estado :String, esu_id :String, patente :String, fechaIni :String, fechaTer :String)
    {
        self.GPS = gps
        self.Descripcion = descripcion
        self.Leyenda = leyenda
        self.Estado = estado
        self.EsuID = esu_id
        self.Patente = patente
        self.FechaIni = fechaIni
        self.FechaTer = fechaTer
        self.HoraIni = ""
        self.HoraTer = ""
    
    }
    init(gps :String, descripcion :String, leyenda :String, estado :String, esu_id :String, patente :String, fechaIni :String, fechaTer :String, horaIni : String, horaTer :String)
    {
        self.GPS = gps
        self.Descripcion = descripcion
        self.Leyenda = leyenda
        self.Estado = estado
        self.EsuID = esu_id
        self.Patente = patente
        self.FechaIni = fechaIni
        self.FechaTer = fechaTer
        self.HoraIni = horaIni
        self.HoraTer = horaTer
        
    }
   
}
