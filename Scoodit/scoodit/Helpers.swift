//
//  Helpers.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/17/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import PMAlertController

let menuColor = UIColor.clear
let nonSelectedColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
let selectedColor = scoodit_color
let lightGrayColor = UIColor(red: 0.9686, green: 0.9686, blue: 0.9686, alpha: 1.0)

let menuFont = UIFont(name: "HelveticaNeue-Light", size:14) ?? UIFont.systemFont(ofSize: 14)

var <API_KEY> = "<API_KEY>"
let noMatchesMessage = "Couldn't match any ingredient."
let ingredientsUpdated = "Ingredients Updated"



let title_haveit_image = "title_haveit"
let title_delete_button = "Delete"
let ingredient_category_view = "IngredientCategoryView"
let ingredient_tableView_cell = "IngredientTableViewCell"
let default_image_ingredient = "default_image_ingredient"
let empty_string_value = String()


let cellIdentifier = "ingredientCell"
let missinIngredientCell = "missinIngredientCell"

let ingredientCategories = ["Vegetables","Fruits","Meat","Dairy","Seafood", "Poultry", "Fish", "Bakery","Spices & herbs","Condiments","Grains & cereals","Canned goods","Snacks","Beverages","Other"]

let itemList = ["Dietary preferences", "Favourite recipes", "Invite Friends", "Rate our app", "We love feedbacks", "About Scoodit"]

let options : [String] = [] //["About me", "Medical conds", "Alergies", "Type of Meal", "Dietary needs", "Type of cuisine", "Sport nutrition", "Logout"]

let servingOptions = ["1 Serving", "2 Serving", "3 Serving", "4 Serving", "5 Serving", "6 Serving", "7 Serving", "8 Serving", "9 Serving", "10 Serving","11 Serving","12 Serving", "13 Serving", "14 Serving", "15 Serving", "16 Serving", "17 Serving", "18 Serving", "19 Serving", "20 Serving","21 Serving","22 Serving", "23 Serving", "24 Serving", "25 Serving"]

let ingredientAlreadySelected = "hey! you've already added this ingredient."
let ingredientAddedToInventory = "Ingredient added"
let ingredientsAddedToInventory = "Ingredients added"


let favorite_recipe_cell_identifier = "favorite_recipe_cell"
let view_favorite_segue = "view_favorite_recipe"
let favorite_recipe_title = "Favorite Recipes"

let bar_button_item_image = "menu"
let bar_button_item_profile = "profile_0"
let bar_button_item_close = "close_icon"

let alert_sortbyaction_title = "Scoodit"
let action_cookingtime_title = "Cooking time"
let action_ningredient_title = "Numbers of Ingredients"
let action_cancel_title = "Cancel"


let reuseMainCollectionViewCellIdentifier = "MainCollectionViewCellIdentifier"
let reuseChildCollectionViewCellIdentifier = "ChildCollectionViewCellIdentifier"

let IngredientViewCollectionViewCellClass = "IngredientViewCollectionViewCell"
let addItBackground = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

let ingredientColorHaveIt = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
let deleteIngredientColorActionRow = UIColor(red:1.00, green:0.18, blue:0.18, alpha:1.0)
let backgroundContainer = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
let scoodit_color = UIColor(red:0.44, green:0.83, blue:0.22, alpha:1.0)
let yellowApp = UIColor(red:1.00, green:0.75, blue:0.01, alpha:1.0)
let scoodit_menu_color = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)

