//
//  ILoginService.swift
//  GPS ALERTA
//
//  Created by Diego Robles on 06-08-15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol ILoginService{
    func login( ilogin:String, ipassword:String, recordar:Int)
    func recuperarContraseña( ilogin:String) -> String
}