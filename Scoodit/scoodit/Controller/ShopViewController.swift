//
//  ShopViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 4/7/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit



class ShopViewController: UIViewController, ScooditHelper{

    var missingIngredients : [Ingredient] = []
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.addMenuButton()
        self.addUserProfileButton()
        
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "selectCell", bundle: Bundle.main), forCellReuseIdentifier: missinIngredientCell)
        tableView.estimatedRowHeight = 60.0;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.missingIngredients = LibraryAPI.sharedInstance.getMissingIngredients()
        self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.buyIt)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteAllMissingIngredients(_ sender: AnyObject)
    {
        self.missingIngredients.removeAll()
        LibraryAPI.sharedInstance.updateMissingIngredients(ingredients: self.missingIngredients)
        self.tableView.reloadData()
    }
    
    

}
