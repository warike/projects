//
//  Direccion.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class Direccion: NSObject, MKAnnotation  {
    
    var latitud :CLLocationDegrees = CLLocationDegrees()
    var longitud :CLLocationDegrees = CLLocationDegrees()
    var latDelta :CLLocationDegrees = CLLocationDegrees()
    var longDelta :CLLocationDegrees = CLLocationDegrees()
    var direccion: String = String()
    var tipo: String = String()
    let coordinate: CLLocationCoordinate2D
    
    
    var title: String? {
        return "Evento:  \(self.tipo) "
    }
    
    var subtitle: String? {
        return "Ubicación: \(self.direccion)"
    }
    
    override init(){
        
        self.latitud = -33.4727879
        self.longitud = -70.6298313
        self.latDelta = 0.08
        self.longDelta = 0.08
        self.direccion = String()
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud)
        self.tipo = String()
        super.init()
    }
    
    init(_lon: Double, _lat: Double, _latDelta: Double, _lonDelta: Double, _dir : String, _tipo: String) {
        self.latitud = _lat
        self.longitud = _lon
        self.latDelta = _latDelta
        self.longDelta = _lonDelta
        self.direccion = _dir
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitud, longitude: self.longitud)
        self.tipo = _tipo
        
        super.init()
    }
    
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): self.subtitle as! AnyObject]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        
        return mapItem
    }
    
    func pinColor() -> MKPinAnnotationColor  {
        switch tipo {
        case "Abre Contacto":
            return .Green
        case "Corta Contacto":
            return .Red
        default:
            return .Green
        }
    }
}
