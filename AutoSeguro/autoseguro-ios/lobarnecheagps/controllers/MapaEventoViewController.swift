//
//  MapaEventoViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit
import MapKit

class MapaEventoViewController: UIViewController, MKMapViewDelegate {

    
    var _eventoDTO: Evento = Evento()
    var _patente : String = String()
    let _regionRadius: CLLocationDistance = 1000
    
    @IBOutlet var mapaEvento: MKMapView!
    @IBOutlet var tipoLabel: UILabel!
    @IBOutlet var horaLabel: UILabel!
    @IBOutlet var patenteLabel: UILabel!
    
    @IBAction func returnSegue(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            self._regionRadius * 4.0, self._regionRadius * 4.0)
        self.mapaEvento.setRegion(coordinateRegion, animated: true)
    }
    
    func agregarPin(_ direccion :Direccion){
        
        self.mapaEvento.addAnnotation(direccion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let lat :Double  = NSString(string: self._eventoDTO.latitud).doubleValue
        let long :Double = NSString(string: self._eventoDTO.longitud).doubleValue
        let direccion = Direccion(_lon: long, _lat: lat, _latDelta: 0.01, _lonDelta: 0.01, _dir : self._eventoDTO.ubicacion, _tipo: self._eventoDTO.tipo)
        
        
        self.agregarPin(direccion)
        self.tipoLabel.text = self._eventoDTO.tipo
        self.horaLabel.text = self._eventoDTO.hora
        self.patenteLabel.text = self._patente
        
        self.centerMapOnLocation(CLLocation(latitude: lat, longitude: long))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self._eventoDTO.tipo == "Corta Contacto" {
            self.tipoLabel.textColor = UIColor.red
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
