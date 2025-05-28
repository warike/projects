//
//  RecipiesListViewController.swift
//  scoodit
//
//  Created by RWBook Retina on 1/23/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Nuke

let view_recipe_segue = "view_recipe"
let recipe_table_viewcell = "RecipeTableViewCell"

class RecipesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ScooditHelper {
    let recipeTableViewCell = recipe_table_viewcell

    @IBOutlet var RecipesTableView: UITableView!
    @IBOutlet var SearchTextField: UITextField!
  
    var RecipesList : [Recipe] = [Recipe]()
    var searchList : [Recipe] = [Recipe]()
    var _isSearching = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initData()
        self.addMenuButton()
        self.addUserProfileButton()
        
        self.RecipesTableView.delegate = self
        self.RecipesTableView.dataSource = self
        self.SearchTextField.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.requestRecommendations()
        self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.cookIt)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewDidAppear(animated)
        self.SearchTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
        self.navigationItem.titleView = UIImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self._isSearching == true) ? self.searchList.count : self.RecipesList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe :Recipe = (self._isSearching == true) ? self.searchList[(indexPath as NSIndexPath).row] : self.RecipesList[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: view_recipe_segue, sender: recipe)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.RecipesTableView.dequeueReusableCell(withIdentifier: recipeTableViewCell) as! RecipeTableViewCell
        let recipe = (self._isSearching == true) ? self.searchList[(indexPath as NSIndexPath).row] : self.RecipesList[(indexPath as NSIndexPath).row]
        let urlRequest = URL(string: recipe.imageUrl)!
        
        cell.photoImageView.image = UIImage()
        UIView.performWithoutAnimation {
            Nuke.loadImage(with: urlRequest, into: cell.photoImageView)
        }
        
        cell.RecipeNameLabel.text = recipe.title
        cell.CookingTimeLabel.text = String(recipe.cookingTime)
        let number = recipe.missingFromUser
        cell.MissingIngredientsNumber.text = self.getMissingNumberIngredients(from: number)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == view_recipe_segue {
            let recipe = sender as! Recipe
            if let destino = segue.destination as? RecipeViewController {
                destino.recipe = recipe
            }
        }
    }

}
