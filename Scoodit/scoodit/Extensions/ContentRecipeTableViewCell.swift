//
//  ContentRecipeTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/2/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//



import UIKit

class ContentRecipeTableViewCell: UITableViewCell , UITableViewDataSource, UITableViewDelegate {

    
    var contentTableView:UITableView?
    var IngredientList = [Ingredient]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showIngredientTable()
    {
        
        self.contentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), style:UITableViewStyle.plain)
        self.contentTableView?.delegate = self
        self.contentTableView?.dataSource = self
        self.contentTableView?.register(IngredientRecipeTableViewCell.self, forCellReuseIdentifier: "IngredientRecipeTableViewCell")
        self.contentTableView?.reloadData()
        self.addSubview(contentTableView!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IngredientList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell? = ((self.contentTableView?.dequeueReusableCell(withIdentifier: "IngredientRecipeTableViewCell"))! as UITableViewCell)
        
        let recipe = IngredientList[indexPath.row]
        let text :String = recipe.quantity == "0" ? recipe.text : "\(recipe.quantity) \(recipe.text)"
        cell?.textLabel!.text = text
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    

}