extension UIView{
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

func unpackParametersForRecommendations(data: [Ingredient], user_id: String) -> [String:String]
{
    let ingredientsIDs = data.map {return $0._ID }
    
    let serializedIDs = ingredientsIDs.enumerated().reduce("") {
        (wholeString: String, indexAndObj: (Int, String)) -> String in
        let maybeComma = (indexAndObj.0 == ingredientsIDs.count - 1) ? "" : ","
        return "\(wholeString)\(indexAndObj.1)\(maybeComma)"
    }
    
    let params : [String:String] = ["user_id": user_id, "ingredient_id": serializedIDs]
    return params
}


func unpackIngredientFromAPI(data: [String:AnyObject]) -> Ingredient {
    var i = Ingredient(_ID: "", text: "", imageUrl: "", pluralName: "", status: true, synonym: [], synonymPlural: [], categories: [], nv: [], dv: [], metric: "", isRequired: false, isAvailable: false, quantity: "", tempImg: Data())
    
    if let id = data["id"] as? String{
        i._ID = id
    }
    
    if let value = data["text"] as? String{
        i.text = value
    }

    if let value = data["imageUrl"] as? String{
        if value != ""{
            i.imageUrl = value.replacingOccurrences(of: " ", with: "%20")
        }
    }
    
    if let value = data["status"] as? Bool{
        i.status = value
    }
    
    if let value = data["pluralName"] as? String{
        i.pluralName = value
    }
    
    if let value = data["categories"] {
        let categoriesJSON = JSON(value)
        
        if let categories = categoriesJSON.arrayObject {
            
            if categories.count == 0 {
                i.categories.append("Other")
            }
            
            for item in categories {
                if var category = item as? String{
                    
                    if category != ""
                    {
                        i.categories.append(category)
                    }
                }
            }
        }
    }
    
    if let value = data["synonym"] {
        if let synonyms = value as? String{
            i.synonym = synonyms.characters.split{$0 == ","}.map(String.init)
        }
    }
    
    if let value = data["synonymPlural"] {
        if let synonymPlurals = value as? String{
            i.synonymPlural = synonymPlurals.characters.split{$0 == ","}.map(String.init)
        }
    }
    
    return i
}

func unpackIngredientFromRecipe(data: [String:AnyObject]) -> Ingredient {
    var i = Ingredient(_ID: "", text: "", imageUrl: "", pluralName: "", status: true, synonym: [], synonymPlural: [], categories: [], nv: [], dv: [], metric: "", isRequired: false, isAvailable: false, quantity: "", tempImg: Data())
    
    
    if let value = data["quantity"] as? String{
        i.quantity = value
    }
    
    if let value = data["metric"] as? String{
        i.metric = value
    }
    if let value = data["ingredient"] as? String{
        let matched_ingredient = LibraryAPI.sharedInstance.getAPIIngredients().filter { $0._ID == value }
        if matched_ingredient.count > 0 {
            if matched_ingredient.count == 1 {
                var m = matched_ingredient.first
                m?.quantity = i.quantity
                m?.metric = i.metric
                i = m!
                
                if LibraryAPI.sharedInstance.getUserIngredients().contains(where: {u in u._ID == i._ID }){
                    i.isAvailable = true
                }
            }
        }
    }
    
    
    return i
}

func unpackIngredientDTO(data: [String:AnyObject]) -> Ingredient?
{
    var ingredient_dto : Ingredient? = nil
    var quantity = "1"
    var metric = ""
    if let value = data["quantity"] as? String{
        quantity = value
    }
    
    if let value = data["metric"] as? String{
        metric = value
    }
    
    if let value = data["ingredient"] as? String{
        if !value.isEmpty {
            let matched_ingredient = LibraryAPI.sharedInstance.getAPIIngredients().filter { $0._ID == value }
            if matched_ingredient.count > 0 {
                if matched_ingredient.count == 1 {
                    
                    let m = matched_ingredient.first!
                    let available = LibraryAPI.sharedInstance.getUserIngredients().contains(where: {u in u._ID == value }) ? true : false
                    ingredient_dto = Ingredient(_ID: value, text: m.text, imageUrl: m.imageUrl, pluralName: m.pluralName, status: m.status, synonym: m.synonym, synonymPlural: m.synonymPlural, categories: m.categories, nv: m.nv, dv: m.dv, metric: metric, isRequired: m.isRequired, isAvailable: available, quantity: quantity, tempImg: m.tempImg)
                }
            }
        }
    }
    
    return ingredient_dto

}

func unpackRecipeFromAPI(data: [String:AnyObject]) -> Recipe
{
    let r = Recipe()

    if let value = data["id"] as? String{
        r._ID = value
    }
    
    if let value = data["title"] as? String{
        r.title = value
        print(value)
    }

    if let value = data["website"] as? String{
        r.website = value
    }
    
    if let value = data["imageUrl"] as? String{
        r.imageUrl = value
    }
    
    if let value = data["provider"] as? String{
        r.provider = value
    }
    
    if let value = data["sourceUrl"] as? String{
        r.sourceUrl = value
    }
    
    if let value = data["servingNumber"] as? String{
        r.servingNumber = value
    }
    
    if let value = data["servingNumber"] as? Int{
        r.servingNumber = String(value)
    }
    
    if let value = data["cookingTime"] as? String{
        r.cookingTime = value
    }
    
    if let value = data["status"] as? Bool{
        r.status = value
    }
    
    if let value = data["ingredients"] {
        let ingredientJSON = JSON(value)
        //var ingredientList :[Ingredient] = [Ingredient]()
        var ingredientDTO_list : [Ingredient] = []
        
        if let ingredients = ingredientJSON.arrayObject {
            let ingredientsDTO = ingredients as! [[String:AnyObject]]
            
            for item in ingredientsDTO {
                //let ingredient_model = unpackIngredientFromRecipe(data: item)
                let ingredient_dto = unpackIngredientDTO(data: item)
                if !(ingredient_dto?.text.isEmpty)! {
                    ingredientDTO_list.append(ingredient_dto!)
                }
            }
        }
        //r.ingredients = ingredientList
        r.ingredients = ingredientDTO_list
    }
    return r
}

enum RemoveOption: String {
    case removeOne = "1"
    case removeAll = "2"
}

enum ScooditTitle{
    case addIt
    case haveIt
    case snapIt
    case cookIt
    case eatIt
    case buyIt
}

enum MentricOption: Int {
    case US = 0
    case System = 1
    
