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
    var Descripcion :String
    var Leyenda :String
    var Estado :String
    var EsuID :String
    
    init(gps :String, descripcion :String, leyenda :String, estado :String, esu_id :String)
    {
        self.GPS = gps
        self.Descripcion = descripcion
        self.Leyenda = leyenda
        self.Estado = estado
        self.EsuID = esu_id
    
    }
   
}
