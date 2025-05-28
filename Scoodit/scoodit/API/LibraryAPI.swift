////
//  LibraryAPI.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import Firebase
import Toaster




class LibraryAPI: NSObject, MessageProtocol {
    
    fileprivate var _recipeService : IRecipeService
    fileprivate var _ingredientService : IIngredientService
    fileprivate var _userService : IUserService
    fileprivate var _missingIngredients: [Ingredient]
    fileprivate var _favoriteRecipes: [Recipe]
    
    fileprivate var ingredientsHaveChanged = true
    fileprivate var _suggestedRecipes: [Recipe] = []
    /*
     ENTITIES
     */
    fileprivate var _userEntity : User
    fileprivate var _allIngredients : [Ingredient] {
        didSet {
            self.onIngredientsPropertiesChanged()
            
        }
    }
    
    fileprivate var _deviceToken : String
    
    class var sharedInstance : LibraryAPI{
        struct Singleton {
            
            static let instance  = LibraryAPI(
                recipeService: RecipeService(),
                ingredientService: IngredientService(),
                userService : UserService(),
                user: User(),
                location: Location(),
                deviceToken: String("")
            )
        }
        return Singleton.instance
    }
    
    init(
        recipeService: IRecipeService,
        ingredientService: IIngredientService,
        userService : IUserService,
        user: User,
        location: Location,
        deviceToken: String
        )
    {
        
        
        self._recipeService = recipeService
        self._ingredientService = ingredientService
        self._userService = userService
        
        self._userEntity = user
        self._deviceToken = deviceToken
        self._missingIngredients = []
        self._favoriteRecipes = []

        self._allIngredients = []
        
        super.init()
  
    }
    
    func setMetricSystem(from metric: MentricOption){
        self._userEntity.metricSystem = metric
        self.syncUserInMemory()
        
    }
    
    func getMetricSystem()-> MentricOption{
        let metric : MentricOption = self._userEntity.metricSystem
        return metric
    }
    
    func setSuggestedRecipes(recipes: [Recipe])-> Void{
        self._suggestedRecipes.removeAll()
        self._suggestedRecipes = recipes
    }
    
    func ingredientsHaveChangedState(state: Bool)
    {
        self.ingredientsHaveChanged = state
    }
    
    func getIngredientsHaveChangedState() -> Bool
    {
        return self.ingredientsHaveChanged
    }
    
    func getDeviceToken() -> String
    {
        return self._deviceToken
    }
    
    func updateHouseHold( number: Int) -> Void{
        let user = self.getUserEntity()
        user.householdsize = number
        self.syncUserInMemory()
    }
    
    func validateSelectedIngredient(_ ingredientID: String) -> Bool{
        var result = false
        self._userEntity.ingredients.forEach { (i) in
            if i._ID == ingredientID {
                result = true
                return
            }
        }

        return result
    }
    
