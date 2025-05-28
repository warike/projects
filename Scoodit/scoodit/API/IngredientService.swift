//
//  IngredientService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Clarifai

class IngredientService: NSObject, IIngredientService {
    
    fileprivate var _ingredients : [Ingredient] = [Ingredient]()
    
    
    func getIngredientsFromClarifai(_ image: UIImage, completion: @escaping ((_ result : [String]) -> Void)) -> Void {
        
        let oldSize: CGSize = image.size
        
        let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        
        let resizeImg = UIImage(data: resizedImage! as Data)
        var results : [String ] = []
        
        let app = ClarifaiApp(appID: "<APP_ID>", appSecret: "<APP_SECRET>")
        
        app?.getModelByName("general-v1.3", completion: { (model, error) in
            let clarifaiImage = ClarifaiImage(image: resizeImg)
            model?.predict(on: [clarifaiImage!], completion: { (outputs, error) in
                
                if !(error != nil)
                {
                    let output : ClarifaiOutput = (outputs?.first)!
                    for c in output.concepts {
                        results.append(c.conceptName!)
                    }
                }
                
                completion(results)
            })
        })

    }
    
    
    func getIngredientsFromCloudVision(_ image: UIImage, completion: @escaping ((_ result : [String]) -> Void)) -> Void
    {

        let oldSize: CGSize = image.size
        
        let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        
        let resizeImg = UIImage(data: resizedImage! as Data)
        let data = UIImagePNGRepresentation(resizeImg!)?.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithCarriageReturn)
        
        
        
        let url = "https://vision.googleapis.com/v1/images:annotate?key=\(<API_KEY>)"
        let parameters = [ "requests": [ "image": [ "content": data! ], "features": [ [ "type": "LABEL_DETECTION", "maxResults": 5 ],[ "type": "TEXT_DETECTION", "maxResults": 5 ] ] ] ]
    
        var result : [String] = []
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let results = JSON(value)

                    if let labelsJSON = results["responses"][0]["labelAnnotations"].arrayObject {
                        let labels = labelsJSON as! [[String:AnyObject]]
                        
                        for label in labels {
                            let text = label["description"] as! String
                            result.append(text)
                        }
                        
                    }
                    
