//
//  UserReal.swift
//  scoodit
//
//  Created by Sergio Esteban on 18/03/17.
//  Copyright © 2017 Sergio Cardenas. All rights reserved.
//

import UIKit
import RealmSwift

class UserRealm: Object {
    
    dynamic var username : String = ""
    dynamic var email : String = ""
    dynamic var householdsize : Int = 2
    
    let recipes  = List<RecipeRealm>()

}

class RealmString: Object {
    dynamic var stringValue = ""
}

class RecipeRealm: Object{

    dynamic var _ID : String = ""
    dynamic var title : String = ""
    dynamic var website : String = ""
    dynamic var imageUrl : String = ""
    
    dynamic var provider : String = ""
    dynamic var sourceUrl : String = ""
    dynamic var servingNumber : String = ""
    dynamic var cookingTime: String = ""
    dynamic var status: Bool = true
    
    //dynamic var ingredients : [Ingredient] = []
    let ingredientNames = List<RealmString>()
    let mealTypes = List<RealmString>()
    let cousinTypes = List<RealmString>()
}
