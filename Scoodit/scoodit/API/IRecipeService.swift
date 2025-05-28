//
//  IRecipeService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

protocol IRecipeService{
    
    func getUserRecipes(_ user_id: String) -> Void
    func getFavoriteRecipesInMemory(_ user_id: String) -> [Recipe]
    func saveFavoriteRecipesInMemory(_ recipes: [Recipe]) -> Void
    
}
