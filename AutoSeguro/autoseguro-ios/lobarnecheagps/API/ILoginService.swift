//
//  ILoginService.swift
//  lobarnecheagps
//
//  Created by Diego Robles on 06-08-15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

protocol ILoginService{
    func login(_ ilogin:String, ipassword:String, recordar:Int)
    func recuperarContraseña(_ ilogin:String) -> String
}
