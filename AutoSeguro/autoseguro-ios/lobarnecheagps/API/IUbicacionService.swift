//
//  IUbicacionService.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/7/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IUbicacionService {
    
    func DatosPorFlota() -> Void
    func UltimaUbicacion(_ gps_id: String, patente_id: String, ilogin: String, ipassword: String)-> Void
    
}
