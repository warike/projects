//
//  ShopExtension.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Nuke


extension ShopViewController: UITableViewDelegate, UITableViewDataSource
{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missingIngredients.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with:UITableViewRowAnimation.fade)
            self.missingIngredients.remove(at: indexPath.row)
            LibraryAPI.sharedInstance.updateMissingIngredients(ingredients: self.missingIngredients)
            self.tableView.endUpdates()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: missinIngredientCell, for: indexPath) as! selectCell
        
        let i = missingIngredients[indexPath.row]
        let img = UIImage(named: "default_image_ingredient")
        
        cell.setImage(img: img!)
        if (i.imageUrl.characters.count) > 0 {
            let url = URL(string: (i.imageUrl))!
            let request = Request(url: url)
            Nuke.loadImage(with: request, into: cell.userImage)
        }
        
        cell.configureWithData(i,serving: 1)
        cell.selectionStyle = .none
        
        if !(indexPath.row % 2 == 0 ){
            cell.colorCell()
        }

        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
