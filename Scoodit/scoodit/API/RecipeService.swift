//
//  RecipeService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RecipeService: NSObject, IRecipeService {
    
    var _recipesList : [Recipe]
    override init(){
        self._recipesList = [Recipe]()
    }
    
    func saveFavoriteRecipesInMemory(_ recipes: [Recipe]) -> Void{
        if recipes.count > 0 {
            recipes.forEach{ $0.backupIngredients() }
            let encoded_recipes = NSKeyedArchiver.archivedData(withRootObject: recipes)
            let encoded_data: [Data] = [ encoded_recipes ]
            
            UserDefaults.standard.set(encoded_data, forKey: "favorite_recipes")
            UserDefaults.standard.synchronize()
        }
    }
    func getFavoriteRecipesInMemory(_ user_id: String) -> [Recipe] {
        let cached_recipes = UserDefaults.standard.object(forKey: "favorite_recipes")
        var memory_recipes : [Recipe] = []
        if( cached_recipes != nil){
            var recipes: [Data] = cached_recipes as! [Data]
            if recipes.count > 0
            {
                if let recipes = NSKeyedUnarchiver.unarchiveObject(with: recipes[0] as Data) as? [Recipe]{
                    
                    memory_recipes = recipes
                    memory_recipes.forEach{ $0.restoreIngredients() }
                }
            }
        }
        return memory_recipes
        
    }
    func getUserRecipes(_ user_id: String) -> Void {
        var msg = "We couldn't load any suggestion, please try it again."
        var status = false
        var success = false
        let url  = "https://<API_URL>/userrecipes"
        
        
        let params = unpackParametersForRecommendations(data: LibraryAPI.sharedInstance.getUserIngredients(), user_id: user_id)
        
        
        self._recipesList.removeAll()
        var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : self._recipesList as AnyObject, "message" : msg as AnyObject, "success": success as AnyObject]
        
        Alamofire.request(url, parameters: params)
            .responseJSON { response in
                switch response.result {
                case .success:
                    status = true
                    
                    if let result = response.result.value {
                        
                        let recipesJSON = JSON(result)
                        if let recipes = recipesJSON["recipes"].arrayObject {
                            let recipesDTO = recipes as! [[String:AnyObject]]
                            for item in recipesDTO {
                                let recipeDTO = unpackRecipeFromAPI(data: item)
                                self._recipesList.append(recipeDTO)
                            }
                        }
                        if (self._recipesList.isEmpty) {
                            msg = "We couldn't load any suggestion"
                        }else {
                            msg = "Enjoy our suggestions"
                            success = true
                            resultAPI.updateValue(self._recipesList as AnyObject, forKey: "data")
                        }
                        
                    }
                    break
                case .failure:
                    break
                }
                
                resultAPI.updateValue(status as AnyObject, forKey: "status")
                resultAPI.updateValue(success as AnyObject, forKey: "success")
                resultAPI.updateValue(msg as AnyObject, forKey: "message")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "recommendedRecipes"), object: self, userInfo: ["result": resultAPI])
                
        }
    }
}
