//
//  IngredientListExtension.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/10/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Toaster


let ingredient_category_view_name = "IngredientCategoryView"

extension IngredientListViewController {

    func initDelegates() -> Void
    {
        self.IngredientsTableView.delegate = self
        self.IngredientsTableView.dataSource = self
        self.IngredientsTableView.rowHeight = 50
        self.IngredientsTableView.sectionHeaderHeight = 43
        self.view.backgroundColor = backgroundContainer
        self.IngredientsTableView.backgroundColor = backgroundContainer
        
        
        
        IngredientsTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: ingredient_category_view_name)
    }
    
    func loadList() -> Void {
        
        self.IngredientList.removeAll(keepingCapacity: true)
        self.IngredientList = LibraryAPI.sharedInstance.getUserIngredients()
        
        
        let iBC = self.getSortedIngredientsByCategories(IngredientList)
        self.ingredientsByCategory.removeAll()
        self.categoriesAvailables.removeAll()
        
        self.ingredientsByCategory = iBC.0
        self.categoriesAvailables = iBC.1
        
        self.IngredientsTableView?.reloadData()
    }

    
    
    
    func isRequired(indexPath: IndexPath){
        
        
        let ind = indexPath.row
        let sec = indexPath.section
        
        let cell = self.IngredientsTableView.cellForRow(at: indexPath) as! IngredientTableViewCell
        var ingredient = self.ingredientsByCategory[sec][ind]
        let is_required : Bool = (ingredient.isRequired) ? false : true
        let star_type = (is_required) ? "star_1" : "star_0"
        
        self.ingredientsByCategory[sec][ind].isRequired = is_required
        ingredient.isRequired = is_required
        cell.starImage.image = UIImage(named: star_type)
        
        self.IngredientsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        
        LibraryAPI.sharedInstance.updateIngredient(ingredient, is_required: ingredient.isRequired) { (result) -> Void in
            self.IngredientList = result
            let iBC = self.getSortedIngredientsByCategories(self.IngredientList)
            self.ingredientsByCategory.removeAll()
            self.categoriesAvailables.removeAll()
            
            self.ingredientsByCategory = iBC.0
            self.categoriesAvailables = iBC.1
            self.IngredientsTableView.reloadData()
        }
        
    }
    
    @IBAction func DeleteAllAction() {
        self.IngredientList.removeAll(keepingCapacity: true)
        self.ingredientsByCategory.removeAll()
        self.categoriesAvailables.removeAll()
        let iBC = self.getSortedIngredientsByCategories(self.IngredientList)
        
        self.ingredientsByCategory = iBC.0
        self.categoriesAvailables = iBC.1
        
        self.IngredientsTableView?.reloadData()
        
        LibraryAPI.sharedInstance.removeIngredient(nil, remove_option: .removeAll) { (_result) in
            
        }
    }
    
}

