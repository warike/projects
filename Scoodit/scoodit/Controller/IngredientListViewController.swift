//
//  IngredientListViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/10/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Nuke


class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SortHelper {

    @IBOutlet weak var IngredientsTableView: UITableView!
    
    var IngredientList : [Ingredient]  = [Ingredient]()
    var ingredientsByCategory = [[Ingredient]]()
    var categoriesAvailables : [String] = []
    var hasDeleted : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initDelegates()
        
        self.addMenuButton()
        self.addUserProfileButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadList()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: title_haveit_image))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rowsPerSectionCount = self.ingredientsByCategory[section].count
        return rowsPerSectionCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.categoriesAvailables.count
        return count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   
    

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let onDelete = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            
            let index = indexPath.row
            let section = indexPath.section
            let currentCategory = self.ingredientsByCategory[section]
            let i = currentCategory[index]
            
            let qtyIngredientsInSectionAfterDelete = (currentCategory.count-1)
            
            if qtyIngredientsInSectionAfterDelete == 0
            {
                self.categoriesAvailables.remove(at: section)
                self.ingredientsByCategory[section].remove(at: index)
                self.ingredientsByCategory.remove(at: section)
                
                
                let indexSet = NSMutableIndexSet()
                indexSet.add(section)
                tableView.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.none)
            }
            else
            {
                
                self.ingredientsByCategory[section].remove(at: index)
                tableView.deleteRows(at: [indexPath], with:UITableViewRowAnimation.none)
            }
            
            LibraryAPI.sharedInstance.removeIngredient(i, remove_option: .removeOne, completion: {
                (result) -> Void in
                
            })
            
        }
        let deleteAction = UITableViewRowAction(style: .default, title: title_delete_button, handler: onDelete)
        deleteAction.backgroundColor = deleteIngredientColorActionRow
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = ingredientColorHaveIt
        return [deleteAction]
    }
 
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        if (indexPath != nil)
        {
            if let cell = tableView.cellForRow(at: indexPath!){
                
                if !((indexPath?.row)! % 2 == 0 ){
                    cell.backgroundColor = ingredientColorHaveIt
                }else
                {
                    cell.backgroundColor = .white
                }
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ingredient_category_view)
        
        let width = tableView.bounds.width
        let height = 40
        
        let frame = CGRect(x: 0, y:3, width: CGFloat(width), height: CGFloat(height))
        let ingredientCategoryView = IngredientCategoryView(frame: frame)
        let title = self.categoriesAvailables[section].uppercased()
        ingredientCategoryView.setTitle(title: title)
        
        cell?.addSubview(ingredientCategoryView)
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.IngredientsTableView.dequeueReusableCell(withIdentifier: ingredient_tableView_cell) as! IngredientTableViewCell
        
        let index = indexPath.row
        let section = indexPath.section
        let ingredient : Ingredient = ingredientsByCategory[section][index]
        
        let star_type = (ingredient.isRequired) ? "star_1" : "star_0"
        
        
        cell.title.text = ingredient.text
        cell.ingredientImage.image = UIImage(named: default_image_ingredient)
        cell.starImage.image = UIImage(named: star_type)
        
        if ingredient.imageUrl != empty_string_value {
            let url = URL(string: ingredient.imageUrl)!
            let request = Request(url: url)
            Nuke.loadImage(with: request, into: cell.ingredientImage)
        }
        
        
        
        if !(indexPath.row % 2 == 0 ){
            cell.backgroundColor = ingredientColorHaveIt
        }else
        {
            cell.backgroundColor = .white
        }
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
        self.isRequired(indexPath: indexPath)
    }
    
}