    static func getMetric(from value: Int) -> MentricOption {
        if 0 ... 1 ~= value {
            switch value {
            case MentricOption.US.rawValue:
                return .US
            case MentricOption.System.rawValue:
                return .System
            default:
                break
            }
        }
        return MentricOption.System
    }
}

protocol IngredientHelper{
    func getOunces(from value: Float) -> Float
    func transform(from metric: String, to user_metric: MentricOption, value: String) -> Float
    
    func getMetric(from ingredient_metric:String, to user_metric: MentricOption) -> String
}
extension IngredientHelper{
    func getOunces(from value:Float) -> Float{
        let converted_value =  Float(value/28.3495231)
        
        return converted_value
    }
    
    func getMetric(from ingredient_metric:String, to user_metric: MentricOption) -> String {
        
        
        if ingredient_metric.lowercased() == "g" {
            return (user_metric == .US) ? "oz" : "g"
        }
        return ingredient_metric
    }
    
    func transform(from ingredient_metric: String, to user_metric: MentricOption, value: String) -> Float{
        var qty = 1.0 as Float
        let converted_quantity: Float
        if value != "" {
            
            if value == "1/2"
            {
                qty = Float(0.5)
            }
            else if value == "1/4"
            {
                qty = Float(0.25)
            }
            else if value == "2/4"
            {
                qty = Float(0.5)
            }
            else if value == "3/4"
            {
                qty = Float(0.75)
            }
            else if value == "1/3"
            {
                qty = Float(0.3)
            }
            else if value == "2/3"
            {
                qty = Float(0.6)
            }
            else
            {
                qty = Float(value)!
            }
        }
        
        if (ingredient_metric.lowercased() == "g"){
            converted_quantity =  (user_metric == .US) ? self.getOunces(from: qty) : qty
        }else{
            converted_quantity = qty
        }
        
        return converted_quantity
    }
}

protocol ScooditHelper{
    func getScooditTitleView(from title: ScooditTitle) -> UIImageView
    func getMissingNumberIngredients(from number: Int) -> String
    func getFloat(from text: String) ->  Float
    func getString(from number: Float) -> String
}

extension ScooditHelper{
    
