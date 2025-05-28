//
//  Ingredient.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

struct Ingredient {
    // Entity variables
    
    // _ID: ObjectID
    // text: Name of the ingredient
    // imageUrl: Url of the Image of the ingredient
    // pluralName: Plural name as reference
    // status: status of the ingredient
    // synonym: synonyms of the ingredient's name
    // synonymPlural: synonyms of the ingredient's plural name
    
    var _ID : String
    var text : String
    var imageUrl: String
    var pluralName: String
    var status : Bool
    var synonym: [String]
    var synonymPlural: [String]
    
    // categories: name of the ingredient's categories
    // nv: number of NV
    // dv: number of DV
    
    var categories : [String]
    var nv : [String]
    var dv : [String]
    
    var metric: String
    var isRequired : Bool
    var isAvailable : Bool
    var quantity :String
    var tempImg: Data
}

extension Ingredient {
    class Coding: NSObject, NSCoding {
        let ingredient: Ingredient?
        
        init(ingredient: Ingredient){
            self.ingredient = ingredient
            super.init()
        }
        
        required init?(coder decoder: NSCoder) {
            guard let _ID = decoder.decodeObject(forKey: "_ID") as? String,
                let text = decoder.decodeObject(forKey: "text") as? String,
                let pluralName = decoder.decodeObject(forKey: "pluralName") as? String,
                let imageUrl = decoder.decodeObject(forKey: "imageUrl") as? String
            else {
                return nil
            }
            
            guard let categories = decoder.decodeObject(forKey: "categories") as? [String],
                let dv = decoder.decodeObject(forKey: "dv") as? [String],
                let nv = decoder.decodeObject(forKey: "nv") as? [String],
                let synonym = decoder.decodeObject(forKey: "synonym") as? [String],
                let synonymPlural = decoder.decodeObject(forKey: "synonymPlural") as? [String]
                else {
                    return nil
            }
            
            let status = decoder.decodeBool(forKey: "status")
            let isRequired = decoder.decodeBool(forKey: "isRequired")
            let isAvailable = decoder.decodeBool(forKey: "isAvailable")
            
            
            guard let tempImg = decoder.decodeObject(forKey: "tempImg") as? Data,
                let quantity = decoder.decodeObject(forKey: "quantity") as? String,
                let metric = decoder.decodeObject(forKey: "metric") as? String
                else {
                    return nil
            }
            ingredient = Ingredient(_ID: _ID, text: text, imageUrl: imageUrl, pluralName: pluralName, status: status, synonym: synonym, synonymPlural: synonymPlural, categories: categories, nv: nv, dv: dv, metric: metric, isRequired: isRequired, isAvailable: isAvailable, quantity: quantity, tempImg: tempImg)
            
            super.init()
        }
        
        public func encode(with coder: NSCoder) {
            guard let ingredient = ingredient else {
                return
            }
            
            
             coder.encode(ingredient._ID, forKey: "_ID")
             coder.encode(ingredient.text, forKey: "text")
             coder.encode(ingredient.pluralName, forKey: "pluralName")
             coder.encode(ingredient.imageUrl, forKey: "imageUrl")
             coder.encode(ingredient.status, forKey: "status")
             
             coder.encode(ingredient.categories, forKey: "categories")
             coder.encode(ingredient.nv, forKey: "nv")
             coder.encode(ingredient.dv, forKey: "dv")
             coder.encode(ingredient.synonym, forKey: "synonym")
             coder.encode(ingredient.synonymPlural, forKey: "synonymPlural")
             
             coder.encode(ingredient.isRequired, forKey: "isRequired")
             coder.encode(ingredient.isAvailable, forKey: "isAvailable")
             coder.encode(ingredient.tempImg, forKey: "tempImg")
             coder.encode(ingredient.quantity, forKey: "quantity")
             coder.encode(ingredient.metric, forKey: "metric")
            
        }
    }

}
extension Ingredient: Encodable {
    var encoded: Decodable? {
        return Ingredient.Coding(ingredient: self)
    }
}