    func existUserInMemoryCompletion(_ completion: @escaping ((_ result : Bool)->Void))
    {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            let resultUser = (user != nil) ? true : false
            completion(resultUser)
        }
    
    }
    
    func existUserInMemory() -> Bool
    {
        let fireBaseUser = FIRAuth.auth()?.currentUser
        return fireBaseUser == nil ? false : true
    }
    
    func existIngredientsInMemory() -> Bool
    {
        let cached_ingredients = UserDefaults.standard.object(forKey: "all_ingredients")
        return ( cached_ingredients == nil) ? false : true
    }
    
    func getAllIngredient() -> Void
    {
        self.getAllIngredient({ (_result) in
            
            let ingredientsDTO = _result["data"] as! [Ingredient]
            if ingredientsDTO.count > 0 {
                self.setAPIIngredients(ingredientsDTO)
                NotificationCenter.default.post(name: Notification.Name(rawValue: all_ingredient_subscription), object: self, userInfo: ["percentage": "100"])
                
            }
        })
    
    }
    
    private func syncUserInMemory()
    {
        self._userService.setEncodedUser(self._userEntity)
    }
    
    private func getUserFromMemory()
    {
        let user_memory = self._userService.getUserFromMemory()
        let favorite_recipes_memory = self._recipeService.getFavoriteRecipesInMemory((user_memory?.user_id)!)
        self.updateFavoriteRecipes(recipes: favorite_recipes_memory)
        self.setUserEntity(user_memory!)
    }
    
    
    private func loadIngredientsInMemory()
    {
        let memory_ingredients = self._ingredientService.getIngredientsFromMemory()
        if(memory_ingredients!.count > 0 ){
            self.setAPIIngredients(memory_ingredients!)
        }else {
            self.getAllIngredient({ (_result) in
                
                let ingredientsDTO = _result["data"] as! [Ingredient]
                if ingredientsDTO.count > 0 {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: all_ingredient_subscription), object: self, userInfo: ["percentage": "100"])
                    self.setAPIIngredients(ingredientsDTO)
                    
                    
                }
            })
        }
    }
    
    func updateIngredientsFromAPI()
    {
        self.getAllIngredient({ (_result) in
            
            let ingredientsDTO = _result["data"] as! [Ingredient]
            if ingredientsDTO.count > 0 {
                self.setAPIIngredients(ingredientsDTO)
                
                // In case to be necessary we can present this message to the user
                // telling him that the inventory's up-to-date.
                
                // self.presentMessage(message: ingredientsUpdated)
            }
        })
    
    
    }
    
    func initLoading() -> Void
    {
        
        
        if !self.existIngredientsInMemory() {
            try! FIRAuth.auth()!.signOut()
            self.getAllIngredient()
        }
        else
        {
            self.loadIngredientsInMemory()
            self.getUserFromMemory()
            self.updateIngredientsFromAPI()
        }

    }
    
    
    
    func getUserIngredients() -> [Ingredient]
    {
        return self._userEntity.ingredients
    }
    
    func setUserIngredients(_ ingredient_list: [Ingredient]) -> Void
    {
        self._userEntity.ingredients = ingredient_list
    }
    
    func getAPIIngredients(filtered: Bool = true) -> [Ingredient]
    {
        let result = (filtered) ? self._allIngredients.filter { $0.status == true} : self._allIngredients
        return result
    }
    
    func setAPIIngredients(_ ingredient_list: [Ingredient]) -> Void
    {
        self._allIngredients = ingredient_list
    }
    
    
    /**
     FAVORITE RECIPES
     1. Add Recipe to the list of favorite recipes
     2. Remove recipe from the list of favorite recipes using the index
     3. Remove recipe from the list of favorite recipes using the recipe object
     4. Update the list of favorite recipes
    **/
 
    
    func addRecipe(toFavorites recipe: Recipe )-> Void
    {
        if !self.existInFavorites(recipe: recipe) {
            self._favoriteRecipes.append(recipe)
            self.syncFavoriteRecipesInMemory()
        }
    
    }
    
    func removeFavoriteRecipe(from index: Int )-> Void
    {
        self._favoriteRecipes.remove(at: index)
        self.syncFavoriteRecipesInMemory()
        
        
    }
    
    func removeRecipe(fromFavorites recipe: Recipe )-> Void
    {
    
        var index = 0
        for r in self._favoriteRecipes {
            if r._ID == recipe._ID {
                self._favoriteRecipes.remove(at: index)
                self.syncFavoriteRecipesInMemory()
                break
            }
            index = index + 1
        }
        
    }
    
    
    func updateFavoriteRecipes(recipes: [Recipe]) -> Void
    {
        self._favoriteRecipes = recipes
    }
    
    func getFavoriteRecipes() -> [Recipe]
    {
        return self._favoriteRecipes
    }
    
    func existInFavorites(recipe: Recipe) -> Bool
    {
        let exist = (self._favoriteRecipes.filter({ $0._ID == recipe._ID}).count > 0)
        return exist
        
    }
    
    func syncFavoriteRecipesInMemory() -> Void {
        self._recipeService.saveFavoriteRecipesInMemory(self._favoriteRecipes)
    }
    
    
    func addMissingIngredient(_ ingredient: Ingredient) -> Void {
        var flag = false
        var k = 0
        for i in self._missingIngredients {
            if i._ID == ingredient._ID {
                let q = Double(self._missingIngredients[k].quantity)! + Double(ingredient.quantity)!
                self._missingIngredients[k].quantity = String(q)
                flag = true
                break
            }
            k = k + 1
        }
        
        if !flag {
            self._missingIngredients.append(ingredient)
        }
        
        
    }
    func updateMissingIngredients(ingredients: [Ingredient]) -> Void
    {
        self._missingIngredients = ingredients
    }
    
    func getMissingIngredients() -> [Ingredient]
    {
        return self._missingIngredients
    }
    
    func setDeviceToken(_ device_id: Data) -> Void
    {
        
        var tokenLimpio = NSString(format: "%@", device_id as CVarArg)
        tokenLimpio = tokenLimpio.replacingOccurrences(of: " ", with: "") as NSString
        tokenLimpio = tokenLimpio.replacingOccurrences(of: ">", with: "") as NSString
        tokenLimpio = tokenLimpio.replacingOccurrences(of: "<", with: "") as NSString
        
        self._deviceToken = tokenLimpio as String
    }
    
    func getMissingIngredients(from recipe: Recipe) -> Int{
        
        let recipe_array = recipe.ingredients.map{$0._ID}
        let recipe_set = Set(recipe_array)
        
        let user_array = self.getUserIngredients().map{$0._ID}
        let user_set = Set(user_array)
        
        let missing_ones1 = Array(user_set.intersection(recipe_set)).count

        let total_missing = recipe.ingredients.count - missing_ones1
        return total_missing
    }

    
    func getUserRecipes()
    {
        var user_id = ""
        
        if let user = FIRAuth.auth()?.currentUser {
            user_id = user.uid
        }
        self._recipeService.getUserRecipes(user_id)
    }
    
    func getAllIngredient(_ completion: @escaping ((_ result :[String : AnyObject])->Void))
    {
        self._ingredientService.getIngredientsFromAPI(self._userEntity.user_id, completion: completion)
    }
    
    func getUserIngredient(_ completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    {
        self._ingredientService.getUserIngredients(self._userEntity.user_id,completion: completion)
        
    }
    
    
    private func removeIngredientInRuntimeMemory(ing: Ingredient)
    {
        if ing._ID != "" {
            var k : Int = 0
            for i in self._userEntity.ingredients{
                if i._ID == ing._ID {
                    self._userEntity.ingredients.remove(at: k)
                    self.ingredientsHaveChangedState(state: true)
                }
                k += 1
            }
        }
    
    
    }
    
    private func removeIngredientsInRuntimeMemory()
    {
        self._userEntity.ingredients.removeAll()
        self.ingredientsHaveChangedState(state: true)
    }
    
    func removeIngredient(_ ingredient: Ingredient?, remove_option : RemoveOption, completion: @escaping ((_ result :[String : AnyObject]) -> Void)) -> Void
    {
        switch remove_option
        {
            case .removeOne:
                self.removeIngredientInRuntimeMemory(ing: ingredient!)
                break
            case .removeAll:
                self.removeIngredientsInRuntimeMemory()
                break
        }
        
        self.syncUserInMemory()
        
    }
    
    private func updateIngredientInRuntimeMemory(i: Ingredient, is_required : Bool)
    {
        
        if is_required
        {
            for key in 0...(self._userEntity.ingredients.count-1){
                self._userEntity.ingredients[key].isRequired = false
                self.ingredientsHaveChangedState(state: true)
            }
        }
        
        var key = 0
        for ing in self._userEntity.ingredients
        {
            if i._ID == ing._ID {
                self._userEntity.ingredients[key].isRequired = is_required
            }
        key = key + 1
        }
        
        
    
    }
    
    func updateIngredient(_ ingredient: Ingredient, is_required: Bool, completion:@escaping ((_ result :[Ingredient])->Void)) -> Void
    {
        
        self.updateIngredientInRuntimeMemory(i: ingredient, is_required : is_required)
        self.syncUserInMemory()
        completion(self.getUserIngredients())
    
    }
    
    func addIngrdientInRuntimeMemory(i: Ingredient, is_required: Bool) -> Void
    {
        let exist = self._userEntity.ingredients.filter { $0._ID == i._ID }
        if exist.count == 0{
            self._userEntity.ingredients.append(i)
            self.ingredientsHaveChangedState(state: true)
        }
        
    }
    
    func addIngredient(_ ingredient: Ingredient, is_required: String? = "0", completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void
    {
        
        self.addIngrdientInRuntimeMemory(i: ingredient, is_required: is_required == "0" ? false: true)
        self.syncUserInMemory()

    }
    
    func loginUser(_ username: String, password: String, completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    {
        var status = false
        FIRAuth.auth()?.createUser(withEmail: username, password: password) { (user, errorSignUp) in
            if errorSignUp == nil {
                FIRAuth.auth()!.signIn(withEmail: username,
                                       password: password)
                
                let user = User()
                user.email = username
                user.password = password
                self.setUserEntity(user)
                self.syncUserInMemory()
                completion(["status" : true as AnyObject])
            }
            else
            {
                if let errCode = FIRAuthErrorCode(rawValue: errorSignUp!._code) {
                    if errCode == FIRAuthErrorCode.errorCodeEmailAlreadyInUse {
                        FIRAuth.auth()!.signIn(withEmail: username, password: password, completion: { (user, errorSignIn) in
                            if errorSignIn == nil {
                                let user = User()
                                user.email = username
                                user.password = password
                                self.setUserEntity(user)
                                status = true
                                completion(["status" : status as AnyObject])
                            }else
                            {
                                completion(["status" : status as AnyObject, "msg" : errorSignUp?.localizedDescription as AnyObject])
                            }
                            
                        })
                    }else
                    {
                        completion(["status" : false as AnyObject, "msg" : errorSignUp?.localizedDescription as AnyObject])
                    }
                }
                
                
            }
        }
        
    }
    
    
    func onIngredientsPropertiesChanged()
    {
        self._ingredientService.setEncodedIngredients(self._allIngredients)        
    }
    
    func getUserEntity() -> User
    {
        return self._userEntity
    }
    
    func setUserEntity(_ user : User)
    {
        self._userEntity = user
    }

    func getIngredientsFromClarifai(picture: UIImage, _ completion: @escaping ((_ result: [String])-> Void)) -> Void
    {
        
        self._ingredientService.getIngredientsFromClarifai(picture) { (result) in
            completion(result)
        }
    }
    
    func getIngredientsFromCloudVision(picture: UIImage, _ completion: @escaping ((_ result: [String])-> Void)) -> Void
    {
        
        self._ingredientService.getIngredientsFromCloudVision(picture) { (result) in
            completion(result)
        }
    }
    
    func logoutUser() -> Void {
        
        let appDomain = Bundle.main.bundleIdentifier!
        
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        
        if let loginManager: FBSDKLoginManager = FBSDKLoginManager(){
            loginManager.logOut()
        }
        
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
    }
    
    func loginFacebook(from view:UIViewController, _ completion: @escaping ((_ result: [String: AnyObject])-> Void)) -> Void
    {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        let resultAPI : [String : AnyObject] = ["status" : false as AnyObject, "message" : "Please check your facebook account and try it again" as AnyObject]
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: view){
            (fbResult, error) in
                if (error == nil)
                {
                    let fbloginresult : FBSDKLoginManagerLoginResult = fbResult!
                    if (fbloginresult.grantedPermissions) != nil
                    {
                        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        
                        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                                let user_entity = User()
                                if let username = user?.displayName {
                                    user_entity.username = username
                                }
                                if let email = user?.email {
                                    user_entity.email = email
                                }
                                self.setUserEntity(user_entity)
                                self.syncUserInMemory()
                                
                                view.performSegue(withIdentifier: "post_login", sender: self)
                            
                            //completion(resultAPI)
                        }

                    }
                    else
                    {
                        completion(resultAPI)
                    }
                }
                else if (fbResult?.isCancelled)! {
                    completion(resultAPI)
                }
                else
                {
                    completion(resultAPI)
                }
            }
        
    }
    
    func loginTwitter(_ completion: @escaping ((_ result: [String: AnyObject])-> Void)) -> Void
    {
        
        Twitter.sharedInstance().logIn { session, error in
            var resultAPI : [String : AnyObject] = ["status" : false as AnyObject, "message" : "Please check your twitter account and try it again" as AnyObject]
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    resultAPI.updateValue(true as AnyObject, forKey: "status")
                    resultAPI.updateValue("Great, login successful" as AnyObject, forKey: "message")
                    self.syncUserInMemory()
                    completion(resultAPI)
                }
                
            }
            
            
            
        }
        
    }
}