                    if let labelsJSON = results["responses"][0]["textAnnotations"].arrayObject {
                        let labels = labelsJSON as! [[String:AnyObject]]
                        
                        for label in labels {
                            let text = label["description"] as! String
                            result.append(text)
                        }
                        
                    }
                    
                }
                break
            case .failure:
                break
            }
            completion(result)
            
            
        
        }

    }

    func getIngredientsFromAPI(_ user_id : String, completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    {
            let params = ["user_id": user_id]
            let headers = ["Content-type" : "application/json"]
            var msg = "error request"
            var status = false
            let url  = "https://<API_URL>/ingredients"
            
            self._ingredients.removeAll()
            var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : self._ingredients as AnyObject, "message" : msg as AnyObject]
            
            Alamofire.request(url, parameters: params, headers: headers)
                .downloadProgress { progress in
                    let percentage = (String(format: "%.0f", progress.fractionCompleted * 100))
                    if percentage != "100" {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: all_ingredient_subscription), object: self, userInfo: ["percentage": percentage])
                    }
                    
                }
                .responseJSON { response in
                    self._ingredients.removeAll()
                    if let result = response.result.value {
                        let ingredientsJSON = JSON(result)
                        if let ings = ingredientsJSON["ingredients"].arrayObject {
                            let ingredientsDTO = ings as! [[String:AnyObject]]
                            
                            for item in ingredientsDTO {
                                let ingredientDTO = unpackIngredientFromAPI(data: item)
                                self._ingredients.append(ingredientDTO)
                            }
                        }
                        if (self._ingredients.isEmpty) {
                            msg = "We don't have any ingredient to show"
                        }else {
                            msg = "successful response"
                            status = true
                        }
                        
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: all_ingredient_subscription), object: self, userInfo: ["percentage": "100"])
                    resultAPI.removeAll()
                    resultAPI.updateValue(status as AnyObject, forKey: "status")
                    resultAPI.updateValue(self._ingredients as AnyObject, forKey: "data")
                    resultAPI.updateValue(msg as AnyObject, forKey: "message")
                    completion(resultAPI)
        }
    }


    
    func getUserIngredients(_ user_id :String, completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void{
        let params = ["user_id": user_id]
        let headers = ["Content-type" : "application/json"]
        var msg = "error request"
        var status = false
        let url  = "https://<API_URL>/useringredients"
        
        self._ingredients.removeAll()
        var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : self._ingredients as AnyObject, "message" : msg as AnyObject]
        
        Alamofire.request(url, parameters: params, headers: headers)
            .responseJSON { response in
                if let result = response.result.value {
                    let ingredientsJSON = JSON(result)  
                    if let ingredients = ingredientsJSON["result"]["ingredients"].arrayObject {
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
                            self._ingredients.append(ingredient_dto)
                        }
                    }
                    if (self._ingredients.isEmpty) {
                        msg = "You don't have any ingredient to show"
                    }else {
                        msg = "successful response"
                        status = true
                    }
                }
                
                resultAPI.updateValue(status as AnyObject, forKey: "status")
                resultAPI.updateValue(self._ingredients as AnyObject, forKey: "data")
                resultAPI.updateValue(msg as AnyObject, forKey: "message")
                completion(resultAPI)
                
        }
        
    }
    
    func addIngredient(_ user_id: String, ingredient_id: String, is_required: String? = "0", completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void{
        let params = ["user_id": user_id, "ingredient_id": ingredient_id, "is_required" : is_required!]
        let headers = ["Content-type" : "application/json"]
        var msg = "error request"
        var status : Bool = false
        let url  = "https://<API_URL>/useraddingredient"
        var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : self._ingredients as AnyObject, "message" : msg as AnyObject]
        
        Alamofire.request(url, parameters: params, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let result = JSON(value)
                        if let status_requested = result["result"]["status"].bool {
                            status = status_requested
                        } else {
                            status = false
                        }
                        if let message_requested = result["result"]["message"].string {
                            msg = message_requested
                        } else {
                            msg = "You don't have any ingredient to show"
                        }
                    }
                case .failure:
                    status = false
                    msg = "Error during the request, please try it later"
                }
                resultAPI.updateValue(status as AnyObject, forKey: "status")
                resultAPI.updateValue(self._ingredients as AnyObject, forKey: "data")
                resultAPI.updateValue(msg as AnyObject, forKey: "message")
                completion(resultAPI)
                
        }
        
    }
    
    func removeIngredient(_ user_id: String, ingredient_id: String, remove_option: RemoveOption = .removeOne, completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void{
        let params = ["user_id": user_id, "ingredient_id": ingredient_id, "remove_option" : remove_option.rawValue]
        let headers = ["Content-type" : "application/json"]
        var msg = "error request"
        var status : Bool = false
        let url  = "https://<API_URL>/userdeleteingredient"
        
        self._ingredients.removeAll()
        var resultAPI : [String : AnyObject] = ["status" : status as AnyObject, "data" : self._ingredients as AnyObject, "message" : msg as AnyObject]
        
        Alamofire.request(url, parameters: params, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let result = JSON(value)
                        if let status_requested = result["result"]["status"].bool {
                            status = status_requested
                            if let ingredients = result["result"]["data"].arrayObject {
                                let ingredientsDTO = ingredients as! [[String:AnyObject]]
                                for item in ingredientsDTO {
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

                                    self._ingredients.append(ingredient_dto)
                                }
                            }
                        } else {
                            status = false
                        }
                        if let message_requested = result["result"]["message"].string {
                            msg = message_requested
                        } else {
                            msg = "You don't have any ingredient to show"
                        }
                    }
                case .failure:
                     status = false
                     msg = "Error during the request, please try it later"
                }
                
                resultAPI.updateValue(status as AnyObject, forKey: "status")
                resultAPI.updateValue(self._ingredients as AnyObject, forKey: "data")
                resultAPI.updateValue(msg as AnyObject, forKey: "message")
                completion(resultAPI)
        }
    }
    
    func setEncodedIngredients(_ ingredients : [Ingredient]) -> Void{
        if ingredients.count > 0{
            var ingredients_dto = [IngredientDTO]()
            for ingredient in ingredients {
                let ingredient_dto = IngredientDTO(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
                ingredients_dto.append(ingredient_dto)
            }
            
            let encoded_ingredients = NSKeyedArchiver.archivedData(withRootObject: ingredients_dto)
            let encoded_data: [Data] = [ encoded_ingredients ]
            
            UserDefaults.standard.set(encoded_data, forKey: "all_ingredients")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func getIngredientsFromMemory() -> [Ingredient]? {
        
        let cached_ingredients = UserDefaults.standard.object(forKey: "all_ingredients")
        var memory_ingredients : [Ingredient] = []
        
        if( cached_ingredients != nil){
            var ingredients: [Data] = cached_ingredients as! [Data]
            if ingredients.count > 0
            {
                if let ingredients_dto: [IngredientDTO] = NSKeyedUnarchiver.unarchiveObject(with: ingredients[0] as Data) as? [IngredientDTO]{
                    
                    for ingredient in ingredients_dto {
                        let ingredient_dto = Ingredient(_ID: ingredient._ID, text: ingredient.text, imageUrl: ingredient.imageUrl, pluralName: ingredient.pluralName, status: ingredient.status, synonym: ingredient.synonym, synonymPlural: ingredient.synonymPlural, categories: ingredient.categories, nv: ingredient.nv, dv: ingredient.dv, metric: ingredient.metric, isRequired: ingredient.isRequired, isAvailable: ingredient.isAvailable, quantity: ingredient.quantity, tempImg: ingredient.tempImg)
                        memory_ingredients.append(ingredient_dto)
                    }
                }
            }
        }
        return memory_ingredients
    }
    
    func getIngredientsCount() -> Int{
        return self._ingredients.count
    }
    
    func getIngredient(_ index: Int) -> Ingredient {
        return self._ingredients[index]
    }
    
    func deleteIngredients(){
        self._ingredients.removeAll()
    }
    
    
    
}
