//
//  RecipeDirectionsViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 9/30/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RecipeNutritionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    lazy var ingredientsList : [Ingredient] = []
    let cellIdentifier = "nutriotionCell"
    var itemInfo = IndicatorInfo(title: "View")
    var tableView :UITableView = UITableView()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillLayoutSubviews() {
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        tableView.register(UINib(nibName: "selectCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! selectCell
        
        var i = ingredientsList[indexPath.row]
        cell.selectionStyle = .none
        i.isAvailable = !i.isAvailable
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! selectCell
        let i = ingredientsList[indexPath.row]
        
        cell.configureWithData(i,serving: 1)
        cell.postText.font = menuFont
        cell.selectionStyle = .none
        if !(indexPath.row % 2 == 0 ){
            cell.colorCell()
        }
        return cell
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }


}
