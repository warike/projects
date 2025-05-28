//
//  RecipeViewController.swift
//  scoodit
//
//  Created by RWBook Retina on 1/30/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Nuke

class RecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScooditHelper {
    
    @IBOutlet var recipeTableView: UITableView!
    var recipe = Recipe()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        
        let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: _activity)
        self.navigationController?.navigationItem.rightBarButtonItem = btnActivity
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: _activity)
        self.navigationController?.navigationItem.rightBarButtonItem = btnActivity
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.eatIt)
        
        let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        let btnActivity: UIBarButtonItem = UIBarButtonItem(customView: _activity)
        self.navigationController?.navigationItem.rightBarButtonItem = btnActivity

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
        self.navigationItem.titleView = UIImageView()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.seeDetails()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if ((indexPath as NSIndexPath).row == 0){
            let cell = self.recipeTableView.dequeueReusableCell(withIdentifier: "ProfileRecipeTableViewCell") as! ProfileRecipeTableViewCell
            if (recipe.imageUrl.characters.count) > 0 {
                let url = URL(string: (recipe.imageUrl))!
                let request = Request(url: url)
                Nuke.loadImage(with: request, into: cell.profileImage)
            }
            
            let exist = LibraryAPI.sharedInstance.existInFavorites(recipe: recipe)
            let img = exist ? "like_1": "like_0"
            cell.favoriteBtn.setImage(UIImage(named: img), for: UIControlState.normal)
            
            return cell
        }
        else if ((indexPath as NSIndexPath).row == 1)
        {
            let cell = self.recipeTableView.dequeueReusableCell(withIdentifier: "TitleRecipeTableViewCell") as! TitleRecipeTableViewCell
            cell.titleRecipe.text = recipe.title
            return cell
        }
        else if((indexPath as NSIndexPath).row == 2) {
            
            let cell = self.recipeTableView.dequeueReusableCell(withIdentifier: "OptionsRecipeTableViewCell") as! OptionsRecipeTableViewCell
            
            cell.ingredientsBtn.addTarget(self, action: #selector(RecipeViewController.seeDetails), for: UIControlEvents.touchUpInside)
            cell.directionsBtn.addTarget(self, action: #selector(RecipeViewController.seeDetails), for: UIControlEvents.touchUpInside)
            cell.nutritionBtn.addTarget(self, action: #selector(RecipeViewController.seeDetails), for: UIControlEvents.touchUpInside)
            

            cell.nIngredients.text = "\(recipe.qtyIngredients)"
            let cooking_time = (recipe.cookingTime.isEmpty) ? "-- min" : recipe.cookingTime
            cell.cookingTime.text = "\(cooking_time)"
            
            self.recipeTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            return cell
        }
        else {
            let cell = self.recipeTableView.dequeueReusableCell(withIdentifier: "ContentRecipeTableViewCell") as! ContentRecipeTableViewCell
            cell.IngredientList = recipe.ingredients
            cell.showIngredientTable()
            return cell
        
        }
    
        
    }
    
    
    @IBAction func likeRecipe(_ sender: UIButton) {
        
        if sender.tag == 0 {
            sender.tag = 1
        }else {
            sender.tag = 0
        }
        
        let exist = LibraryAPI.sharedInstance.existInFavorites(recipe: recipe)
        if  exist {
            // if it does exist we remove it
            LibraryAPI.sharedInstance.removeRecipe(fromFavorites: recipe)
            sender.setImage(UIImage(named: "like_0"), for: UIControlState.normal)
        }
        else{
            // if it does not exist we add it
            LibraryAPI.sharedInstance.addRecipe(toFavorites: recipe)
            sender.setImage(UIImage(named: "like_1"), for: UIControlState.normal)
        }
        
    }
    
    
    @IBAction func seeDetails()
    {
        self.performSegue(withIdentifier: "recipe_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipe_detail" {
            if let destino = segue.destination as? RecipeDetailsViewController {
                destino.recipe = recipe
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            let h = tableView.bounds.height
            
            if (indexPath as NSIndexPath).row == 0 {
                return (h*0.678)
            }
            else if (indexPath as NSIndexPath).row ==  1{
                return (h*0.108)
            }
            else if (indexPath as NSIndexPath).row ==  2{
                return (h*0.18)
            }
            else {
                return 237
            }
    }
    
    
}