extension Ingredient.Coding: Decodable {
    var decoded: Encodable? {
        return self.ingredient
    }
}

protocol Encodable {
    var encoded: Decodable? { get }
}
protocol Decodable {
    var decoded: Encodable? { get }
}

extension Sequence where Iterator.Element: Encodable {
    var encoded: [Decodable] {
        return self.filter({ $0.encoded != nil }).map({ $0.encoded! })
    }
}
extension Sequence where Iterator.Element: Decodable {
    var decoded: [Encodable] {
        return self.filter({ $0.decoded != nil }).map({ $0.decoded! })
    }
}


class IngredientDTO: NSObject {
    
    var _ID : String
    var text : String
    var imageUrl: String
    var pluralName: String
    var status : Bool
    var synonym: [String]
    var synonymPlural: [String]
    
    
    var categories : [String]
    var nv : [String]
    var dv : [String]
    
    var metric: String
    var isRequired : Bool
    var isAvailable : Bool
    var quantity :String
    var tempImg: Data
    
    
    init(_ID: String, text: String, imageUrl: String, pluralName: String, status: Bool, synonym: [String], synonymPlural: [String], categories: [String], nv: [String], dv: [String], metric: String, isRequired: Bool, isAvailable: Bool, quantity: String, tempImg: Data)
    {
        self._ID = _ID
        self.text = text
        self.pluralName = pluralName
        self.imageUrl = imageUrl
        self.status = status
        
        self.synonym = synonym
        self.synonymPlural = synonymPlural
        self.categories = categories
        self.dv = dv
        self.nv = nv
        
        self.metric = metric
        self.isRequired = isRequired
        self.isAvailable = isAvailable
        self.tempImg = tempImg
        self.quantity = quantity
        
        
        
    }
    
    func initWithCoder(_ decoder: NSCoder) -> IngredientDTO {
        
        self._ID = decoder.decodeObject(forKey: "_ID") as! String
        self.text = decoder.decodeObject(forKey: "text") as! String
        self.pluralName = decoder.decodeObject(forKey: "pluralName") as! String
        self.imageUrl = decoder.decodeObject(forKey: "imageUrl") as! String
        self.status = decoder.decodeBool(forKey: "status")
        
        
        self.categories = decoder.decodeObject(forKey: "categories") as! [String]
        self.dv = decoder.decodeObject(forKey: "dv") as! [String]
        self.nv = decoder.decodeObject(forKey: "nv") as! [String]
        self.synonym = decoder.decodeObject(forKey: "synonym") as! [String]
        self.synonymPlural = decoder.decodeObject(forKey: "synonymPlural") as! [String]
        
        self.isRequired = decoder.decodeBool(forKey: "isRequired")
        self.isAvailable = decoder.decodeBool(forKey: "isAvailable")
        
        
        self.tempImg = decoder.decodeObject(forKey: "tempImg") as! Data
        self.quantity = decoder.decodeObject(forKey: "quantity") as! String
        self.metric = decoder.decodeObject(forKey: "metric") as! String
        
        return self
    }
    
    
    func encodeWithCoder(_ coder: NSCoder!) {
        
        coder.encode(self._ID, forKey: "_ID")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.pluralName, forKey: "pluralName")
        coder.encode(self.imageUrl, forKey: "imageUrl")
        coder.encode(self.status, forKey: "status")
        
        coder.encode(self.categories, forKey: "categories")
        coder.encode(self.nv, forKey: "nv")
        coder.encode(self.dv, forKey: "dv")
        coder.encode(self.synonym, forKey: "synonym")
        coder.encode(self.synonymPlural, forKey: "synonymPlural")
        
        coder.encode(self.isRequired, forKey: "isRequired")
        coder.encode(self.isAvailable, forKey: "isAvailable")
        coder.encode(self.tempImg, forKey: "tempImg")
        coder.encode(self.quantity, forKey: "quantity")
        coder.encode(self.metric, forKey: "metric")
        
    }

}
