//
//  Usuario.swift
//  lobarnecheagps
//
//  Created by Diego Robles on 06-08-15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class Usuario:NSObject {
    
    var ilogin = String()
    var ipassword = String()
    var tipo = Int()
    var recordar = Int()
    var vehiculo : Vehiculo = Vehiculo()
    var email : String = String()
    var nombre: String = String()
    var fono : String = String()
    var usuario : String = String()
    
    override init (){
        self.ilogin = "samtech"
        self.ipassword = "4510sam"
        self.tipo = 1
        self.recordar = 1
        self.vehiculo = Vehiculo()
        self.usuario = ""
    }
    
    init (ilogin: String, ipassword: String, tipo: Int, recordar:Int, usuario: String){
        self.ilogin = ilogin
        self.ipassword = ipassword
        self.tipo = tipo
        self.recordar = recordar
        self.vehiculo = Vehiculo()
        self.usuario = usuario
    }
    
    init (ilogin: String, ipassword: String, tipo: Int, recordar:Int, vehiculo: Vehiculo){
        self.ilogin = ilogin
        self.ipassword = ipassword
        self.tipo = tipo
        self.recordar = recordar
        self.vehiculo = vehiculo
    }
    
    init(ilogin: String, ipassword: String, tipo: Int,email: String, nombre: String, fono: String){
    
        self.ilogin = ilogin
        self.ipassword = ipassword
        self.tipo = tipo
        self.email = email
        self.nombre = nombre
        self.fono = fono
    }
    
    init(coder decoder: NSCoder!) {
        self.ilogin = decoder.decodeObjectForKey("ilogin") as! String
        self.ipassword = decoder.decodeObjectForKey("ipassword") as! String
        self.tipo = decoder.decodeObjectForKey("tipo") as! Int
        self.recordar = decoder.decodeObjectForKey("recordar") as! Int
        self.usuario = decoder.decodeObjectForKey("_usuario") as! String
    }
    
    func initWithDecoder(decoder: NSCoder) -> Usuario {
        self.ilogin = decoder.decodeObjectForKey("ilogin") as! String
        self.ipassword = decoder.decodeObjectForKey("ipassword") as! String
        self.tipo = decoder.decodeObjectForKey("tipo") as! Int
        self.recordar = decoder.decodeObjectForKey("recordar") as! Int
        
        self.usuario = decoder.decodeObjectForKey("_usuario") as! String
        
        return self
    }
    
    func encodeWithCoder(coder: NSCoder!) {
        coder.encodeObject(ilogin, forKey: "ilogin")
        coder.encodeObject(ipassword, forKey: "ipassword")
        coder.encodeObject(tipo, forKey: "tipo")
        coder.encodeObject(recordar, forKey: "recordar")
        coder.encodeObject(usuario, forKey: "usuario")
    }
}