    func getFloat(from text: String) ->  Float{
        return Float(text)!
    }
    
    func getString(from number: Float) -> String{
        return String(number)
    }
    
    func getMissingNumberIngredients(from number: Int) -> String{
        var text = ""
        text =  (number>0) ? "+ \(number) Ingredients" : "\u{1F31F} Perfect!"
        
        return text
    }
    
    func getScooditTitleView(from title: ScooditTitle) -> UIImageView
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        switch title {
        case .addIt:
            imageView.image = UIImage(named: "title_addit")
        case .haveIt:
            imageView.image = UIImage(named: "title_haveit")
        case .snapIt:
            imageView.image = UIImage(named: "title_snapit")
        case .cookIt:
            imageView.image = UIImage(named: "title_cookit")
        case .eatIt:
            imageView.image = UIImage(named: "title_eatit")
        case .buyIt:
            imageView.image = UIImage(named: "title_buyit")
        }
        
        return imageView
        
    }
}

protocol SortHelper {
    func sortByIngredientName(_ compare1: Ingredient, compare2: Ingredient) -> Bool
    func getSortedIngredientsByCategories(_ ingredients: [Ingredient]) -> ([[Ingredient]],[String])
}


extension SortHelper{
    func sortByIngredientName(_ compare1: Ingredient, compare2: Ingredient) -> Bool {
        return compare1.text.localizedCaseInsensitiveCompare(compare2.text) == ComparisonResult.orderedAscending
    }
    
