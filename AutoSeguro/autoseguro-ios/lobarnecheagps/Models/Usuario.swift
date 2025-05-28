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
    var demo = Int()
    
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
    
    init (ilogin: String, ipassword: String, tipo: Int, recordar:Int, usuario: String, demo: Int){
        self.ilogin = ilogin
        self.ipassword = ipassword
        self.tipo = tipo
        self.recordar = recordar
        self.vehiculo = Vehiculo()
        self.usuario = usuario
        self.demo = demo
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
        self.ilogin = decoder.decodeObject(forKey: "ilogin") as! String
        self.ipassword = decoder.decodeObject(forKey: "ipassword") as! String
        self.tipo = decoder.decodeObject(forKey: "tipo") as! Int
        self.recordar = decoder.decodeObject(forKey: "recordar") as! Int
        self.usuario = decoder.decodeObject(forKey: "_usuario") as! String
        self.demo = decoder.decodeObject(forKey: "demo") as! Int
    }
    
    func initWithDecoder(_ decoder: NSCoder) -> Usuario {
        self.ilogin = decoder.decodeObject(forKey: "ilogin") as! String
        self.ipassword = decoder.decodeObject(forKey: "ipassword") as! String
        self.tipo = decoder.decodeObject(forKey: "tipo") as! Int
        self.recordar = decoder.decodeObject(forKey: "recordar") as! Int
        self.tipo = decoder.decodeObject(forKey: "demo") as! Int
        
        self.usuario = decoder.decodeObject(forKey: "_usuario") as! String
        
        return self
    }
    
    func encodeWithCoder(_ coder: NSCoder!) {
        coder.encode(ilogin, forKey: "ilogin")
        coder.encode(ipassword, forKey: "ipassword")
        coder.encode(tipo, forKey: "tipo")
        coder.encode(recordar, forKey: "recordar")
        coder.encode(demo, forKey: "demo")
        coder.encode(usuario, forKey: "usuario")
    }
}
