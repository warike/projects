//
//  IIngredientService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

protocol IIngredientService{

    func addIngredient(_ user_id: String, ingredient_id: String, is_required: String?,completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    
    func removeIngredient(_ user_id: String, ingredient_id: String, remove_option: RemoveOption, completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    
    func setEncodedIngredients(_ ingredients : [Ingredient]) -> Void
    
    func getIngredientsFromMemory() -> [Ingredient]?
    
    func getIngredientsCount() -> Int
    
    func getIngredient(_ index: Int) -> Ingredient
    
    func deleteIngredients()
    
    func getIngredientsFromAPI(_ user_id : String,completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    
    func getUserIngredients(_ user_id :String, completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    
    func getIngredientsFromCloudVision(_ image: UIImage, completion: @escaping ((_ result : [String]) -> Void)) -> Void
    
    func getIngredientsFromClarifai(_ image: UIImage, completion: @escaping ((_ result : [String]) -> Void)) -> Void
}
