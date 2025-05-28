//
//  Recipe.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    
    var _ID : String
    var title : String
    var website : String
    var imageUrl : String
    
    var provider : String
    var sourceUrl : String
    var servingNumber : String
    var cookingTime: String
    var status: Bool
    
    var ingredients : [Ingredient]
    var ingredients_dto: [IngredientDTO] = []
    
    var ingredientNames : [String]
    var mealTypes : [String]
    var cousinTypes : [String]
    
    var tempData = Data()
    var missingFromUser :Int { get { return LibraryAPI.sharedInstance.getMissingIngredients(from: self) } }
    
    var qtyIngredients :Int { get { return self.ingredients.count } }
    
    override init()
    {
        self._ID = String()
        self.title = String()
        self.imageUrl = String()
        self.website = String()
        
        self.provider = String()
        self.sourceUrl = String()
        self.servingNumber = "4"
        self.cookingTime = String()
        self.status = true
        
        self.ingredients = []
        self.ingredientNames = []
        self.mealTypes = []
        self.cousinTypes = []
        
        self.tempData = Data()
    }
    
    
    func initWithCoder(_ decoder: NSCoder) -> Recipe {
        
        self._ID = decoder.decodeObject(forKey: "_ID") as! String
        self.title = decoder.decodeObject(forKey: "title") as! String
        self.imageUrl = decoder.decodeObject(forKey: "imageUrl") as! String
        self.website = decoder.decodeObject(forKey: "website") as! String
        
        self.provider = decoder.decodeObject(forKey: "provider") as! String
        self.sourceUrl = decoder.decodeObject(forKey: "sourceUrl") as! String
        self.servingNumber = decoder.decodeObject(forKey: "servingNumber") as! String
        self.cookingTime = decoder.decodeObject(forKey: "cookingTime") as! String
        self.status = decoder.decodeBool(forKey: "status")
        
        self.ingredients_dto = decoder.decodeObject(forKey: "ingredients_dto") as! [IngredientDTO]
        self.ingredientNames = decoder.decodeObject(forKey: "ingredientNames") as! [String]
        self.mealTypes = decoder.decodeObject(forKey: "mealTypes") as! [String]
        self.cousinTypes = decoder.decodeObject(forKey: "cousinTypes") as! [String]
        
        self.tempData = decoder.decodeObject(forKey: "tempData") as! Data
        return self
    }
    
    
    func encodeWithCoder(_ coder: NSCoder!) -> Void {
        
        coder.encode(self._ID, forKey: "_ID")
        coder.encode(self.title, forKey: "title")
        coder.encode(self.imageUrl, forKey: "imageUrl")
        coder.encode(self.website, forKey: "website")
        
        coder.encode(self.provider, forKey: "provider")
        coder.encode(self.sourceUrl, forKey: "sourceUrl")
        coder.encode(self.servingNumber, forKey: "servingNumber")
        coder.encode(self.cookingTime, forKey: "cookingTime")
        coder.encode(self.status, forKey: "status")
        coder.encode(self.ingredients_dto, forKey: "ingredients_dto")
        coder.encode(self.ingredientNames, forKey: "ingredientNames")
        coder.encode(self.mealTypes, forKey: "mealTypes")
        coder.encode(self.cousinTypes, forKey: "cousinTypes")
        coder.encode(self.tempData, forKey: "tempData")
        
    }
    
    func backupIngredients(){
        for ingredient in self.ingredients{
            let ingredient_dto = IngredientDTO(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
            self.ingredients_dto.append(ingredient_dto)
        }
    }
    
    func restoreIngredients(){
        var ingredients_list = [Ingredient]()
        for ingredient in self.ingredients_dto{
            let ingredient_dto = Ingredient(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
            
            ingredients_list.append(ingredient_dto)
        }
        self.ingredients = ingredients_list
    }
    

}
