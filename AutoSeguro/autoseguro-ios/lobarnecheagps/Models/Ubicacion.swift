//
//  Ubicacion.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/7/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

/*****
latitud, longitud, velocidad, fecha-hora, chofer, ubicación, faena, id gps y hdg separados por coma
*****/


class Ubicacion: NSObject, MKAnnotation  {
    
    var latitud :CLLocationDegrees = CLLocationDegrees()
    var longitud :CLLocationDegrees = CLLocationDegrees()
    var latDelta :CLLocationDegrees = CLLocationDegrees()
    var longDelta :CLLocationDegrees = CLLocationDegrees()
    var velocidad: String = String()
    var fecha: String = String()
    var hora: String = String()
    var chofer: String = String()
    var ubicacion: String = String()
    var faena: String = String()
    var gps_id: String = String()
    var hdg: String = String()
    var tipo: String = String()
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return "\(self.ubicacion) "
    }
    
    var subtitle: String? {
        return "\(self.velocidad) Km/hr, \(self.fecha) \(self.hora)"
    }
    
    init (_lat: Double, _lon: Double, _latDelta: Double, _lonDelta: Double, _ubic: String, _fecha: String, _hora: String){
        
        self.latitud = _lat
        self.longitud = _lon
        self.latDelta = _latDelta
        self.longDelta = _lonDelta
        self.ubicacion = _ubic
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud)
        self.fecha = _fecha
        self.hora = _hora
        super.init()
    }
    
    override init(){
        // LIRA 196 ,
        self.latitud = -33.445569
        self.longitud = -70.640212
        self.latDelta = 0.08
        self.longDelta = 0.08
        self.ubicacion = String()
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud)
        self.chofer = String()
        super.init()
    }
    
    
    init(_lon: Double, _lat: Double, _latDelta: Double, _lonDelta: Double, _vel: String, _ubi : String, _fecha: String, _hora: String, _chofer: String, _faena: String, _gps_id: String, _hdg: String, _tipo: String) {
        
        self.latitud = _lat
        self.longitud = _lon
        self.latDelta = _latDelta
        self.longDelta = _lonDelta
        self.velocidad = _vel
        self.ubicacion = _ubi
        
        
        self.fecha = _fecha
        self.hora = _hora
        self.chofer = _chofer
        
        self.faena = _faena
        self.gps_id = _gps_id
        self.hdg = _hdg
        self.tipo = _tipo
        
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud)
        
        super.init()
    }
    
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): self.subtitle as AnyObject]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        
        return mapItem
    }
    
    func pinColor() -> MKPinAnnotationColor  {
        switch self.tipo {
        case "Ubicacion":
            return .green
        case "Usuario":
            return .red
        default:
            return .green
        }
    }
}
