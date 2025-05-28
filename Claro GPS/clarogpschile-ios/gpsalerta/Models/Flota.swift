//
//  Flota.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 9/4/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class Flota: NSObject , MKAnnotation{
    var _modelo :String
    var _patente :String
    var _gps :String
    var _estado :String
    var _velocidad :String
    var _ubicacion :String
    var _fecha :String
    var _latitud :String
    var _longitud :String
    var _nombre :String
    var _ignicion :String
    
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return "\(self._ubicacion) "
    }
    
    var subtitle: String? {
        return "\(self._velocidad) Km/hr, \(self._fecha)"
    }
    
    init(modelo :String, patente :String, estado :String, velocidad :String, ubicacion :String, fecha :String, latitud :String, longitud :String, nombre :String, gps :String, ignicion: String)
    {
        
        self._modelo = modelo
        self._patente = patente
        self._estado = estado
        self._velocidad = velocidad
        self._ubicacion = ubicacion
        self._fecha = fecha
        self._latitud = latitud
        self._longitud = longitud
        self._nombre = nombre
        self._gps = gps
        self._ignicion = ignicion
        self.coordinate = CLLocationCoordinate2D(latitude: (self._latitud as NSString).doubleValue, longitude: (self._longitud as NSString).doubleValue)
        
        super.init()
    }
    
    override init(){
        self._modelo = String()
        self._patente = String()
        self._gps = String()
        self._estado = String()
        self._velocidad = String()
        self._ubicacion = String()
        self._fecha = String()
        self._latitud = "-33.445569"
        self._longitud = "-70.640212"
        self._nombre = String()
        self._ignicion = String()
        self.coordinate = CLLocationCoordinate2D(latitude: (self._latitud as NSString).doubleValue, longitude: (self._longitud as NSString).doubleValue)
    }
    
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): self.subtitle as! AnyObject]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        
        return mapItem
    }

}
