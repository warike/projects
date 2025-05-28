//
//  HistorialPatenteViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class HistorialPatenteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tableVehiculos: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    let _EventoSegueIdentifier = "verListaEventos"
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    var _isSearching:Bool = false
    var _searchingVehiculos = [Vehiculo]()
    var _vehiculos = [Vehiculo]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iniciarHistorialPantete()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Historial"
        
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: self._activity)
        self.navigationItem.rightBarButtonItem = btnActivity
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillDisappear(animated: Bool){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}



