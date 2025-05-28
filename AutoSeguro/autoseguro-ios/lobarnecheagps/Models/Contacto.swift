//
//  Contacto.swift
//  TrackliteCL
//
//  Created by RWBook Retina on 10/20/15.
//  Copyright © 2015 Samtech SA. All rights reserved.
//

import UIKit

class Contacto: NSObject {
    
    let ID: String
    let Nombre: String
    let Telefono: String
    let Mail: String
    
    init(_id: String, _nombre: String, _telefono: String, _mail: String){
        
        self.ID = _id
        self.Nombre = _nombre
        self.Telefono = _telefono
        self.Mail = _mail
    }
    
    override init() {
        self.ID = String()
        self.Nombre = String()
        self.Telefono = String()
        self.Mail = String()
    }
    

}
