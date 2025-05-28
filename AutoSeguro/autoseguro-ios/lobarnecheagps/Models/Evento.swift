//
//  Evento.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class Evento: NSObject {
 
    var fecha : String = String()
    var hora : String = String()
    var ubicacion :String = String()
    var latitud :String = String()
    var longitud :String = String()
    var tipo : String = String()
    var vehiculo: Vehiculo = Vehiculo()
}
