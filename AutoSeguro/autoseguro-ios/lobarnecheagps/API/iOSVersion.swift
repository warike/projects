//
//  iOSVersion.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 9/2/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import Foundation


let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)