//
//  IEventoService.swift
//  GPS ALERTA
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol IEventoService {

    func getEventos(patente_id: String, gps_id: String) -> Void
}
