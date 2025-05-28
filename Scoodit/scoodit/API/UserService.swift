    //
//  UserService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserService: NSObject, IUserService {
    
    
    func loginFbUser(_ fb_email: String,  fb_first_name: String, fb_last_name: String,fb_session_id: String, fb_completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void
    
    {

    }
    
    func loginUser(_ username: String, password: String, completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void
    {
        let params = ["username": username , "password": password]
        let headers = ["Content-type" : "application/json"]
        var msg = "error request"
        var status = false
        let user: User = User(username: username, password: password)
        let url  = "https://<API_URL>/userlogin"
        
        var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : "" as AnyObject, "message" : msg as AnyObject]
        
        Alamofire.request(url, parameters: params, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let result = JSON(value)
                        if let status_requested = result["result"]["status"].bool {
                            status = status_requested
                            if let token_id = result["result"]["token_id"].string
                            {
                                user.token_id = token_id
                            }
                            if let email_id = result["result"]["data"]["email"].string
                            {
                                user.email = email_id
                            }
                            if let _id = result["result"]["data"]["id"].string
                            {
                                user.user_id = _id
                            }
                            if let _createdAt = result["result"]["data"]["createdAt"].string
                            {
                                user.createdAt = _createdAt
                            }
                            if let updatedAt = result["result"]["data"]["updatedAt"].string
                            {
                                user.updatedAt = updatedAt
                            }
                            
                            if let required_ingredients = result["result"]["data"]["required_ingredients"].arrayObject {
                                
                                let ingredientsDTO = required_ingredients as! [[String:AnyObject]]
                                
                                for item in ingredientsDTO {
                                    
                                    var img = ""
                                    if let imgValue = item["img"] as? String{
                                        if imgValue != "BsonNull" {
                                            img = imgValue
                                        }
                                    }
                                    
                                    let ingredientDTO = Ingredient(_ID: item["id"] as! String, text: item["text"] as! String, imageUrl: "", pluralName: "", status: true, synonym: [], synonymPlural: [], categories: [], nv: [], dv: [], metric: "", isRequired: item["is_required"] as! Bool, isAvailable: false, quantity:  item["quantity"] as! String, tempImg: Data())
                                    user.ingredients.append(ingredientDTO)
                                }
                                
                            }
                            
                            
                            if let ingredients = result["result"]["data"]["ingredients"].arrayObject {
                                
                                let ingredientsDTO = ingredients as! [[String:AnyObject]]
                                
                                for item in ingredientsDTO {
                                    
                                    var img = ""
                                    if let imgValue = item["img"] as? String{
                                        if imgValue != "BsonNull" {
                                            img = imgValue
                                        }
                                    }
                                    var ingredient_dto =  Ingredient(_ID: "", text: "", imageUrl: "", pluralName: "", status: true, synonym: [], synonymPlural: [], categories: [], nv: [], dv: [], metric: "", isRequired: false, isAvailable: false, quantity: "", tempImg: Data())
                                    if let value = item["id"] as? String{
                                        ingredient_dto._ID = value
                                    }
                                    if let value = item["text"] as? String{
                                        ingredient_dto.text = value
                                    }
                                    if let value = item["quantity"] as? String{
                                        ingredient_dto.quantity = value
                                    }
                                    if let value = item["is_required"] as? String{
                                        ingredient_dto.quantity = value
                                    }

                                    user.ingredients.append(ingredient_dto)
                                }
                                
                            }
                            
                            if status
                            {
                                self.setEncodedUser(user)
                                
                            }
                            
                            
                        } else {
                            status = false
                        }
                        
                        if let message_requested = result["result"]["message"].string {
                            msg = message_requested
                        } else {
                            msg = "Something went wrong, please try it again later."
                        }
                    }
                case .failure:
                    status = false
                    msg = "Error during the request, please try it again later"
                }
                
                resultAPI.updateValue(status as AnyObject, forKey: "status")
                resultAPI.updateValue(user as AnyObject, forKey: "data")
                resultAPI.updateValue(msg as AnyObject, forKey: "message")
                                
                completion(resultAPI)
                
        }
        
        
    
    }
    
    func getUserFromMemory() -> User? {
        let cachedUser = UserDefaults.standard.object(forKey: "user")
        var memory_user : User = User()
        if( cachedUser != nil){
            var user: [Data] = cachedUser as! [Data]
            let user_id :String = NSKeyedUnarchiver.unarchiveObject(with: user[0] as Data) as! String
            let username: String = NSKeyedUnarchiver.unarchiveObject(with: user[1] as Data) as! String
            let password: String = NSKeyedUnarchiver.unarchiveObject(with: user[2] as Data) as! String
            let email: String = NSKeyedUnarchiver.unarchiveObject(with: user[3] as Data) as! String
            let token_id: String = NSKeyedUnarchiver.unarchiveObject(with: user[4] as Data) as! String
            let createdAt: String = NSKeyedUnarchiver.unarchiveObject(with: user[5] as Data) as! String
            let updatedAt: String = NSKeyedUnarchiver.unarchiveObject(with: user[6] as Data) as! String
        
            memory_user = User(_id: user_id, _username: username, _password: password, _email: email, token_id: token_id, _authdata: "", _emailVerified: true, _createdAt: createdAt, _updatedAt: updatedAt)
            
            if user.count > 7 {
             if let fa_session_id: String = NSKeyedUnarchiver.unarchiveObject(with: user[7] as Data) as? String {
             memory_user.fb_session_id = fa_session_id
             }
             if let fb_first_name: String = NSKeyedUnarchiver.unarchiveObject(with: user[8] as Data) as? String {
             memory_user.fb_first_name = fb_first_name
             }
             if let fb_last_name: String = NSKeyedUnarchiver.unarchiveObject(with: user[9] as Data) as? String {
             memory_user.fb_last_name = fb_last_name
             }
             if let fb_email: String = NSKeyedUnarchiver.unarchiveObject(with: user[10] as Data) as? String {
             memory_user.fb_email = fb_email
             }
             
             
             if let ingredients_dto: [IngredientDTO] = NSKeyedUnarchiver.unarchiveObject(with: user[11] as Data) as? [IngredientDTO]{
                for ingredient in ingredients_dto {
                    let ingredient_dto = Ingredient(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
                    memory_user.ingredients.append(ingredient_dto)
                }
             }
            }
            
            
            
        }
        
        return memory_user
        
    
    }
    
    func setEncodedUser(_ user :User) -> Void{
        
        let encodedId = NSKeyedArchiver.archivedData(withRootObject: user.user_id)
        let encodedUsername = NSKeyedArchiver.archivedData(withRootObject: user.username)
        let encodedPassword = NSKeyedArchiver.archivedData(withRootObject: user.password)
        let encodedEmail = NSKeyedArchiver.archivedData(withRootObject: user.email)
        let encodedToken = NSKeyedArchiver.archivedData(withRootObject: user.token_id)
        
        let encodedCreatedAt = NSKeyedArchiver.archivedData(withRootObject: user.createdAt)
        let encodedUpdatedAt = NSKeyedArchiver.archivedData(withRootObject: user.updatedAt)
        
        /*
         UPDATE MAY 23
        */
        
        let encoded_fa_session_id = NSKeyedArchiver.archivedData(withRootObject: user.fb_session_id)
        let encoded_fa_first_name = NSKeyedArchiver.archivedData(withRootObject: user.fb_first_name)
        let encoded_fa_last_name = NSKeyedArchiver.archivedData(withRootObject: user.fb_last_name)
        let encoded_fa_email = NSKeyedArchiver.archivedData(withRootObject: user.fb_email)
        
        
        var ingredients_dto = [IngredientDTO]()
        for ingredient in user.ingredients {
            let ingredient_dto = IngredientDTO(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
            ingredients_dto.append(ingredient_dto)
        }
        let encoded_ingredients = NSKeyedArchiver.archivedData(withRootObject: ingredients_dto)
        
        
        let encodedUser: [Data] =
            [
                encodedId,
                encodedUsername,
                encodedPassword,
                encodedEmail,
                encodedToken,
                encodedCreatedAt,
                encodedUpdatedAt,
                encoded_fa_session_id,
                encoded_fa_first_name,
                encoded_fa_last_name,
                encoded_fa_email,
                encoded_ingredients
            ]
        
        UserDefaults.standard.set(encodedUser, forKey: "user")
        UserDefaults.standard.synchronize()
    }

}
