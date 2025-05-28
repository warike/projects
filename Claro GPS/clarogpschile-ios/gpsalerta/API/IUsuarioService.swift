//
//  IUsuarioService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/18/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IUsuarioService {

    func getListaUsuarios()-> Void
    
    func AsignaVehiculosPorUsuario(user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    
    func InsertaUsuario(usuario_id: String, nombre_id: String, password_id: String, mail_id: String, numero_id: String, tipo_id: String)
    
    func NombrePorPatente(gps_id: String, patente_id: String, nombre_id: String, accion_id: String) -> Void
    
    func ActualizarNombrePorPatente(gps_id: String, patente_id: String, nombre_id: String) -> Void
    
    func InsertaDeviceToken(device_id: String) -> Void
    
    func ActualizarAsignaVehiculosPorUsuario(user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    
    func ActualizarNotificaciones(accion_id: String, estado_id: String, notificacion_id: String) -> Void
    
    func consultaEstados() -> Void
    
    func ContactoList(contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void
    
    func ContactoActualizar(contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void

}
