//
//  FavoriteRecipesViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 1/23/17.
//  Copyright © 2017 Sergio Cardenas. All rights reserved.
//

import UIKit


class FavoriteRecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var favoriteRecipes : [Recipe] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.favoriteRecipes = LibraryAPI.sharedInstance.getFavoriteRecipes()
        self.navigationItem.title = favorite_recipe_title
        self.navigationItem.titleView?.tintColor = scoodit_color
        self.tableView.reloadData()
    
    }
    
}

extension FavoriteRecipeListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: favorite_recipe_cell_identifier)! as UITableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.blue;
        
        let text = favoriteRecipes[indexPath.row].title
        
        cell.textLabel!.text = text
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: view_favorite_segue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let onDelete = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            
            let index = indexPath.row
            
            self.favoriteRecipes.remove(at: index)
            
            tableView.deleteRows(at: [indexPath], with:UITableViewRowAnimation.none)
            LibraryAPI.sharedInstance.removeFavoriteRecipe(from: index)
            

            
        }
        let deleteAction = UITableViewRowAction(style: .default, title: title_delete_button, handler: onDelete)
        deleteAction.backgroundColor = deleteIngredientColorActionRow
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = ingredientColorHaveIt
        return [deleteAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == view_favorite_segue {
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let recipe = self.favoriteRecipes[index]
                if let destino = segue.destination as? FavoriteRecipeViewController {
                    destino.recipe = recipe
                }
            }
            
        }
    }

}
