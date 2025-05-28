//
//  LoginService.swift
//  GPS ALERTA
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

public class LoginService: ILoginService {
    
    let _manager = AFHTTPRequestOperationManager()
    let _usuario = Usuario()
    
    func login(ilogin:String, ipassword:String, recordar: Int){
        
        self._usuario.ilogin = ilogin
        self._usuario.ipassword = ipassword
        
        let url = "http://libs.samtech.cl/movil/SesionUsuario.asp"
        
        let parametros = ["ilogin":ilogin,"ipassword":ipassword,"app":"claro"]
        var respuesta : Bool = false
        
        _manager.POST(url, parameters: parametros,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let respuestas : NSArray = responseObject.objectForKey("users") as? NSArray {
                    for respt in respuestas {
                        let mensaje : String = respt["mensaje"] as! String
                        let tipo: String = respt["tipo_usuario"] as! String
                        
                        let vel : String = respt["contro_vel"] as! String
                        let est : String = respt["estado"] as! String
                        let deviceToken :String = LibraryAPI.sharedInstance.getDeviceToken()
                        
                        if !deviceToken.isEmpty { LibraryAPI.sharedInstance.InsertaDToken(deviceToken) }
                        
                        LibraryAPI.sharedInstance.setVelocidadActivado(vel)
                        LibraryAPI.sharedInstance.setEstacionadoActivado(est)
                        
                        if(mensaje  == "1") {
                            respuesta = true
                            
                            self._usuario.ilogin = ilogin
                            self._usuario.ipassword = ipassword
                            self._usuario.tipo = Int(tipo)!
                            self._usuario.recordar = recordar
                            self._usuario.usuario = respt["usuario"] as! String
                            
                            LibraryAPI.sharedInstance.setUsuario(self._usuario)
                            
                            let encodedIlogin = NSKeyedArchiver.archivedDataWithRootObject(self._usuario.ilogin)
                            let encodedIpassword = NSKeyedArchiver.archivedDataWithRootObject(self._usuario.ipassword)
                            let encodedTipo = NSKeyedArchiver.archivedDataWithRootObject(self._usuario.tipo)
                            let encodedRecordar = NSKeyedArchiver.archivedDataWithRootObject(self._usuario.recordar)
                            let encodedUsu = NSKeyedArchiver.archivedDataWithRootObject(self._usuario.usuario)
                            
                            let encodedUsuario: [NSData] = [encodedIlogin, encodedIpassword, encodedTipo, encodedRecordar, encodedUsu]
                            
                            NSUserDefaults.standardUserDefaults().setObject(encodedUsuario, forKey: "usuario")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        }
                    }
                    
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaLogin", object: self, userInfo: ["respuesta": respuesta])
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                //println("Error: " + error.localizedDescription)
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaLogin", object: self, userInfo: ["respuesta": false])
        })
    }
    
    func recuperarContraseña(ilogin:String) -> String{
        
        self._usuario.ilogin = ilogin
        
        let url = "http://libs.samtech.cl/movil/RecuperaContrasena.asp"
        let parametros = ["ilogin":ilogin]
        var mensaje : String = String()
        
        _manager.POST(url, parameters: parametros,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let respuestas : NSArray = responseObject.objectForKey("contrasena") as? NSArray {
                    for respt in respuestas {
                        mensaje = respt["mensaje"] as! String
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("respuestaRecuperaContraseña", object: self, userInfo: ["respuesta": mensaje])
                    }
                }
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                //println("Error: " + error.localizedDescription)
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaRecuperaContraseña", object: self, userInfo: ["respuesta": "Error de conexión"])
        })
        
        return mensaje
    }
}