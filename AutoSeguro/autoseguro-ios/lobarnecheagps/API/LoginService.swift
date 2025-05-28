//
//  LoginService.swift
//  lobarnecheagps
//
//  Created by Diego Robles on 06-08-15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

/**ice
http://libs.samtech.cl/movil/SesionUsuario.asp?ilogin=nombre_usuario&ipassword=clave&app=app

Parámetros:
- ilogin : nombre de usuario
- ipassword : contraseña
- app : nombre de app [claro/tracklite/isamtech]
**/

open class LoginService: ILoginService {
    
    let _manager = AFHTTPRequestOperationManager()
    let _usuario = Usuario()
    
    func login(_ ilogin:String, ipassword:String, recordar: Int){
        
        self._usuario.ilogin = ilogin
        self._usuario.ipassword = ipassword
        
        let url = "http://libs.samtech.cl/movil/SesionUsuario.asp"
        
        let parametros = ["ilogin":ilogin, "ipassword":ipassword, "app":"claro"]
        var respuesta : Bool = false
        
        _manager.post(url, parameters: parametros,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let respuestas : NSArray = responseObject.object(forKey: "users") as? NSArray {
                    for respt in respuestas {
                        let mensaje : String = respt["mensaje"] as! String
                        let tipo: String = respt["tipo_usuario"] as! String
                        
                        let vel : String = respt["contro_vel"] as! String
                        let demo : String = respt["demo"] as! String
                        let est : String = respt["estado"] as! String
                        let deviceToken :String = LibraryAPI.sharedInstance.getDeviceToken()
                        
                        if !deviceToken.isEmpty { LibraryAPI.sharedInstance.InsertaDToken(deviceToken) }
                        
                        LibraryAPI.sharedInstance.setVelocidadActivado(vel)
                        LibraryAPI.sharedInstance.setEstacionadoActivado(est)
                        
                        
                        if(mensaje  == "1") {
                            respuesta = true
                            
                            self._usuario.ilogin = ilogin
                            self._usuario.ipassword = ipassword
                            self._usuario.tipo =  Int(tipo)!
                            self._usuario.recordar = recordar
                            self._usuario.demo = Int(demo)!
                            
                            LibraryAPI.sharedInstance.setUsuario(self._usuario)
                            
                            let encodedIlogin = NSKeyedArchiver.archivedData(withRootObject: self._usuario.ilogin)
                            let encodedIpassword = NSKeyedArchiver.archivedData(withRootObject: self._usuario.ipassword)
                            let encodedTipo = NSKeyedArchiver.archivedData(withRootObject: self._usuario.tipo)
                            let encodedRecordar = NSKeyedArchiver.archivedData(withRootObject: self._usuario.recordar)
                            let encodedDemo = NSKeyedArchiver.archivedData(withRootObject: self._usuario.demo)
                            
                            let encodedUsuario: [Data] = [encodedIlogin, encodedIpassword, encodedTipo, encodedRecordar, encodedDemo]
                            
                            UserDefaults.standard.set(encodedUsuario, forKey: "usuario")
                            UserDefaults.standard.synchronize()
                        }
                    }
                    
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "respuestaLogin"), object: self, userInfo: ["respuesta": respuesta])
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "respuestaLogin"), object: self, userInfo: ["respuesta": false])
        })
    }
    
    func recuperarContraseña(_ ilogin:String) -> String{
        
        self._usuario.ilogin = ilogin
        
        let url = "http://libs.samtech.cl/movil/RecuperaContrasena.asp"
        let parametros = ["ilogin":ilogin]
        var mensaje : String = String()
        
        _manager.post(url, parameters: parametros,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let respuestas : NSArray = responseObject.object(forKey: "contrasena") as? NSArray {
                    for respt in respuestas {
                        mensaje = respt["mensaje"] as! String
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "respuestaRecuperaContraseña"), object: self, userInfo: ["respuesta": mensaje])
                    }
                }
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "respuestaRecuperaContraseña"), object: self, userInfo: ["respuesta": "Error de conexión"])
        })
        
        return mensaje
    }
}
