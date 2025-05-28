//
//  IVehiculoService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IVehiculoService {
    func getListaVehiculoEstacionados() -> Void
    func getListaVehiculoTodos() -> Void
    func actualizarControlVelocidad(gps_id : String, patente_id :String, estado_id : String, velocidad_id :String, accion_id: String) -> Void
    func listaControlVelocidad() -> Void
    func ModoEstacionadoVehiculo(gps_id: String, patente_id :String, estado_id: String, device_token: String, corta_corr: String, genAlert: Bool) -> Void
    func AlarmaSOS(latitud: String, longitud: String) -> Void
    func ContadorVehiculo() -> Void
    func listaControlDeUso() -> Void
    func actualizarControlDeUso(gps_id : String, patente_id :String, estado_id : String, fechaIni :String, fechaTer :String, horaIni :String, horaTer :String, accion_id :String) -> Void
    func getUltimoEstado(gps_id: String, patente_id: String) -> Void
}