    func getSortedIngredientsByCategories(_ ingredients: [Ingredient]) -> ([[Ingredient]],[String])
    {
        var vegetables = [Ingredient]()
        var fruits = [Ingredient]()
        var meat = [Ingredient]()
        var poultry = [Ingredient]()
        var dairy = [Ingredient]()
        var seafood = [Ingredient]()
        var fish = [Ingredient]()
        var bakery = [Ingredient]()
        var spices_herbs = [Ingredient]()
        var condiments = [Ingredient]()
        var grains_cereals = [Ingredient]()
        var canned_goods = [Ingredient]()
        var snacks = [Ingredient]()
        var beverages = [Ingredient]()
        var other = [Ingredient]()
        
        var ingredients_categorized = [[Ingredient]]()
        var categories_availables : [String] = []
        
        
        for i in ingredients {
            
            if i.categories.contains("Vegetables") {
                vegetables.append(i)
            }
            
            else if i.categories.contains("Fruits") {
                fruits.append(i)
            }
            
            else if i.categories.contains("Meat & Poultry") ||  i.categories.contains("Meat"){
                meat.append(i)
            }
            else if i.categories.contains("Poultry"){
                poultry.append(i)
            }
            else if i.categories.contains("Dairy") {
                dairy.append(i)
            }
            
            else if i.categories.contains("Fish & Seafood") ||  i.categories.contains("Fish"){
                fish.append(i)
            }
            else if i.categories.contains("Seafood"){
                seafood.append(i)
            }
            
            else if i.categories.contains("Bakery") {
                bakery.append(i)
            }
            
            else if i.categories.contains("Spices & herbs") {
                spices_herbs.append(i)
            }
            
            else if i.categories.contains("Condiments") {
                condiments.append(i)
            }
            
            else if i.categories.contains("Grains & Cereals") {
                grains_cereals.append(i)
            }
            
            else if i.categories.contains("Canned goods") {
                canned_goods.append(i)
            }
            
            else if i.categories.contains("Snacks") {
                snacks.append(i)
            }
            
            else if i.categories.contains("Drinks & Beverages") ||  i.categories.contains("Beverages") {
                beverages.append(i)
            }
            
            else if i.categories.contains("Other") {
                other.append(i)
            }
            
            else if i.categories.contains("") {
                other.append(i)
            }
            else{
                other.append(i)
            }
        }
        
        if vegetables.count > 0 {
            ingredients_categorized.append(vegetables.sorted(by: self.sortByIngredientName))
            categories_availables.append("Vegetables")
        }
        
        if fruits.count > 0 {
            ingredients_categorized.append(fruits.sorted(by: self.sortByIngredientName))
            categories_availables.append("Fruits")
        }
        
        if meat.count > 0 {
            ingredients_categorized.append(meat.sorted(by: self.sortByIngredientName))
            categories_availables.append("Meat")
        }
        if poultry.count > 0 {
            ingredients_categorized.append(poultry.sorted(by: self.sortByIngredientName))
            categories_availables.append("Poultry")
        }
        
        if seafood.count > 0 {
            ingredients_categorized.append(seafood.sorted(by: self.sortByIngredientName))
            categories_availables.append("Fish")
        }
        
        if fish.count > 0 {
            ingredients_categorized.append(fish.sorted(by: self.sortByIngredientName))
            categories_availables.append("Fish")
        }
        
        if dairy.count > 0 {
            ingredients_categorized.append(dairy.sorted(by: self.sortByIngredientName))
            categories_availables.append("Dairy")
        }
        
        if canned_goods.count > 0 {
            ingredients_categorized.append(canned_goods.sorted(by: self.sortByIngredientName))
            categories_availables.append("Canned goods")
        }
        
        if grains_cereals.count > 0 {
            ingredients_categorized.append(grains_cereals.sorted(by: self.sortByIngredientName))
            categories_availables.append("Grains & cereals")
        }
        
        if bakery.count > 0 {
            ingredients_categorized.append(bakery.sorted(by: self.sortByIngredientName))
            categories_availables.append("Bakery")
        }
        
        if condiments.count > 0 {
            ingredients_categorized.append(condiments.sorted(by: self.sortByIngredientName))
            categories_availables.append("Condiments")
        }
        
        
        if spices_herbs.count > 0 {
            ingredients_categorized.append(spices_herbs.sorted(by: self.sortByIngredientName))
            categories_availables.append("Spices & herbs")
        }
        
        if beverages.count > 0 {
            ingredients_categorized.append(beverages.sorted(by: self.sortByIngredientName))
            categories_availables.append("Drinks & Beverages")
        }
        
        
        if snacks.count > 0 {
            ingredients_categorized.append(snacks.sorted(by: self.sortByIngredientName))
            categories_availables.append("Snacks")
        }
        
        
        if other.count > 0 {
            ingredients_categorized.append(other.sorted(by: self.sortByIngredientName))
            categories_availables.append("Other")
        }
        
        return (ingredients_categorized, categories_availables)
    }
}

protocol MessageProtocol {
    func presentMessage(message: String)
    func notificateStatus(title: String, message: String, target: UIViewController)
}
extension MessageProtocol {
    func presentMessage(message: String)
    {
        if let currentToast = ToastCenter.default.currentToast {
            currentToast.cancel()
        }
        let toast = Toast(text: message, delay: 0.0, duration: 1.0)
        toast.show()
    }
    
    func notificateStatus(title: String, message: String, target: UIViewController)
    {
        let alertVC = PMAlertController(title: title, description: message, image: UIImage(named: ""), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
        }))
        
        target.present(alertVC, animated: true, completion: nil)
        
    }
}

extension UIImageView {
    
    public func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                if let imageData = data as Data? {
                    self.image = UIImage(data: imageData)   
                }
            }.resume()
           
        }
    }
    
    public func getAndSaveFromUrl(_ urlString: String, completion: @escaping ((_ result : Data)->Void)) {
        if let url = URL(string: urlString) {
            
            
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                if let imageData = data as Data? {
                    self.image = UIImage(data: imageData)
                    completion(imageData)
                }
            }.resume()
        }
    }
}

extension UIView
{
    func removeAllSubViews()
    {
        for subView :AnyObject in self.subviews
        {
            subView.removeFromSuperview()
        }
    }
    
}

