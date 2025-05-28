//
//  IVehiculoService.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IVehiculoService {
    func getListaVehiculoEstacionados() -> Void
    func getListaVehiculoTodos() -> Void
    func actualizarControlVelocidad(_ gps_id : String, patente_id :String, estado_id : String, velocidad_id :String, accion_id: String) -> Void
    func listaControlVelocidad() -> Void
    func ModoEstacionadoVehiculo(_ gps_id: String, patente_id :String, estado_id: String, device_token: String, corta_corr: String, genAlert: Bool) -> Void
    func AlarmaSOS(_ latitud: String, longitud: String) -> Void
    func ContadorVehiculo() -> Void
    func getUltimoEstado(_ gps_id: String, patente_id: String) -> Void
}
