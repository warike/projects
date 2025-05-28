//
//  RecipeDetailsViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 9/28/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Nuke

let ingredients_tab_title = "Ingredients"
let nutritions_tab_title = "Nutritions"
let directions_tab_title = "Directions"
let recipe_details_title = "Details"

class RecipeDetailsViewController: ButtonBarPagerTabStripViewController, ScooditHelper {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    
    var recipe = Recipe()
    @IBOutlet weak var shadowView: UIView!
    
    override func viewDidLoad() {
        
        self.recipeTitle.text = recipe.title
        if (recipe.imageUrl.characters.count) > 0 {
            let url = URL(string: (recipe.imageUrl))!
            let request = Request(url: url)
            Nuke.loadImage(with: request, into: recipeImage)
        }
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = menuColor
        settings.style.selectedBarBackgroundColor = scoodit_color
        settings.style.buttonBarItemFont = menuFont
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = menuColor
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = nonSelectedColor
            newCell?.label.textColor = selectedColor
        }
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        return self.getRecipeTabs(from: recipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = recipe_details_title

    }

    func getRecipeTabs(from recipe: Recipe) -> [UIViewController] {
        let child_1 = RecipeIngredientsViewController(itemInfo: IndicatorInfo(title: ingredients_tab_title))
        let child_2 = RecipeDirectionsViewController(itemInfo: IndicatorInfo(title: directions_tab_title))
        let child_3 = RecipeIngredientsViewController(itemInfo: IndicatorInfo(title: nutritions_tab_title))
        
        
        child_1.ingredientsList = recipe.ingredients
        child_1.recipeName = recipe.title
        child_1.recipe_id = recipe._ID
        child_1.selectedServing = String(LibraryAPI.sharedInstance.getUserEntity().householdsize)
        child_1.recipeServingNumber = recipe.servingNumber
        
        child_2.url = recipe.sourceUrl
        
        
        child_3.ingredientsList = recipe.ingredients
        child_3.recipeName = recipe.title
        child_3.recipeServingNumber = recipe.servingNumber
        
        return [child_1, child_2]
    }

}
