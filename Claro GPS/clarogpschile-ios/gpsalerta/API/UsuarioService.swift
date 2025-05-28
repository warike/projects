//
//  UsuarioService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/18/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class UsuarioService: NSObject, IUsuarioService {
    
    let _manager: AFHTTPRequestOperationManager
    var _usuarios :[Usuario] = [Usuario]()
    var _vehiculosUsuario : [Vehiculo] = [Vehiculo]()
    var _notificaciones : [Notificacion] = [Notificacion]()
    var _contactos : [Contacto] = [Contacto]()
    var _respuesta : [NSObject : AnyObject]


    
    override init(){
        self._manager = AFHTTPRequestOperationManager()
        self._usuarios = [Usuario]()
        self._vehiculosUsuario = [Vehiculo]()
        self._notificaciones = [Notificacion]()
        self._contactos = [Contacto]()
        self._respuesta = ["respuesta": false, "mensaje" : "Ha ocurrido un Error, intente de nuevo"]

    }
    
    init(usuarios: [Usuario], manager: AFHTTPRequestOperationManager){
        self._usuarios = usuarios
        self._manager = manager
        self._respuesta = ["respuesta": false, "mensaje" : "Ha ocurrido un Error, intente de nuevo"]
    }
    
    func ContactoActualizar(contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void {
        let url: String = "http://libs.samtech.cl/movil/contacto.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin, "ipassword": user.ipassword, "Sw": accion_id, "Id_cont": contenido_id, "Nombre": nombre_id, "Telefono": telefono_id, "Mail": mail_id]
        self._respuesta = ["respuesta": false, "mensaje" : "Ha ocurrido un Error, intente de nuevo"]

        _manager.POST(url, parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let contactos : NSArray = responseObject.objectForKey("lista") as? NSArray {
                    self._respuesta = ["respuesta": true, "mensaje": ""]

                    for contacto in contactos {
                        let mensaje = contacto["Nombre"] as! String
                        
                        if (mensaje == "Usuario Registrado" || mensaje  == "Contacto actualizado" || mensaje == "Contacto eliminado")
                        {
                            self._respuesta = ["respuesta": true, "mensaje": mensaje]
                            
                        }
                        else
                        {
                            self._respuesta = ["respuesta": false, "mensaje": mensaje]
                        }
                        
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacion", object: self, userInfo: self._respuesta)

                }
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacion", object: self, userInfo: ["respuesta": false])
        })
        
        
    }
    
    
    func ContactoList(contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void {
        
        let url: String = "http://libs.samtech.cl/movil/contacto.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword,"Sw": accion_id]
        self._contactos.removeAll(keepCapacity: true)
        _manager.POST(url, parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let contactos : NSArray = responseObject.objectForKey("lista") as? NSArray {
                    for contacto in contactos {
                        let contactoDTO : Contacto = Contacto(_id: contacto["ID_cont"] as! String, _nombre: contacto["Nombre"] as! String, _telefono: contacto["Telefono"] as! String, _mail: contacto["eMail"] as! String)
                        self._contactos.append(contactoDTO)

                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaContactos", object: self, userInfo: ["contactosDTO": self._contactos])

            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                
        })
    }

    
    func consultaEstados(){
        
        let url: String = "http://libs.samtech.cl/movil/SesionUsuario.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin, "ipassword": user.ipassword, "app": "claro"]
        
        _manager.POST(url, parameters: parameters,
            success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                if let respuestas : NSArray = responseObject.objectForKey("users") as? NSArray {
                    for respt in respuestas {
                        let vel : String = respt["contro_vel"] as! String
                        let est : String = respt["estado"] as! String
                        let uso : String = respt["conta_uso"] as! String
                        
                        LibraryAPI.sharedInstance.setVelocidadActivado(vel)
                        LibraryAPI.sharedInstance.setEstacionadoActivado(est)
                        LibraryAPI.sharedInstance.setControlUsoActivado(uso)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("respuestaEstados", object: self, userInfo: nil)
                    }
                }
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                
        })
        
        
    }
   
    func getListaUsuarios()-> Void {
    
        let url: String = "http://libs.samtech.cl/movil/ConsultaUsuario.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword]
        self._usuarios.removeAll(keepCapacity: true)

        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let usuarios : NSArray = responseObject.objectForKey("usuarios") as? NSArray {
                    for usuario in usuarios {
                        
                        let usuarioDTO : Usuario = Usuario(ilogin: usuario["Usuario"] as! String,
                            ipassword: usuario["Clave"] as! String,
                            tipo: 2 ,
                            email: usuario["Mail"] as! String,
                            nombre: usuario["Nombre"] as! String,
                            fono: usuario["Fono"] as! String
                        )
                        self._usuarios.append(usuarioDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaUsuarios", object: self, userInfo: ["usuariosDTO": self._usuarios])
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
        
        
    }
    
    /*
    http://libs.samtech.cl/movil/AsignaVehiculosPorUsuario.asp
    Parámetros
    
    usuario: Corresponde al nombre de usuario que desea asignar o listar patentes asignadas.
    GPS: Corresponde al id gps del vehículo que desea asignar. Si el tipo de acción es 1, no necesita enviar este parámetro.
    Patente: Corresponde a la patente del vehículo que desea asignar. Si el tipo de acción es 1, no necesita enviar este parámetro.
    Estado: Corresponde al estado al estado de asignación que desea enviar. Si estado=0, la patente será desasignada del usuario. Si el estado=1, la patente será asignada al usuario.
    Acción: Corresponde a las acciones que puede realizar en este método. Donde; 1=Listar todo los vehículos con su estado de asignación, 2=Actualizar el estado de asignación según el valor del parámetro ‘Estado’ que se haya enviado.
    ilogin: Corresponde nombre de inicio de sesión del cliente principal de la cuenta.
    ipassword: Corresponde a la clave del cliente principal.
    */
    
    func AsignaVehiculosPorUsuario(user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    {
        
        let url: String = "http://libs.samtech.cl/movil/AsignaVehiculosPorUsuario.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "usuario":user_id, "patente":patente_id, "estado":estado_id, "accion":accion_id]
        self._vehiculosUsuario.removeAll(keepCapacity: true)
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.objectForKey("vehiculos") as? NSArray {
                    for vehiculo in vehiculos {
                        let vehiculoDTO = Vehiculo(
                            patente_id: vehiculo["Patente"] as! String,
                            gps_id: vehiculo["GPS"] as! String,
                            estado_id: vehiculo["Estado"] as! String,
                            velocidad_id: "")
                        self._vehiculosUsuario.append(vehiculoDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaVehiculos", object: self, userInfo: ["vehiculos": self._vehiculosUsuario])
                    
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })

        
    }
    
    func ActualizarAsignaVehiculosPorUsuario(user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    {
        
        let url: String = "http://libs.samtech.cl/movil/AsignaVehiculosPorUsuario.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "id": gps_id, "usuario":user_id, "patente":patente_id, "estado":estado_id, "accion":accion_id]
        
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })
        
        
    }
    
    
    
    
    /*
    http://libs.samtech.cl/movil/InsertaUsuario.asp
    
    Parámetros:
    
    usuario: Corresponde al nombre de inicio de sesión del usuario. Debe ser un nombre de largo 10 sin espacio.
    Nombre_usu: Corresponde al nombre real del usuario.
    Clave_usuario: Corresponde a la clave de acceso del usuario. Deber ser de largo 60 sin espacio.
    Mail_usuario: Corresponde al mail del usuario.
    Tipo_ingreso: Es un valor entero entre el 1 y 6 que corresponde al tipo de acción que desea realizar. Dónde:
     Ingresar usuario
     Actualizar Usuario
     Eliminar Usuario
     Desactivar usuario
     Activar usuario
     ilogin: Corresponde nombre de sesión del cliente principal.
     ipassword: Corresponde a la clave del cliente.
    Respuesta WS:
    
    El webservice devolverá un string confirmando la acción realizada. Si la acción no se realiza, devolverá la leyenda 'Error: Acción no realizada'.
    */
    
    func InsertaUsuario(usuario_id: String, nombre_id: String, password_id: String, mail_id: String, numero_id: String, tipo_id: String)
    {
        let url: String = "http://libs.samtech.cl/movil/InsertaUsuario.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "usuario": usuario_id, "Nombre_usu": nombre_id, "Clave_usuario": password_id, "Mail_usuario": mail_id, "Tipo_ingreso": tipo_id,"fono": numero_id, "tipo_usu": "2", "app": "claro" ]
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                    
                if let usuarios : NSArray = responseObject.objectForKey("usuario") as? NSArray {
                    for usuario in usuarios {
                        let mensaje = usuario["mensaje"] as! String
                       if(mensaje == "Usuario ingresados" || mensaje == "Usuario actualizado"){
                        NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacionUsuario", object: self, userInfo: ["respuesta": true])
                       }else{
                        NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacionUsuario", object: self, userInfo: ["respuesta": false, "mensaje": mensaje])
                        }
                    }
                    
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacion", object: self, userInfo: ["respuesta": false])
        })
    
    }
    
    /*
    http://libs.samtech.cl/movil/InsertaDeviceToken.asp
    
    Parámetros:
    
    DeviceToken: Corresponde al identificador único de cada dispositivo móvil.
    App: Corresponde al nombre de la aplicación que está iniciando sesión.
    ilogin: Corresponde al nombre de usuario o cliente que desea consultar.
    ipassword: Corresponde al nombre de usuario asociado al cliente principal.
    
    */
    func InsertaDeviceToken(device_id: String) -> Void
    {
    
        let url: String = "http://libs.samtech.cl/movil/InsertaDeviceToken.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "app": "claro", "DeviceToken": device_id]

        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })

    
    }
    
    
    /*
    
    http://libs.samtech.cl/movil/NombrePorPatente.asp
    
    Parámetros
    
    GPS: Corresponde al id gps del vehículo que desea crear un nombre.
    Patente: Corresponde a la patente del vehículo al que desea crear un nombre.
    Nombre: Corresponde al nombre que desea asignarle a la patente.
    Acción: Corresponde a las acciones que puede realizar en este método. Donde; 1=Listar todo los vehículos con su respectivo nombre, 2=Actualizar el nombre de una determinada patente.
    ilogin: Corresponde nombre de inicio de sesión del cliente principal de la cuenta.
    ipassword: Corresponde a la clave del cliente principal.
    */
    
    func NombrePorPatente(gps_id: String, patente_id: String, nombre_id: String, accion_id: String) -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/NombrePorPatente.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "accion": accion_id, "patente": patente_id, "gps": gps_id  ]
        self._vehiculosUsuario.removeAll(keepCapacity: true)
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let vehiculos : NSArray = responseObject.objectForKey("NomPatente") as? NSArray {
                    for vehiculo in vehiculos {
                        let vehiculoDTO = Vehiculo(
                            patente_id: vehiculo["Patente"] as! String,
                            gps_id: vehiculo["GPS"] as! String,
                            nombre_id: vehiculo["Nombre"] as! String)
                        self._vehiculosUsuario.append(vehiculoDTO)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaVehiculos", object: self, userInfo: ["vehiculosDTO": self._vehiculosUsuario])
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //println("Error: " + error.localizedDescription)
        })

    
    }
    
    
    func ActualizarNombrePorPatente(gps_id: String, patente_id: String, nombre_id: String) -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/NombrePorPatente.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "accion": "2", "patente": patente_id, "gps": gps_id, "Nombre": nombre_id  ]
        self._usuarios.removeAll(keepCapacity: true)
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in

                if let vehiculos : NSArray = responseObject.objectForKey("NomPatente") as? NSArray {
                    for vehiculo in vehiculos {
                        if(vehiculo["GPS"] as! String == "Patente Actualizada"){
                            NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacion", object: self, userInfo: ["respuesta": true])
                        }
                    }
                    
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                NSNotificationCenter.defaultCenter().postNotificationName("respuestaActualizacion", object: self, userInfo: ["respuesta": false])
        })
    }
    
    func ActualizarNotificaciones(accion_id: String, estado_id: String, notificacion_id: String) -> Void
    {
        let url: String = "http://libs.samtech.cl/movil/Notificaciones.asp"
        let user: Usuario = LibraryAPI.sharedInstance.getCurrentUser()
        let parameters = ["ilogin": user.ilogin,"ipassword": user.ipassword, "accion": accion_id, "estado" : estado_id, "Id_notificacion" : notificacion_id]
        self._notificaciones.removeAll(keepCapacity: true)
        
        _manager.POST( url,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                if let notificaciones : NSArray = responseObject.objectForKey("notificaciones") as? NSArray {
                    if accion_id == "1" {
                        for notificacion in notificaciones {
                            let notificacionDTO :Notificacion = Notificacion(gps: notificacion["GPS"] as! String, descripcion: notificacion["Descripcion"] as! String, leyenda: notificacion["Leyenda"] as! String, estado: notificacion["Estado"] as! String, esu_id: notificacion["Esu_id"] as! String,patente: "", fechaIni :"",fechaTer: "")
                            self._notificaciones.append(notificacionDTO)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName("actualizarTablaNotificaciones", object: self, userInfo: ["notificacionesDTO": self._notificaciones])
                    }
                }
                
            },
            failure: { (operation: AFHTTPRequestOperation!,error: NSError!) in
                //
        })
    }
    
}
