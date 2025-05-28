//
//  IUsuarioService.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/18/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IUsuarioService {

    func getListaUsuarios()-> Void
    
    func AsignaVehiculosPorUsuario(_ user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    
    func InsertaUsuario(_ usuario_id: String, nombre_id: String, password_id: String, mail_id: String, numero_id: String, tipo_id: String)
    
    func NombrePorPatente(_ gps_id: String, patente_id: String, nombre_id: String, accion_id: String) -> Void
    
    func ActualizarNombrePorPatente(_ gps_id: String, patente_id: String, nombre_id: String) -> Void
    
    func InsertaDeviceToken(_ device_id: String) -> Void
    
    func ActualizarAsignaVehiculosPorUsuario(_ user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    
    func ActualizarNotificaciones(_ accion_id: String, estado_id: String, notificacion_id: String) -> Void
    
    func consultaEstados() -> Void
    
    func ContactoList(_ contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void
    
    func ContactoActualizar(_ contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void
    
    func InsertarUsuarioDemo(_ email: String, ilogin: String, ipassword: String, nombre: String,
        apellido: String, rut: String, fono: String)
    
    func SolicitarEjecutivo(_ ilogin: String, ipassword: String)
}
