//
//  User.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var user_id : String
    var username : String
    var password : String
    var email : String
    var token_id : String
    
    var emailVerified :Bool
    var createdAt : String
    var updatedAt : String
    
    var householdsize : Int = 2
    var metricSystem : MentricOption = MentricOption.System
    
    /*
     UPDATE  MAY 20 - SOCIAL INTEGRATION
     */
    
    var authData : String
    
    // Facebook
    var fb_first_name : String
    var fb_last_name : String
    var fb_session_id : String
    var fb_email : String
    
    // Twitter
    var tw_username : String
    var tw_session_id : String
    var tw_authtoken : String
    var tw_authtokenSecret : String
    
    var ingredients: [Ingredient] = []
    
    // favorite recipes
    var favorite_recipes: [Recipe] = []
     
    
    override init (){
        
        self.user_id = String()
        self.username = String()
        self.password = String()
        self.email = String()
        self.authData = String()
        self.emailVerified = false
        self.createdAt = String()
        self.updatedAt = String()
        self.token_id = String()
        
        self.fb_email = String()
        self.fb_first_name = String()
        self.fb_last_name = String()
        self.fb_session_id = String()
        
        self.tw_username = String()
        self.tw_session_id = String()
        self.tw_authtoken = String()
        self.tw_authtokenSecret = String()
        
        
        self.ingredients = []
        self.ingredients = []
        
    }
    
    
    init(_fb_first_name: String, _fb_last_name: String, _fb_session_id: String,_fb_email: String)
    {
        self.user_id = String()
        self.username = String()
        self.password = String()
        self.email = String()
        self.authData = String()
        self.emailVerified = false
        self.createdAt = String()
        self.updatedAt = String()
        self.token_id = String()
        
        self.fb_first_name = _fb_first_name
        self.fb_last_name = _fb_last_name
        self.fb_email = String()
        self.fb_session_id = _fb_session_id
        
        self.tw_username = String()
        self.tw_session_id = String()
        self.tw_authtoken = String()
        self.tw_authtokenSecret = String()
        
        self.ingredients = []
    }
    
    init(_tw_session_id: String, _tw_auth_token: String, _tw_authtokenSecret: String, _tw_username: String)
    {
        self.user_id = String()
        self.username = String()
        self.password = String()
        self.email = String()
        self.authData = String()
        self.emailVerified = false
        self.createdAt = String()
        self.updatedAt = String()
        self.token_id = String()
        
        self.fb_first_name = String()
        self.fb_last_name = String()
        self.fb_email = String()
        self.fb_session_id = String()
        
        self.tw_username = _tw_username
        self.tw_session_id = _tw_session_id
        self.tw_authtoken = _tw_auth_token
        self.tw_authtokenSecret = _tw_authtokenSecret
        
        self.ingredients = []
    }
    
    init (username: String, password:String){
        self.user_id = username
        self.username = password
        self.password = String()
        self.email = String()
        self.authData = String()
        self.emailVerified = false
        self.createdAt = String()
        self.updatedAt = String()
        self.token_id = String()
        
        self.fb_email = String()
        self.fb_first_name = String()
        self.fb_last_name = String()
        self.fb_session_id = String()
        
        self.tw_username = String()
        self.tw_session_id = String()
        self.tw_authtoken = String()
        self.tw_authtokenSecret = String()
        
        self.ingredients = []
        
        
    }
    
    init(_id :String, _username :String, _password :String, _email :String, token_id: String, _authdata: String, _emailVerified :Bool, _createdAt :String, _updatedAt :String){
    
        self.user_id = _id
        self.username = _username
        self.password = _password
        self.email = _email
        self.token_id = token_id
        self.authData = _authdata
        self.emailVerified = _emailVerified
        self.createdAt = _createdAt
        self.updatedAt = _updatedAt
        
        self.fb_email = String()
        self.fb_first_name = String()
        self.fb_last_name = String()
        self.fb_session_id = String()
        
        self.tw_username = String()
        self.tw_session_id = String()
        self.tw_authtoken = String()
        self.tw_authtokenSecret = String()
        
        self.ingredients = []
        
        
    }
    
    
    func encodeWithCoder(_ coder: NSCoder!) {
        
        coder.encode(self.user_id, forKey: "user_id")
        coder.encode(self.username, forKey: "username")
        coder.encode(self.password, forKey: "password")
        coder.encode(self.email, forKey: "email")
        coder.encode(self.token_id, forKey: "token_id")
        
        coder.encode(self.createdAt, forKey: "createdAt")
        coder.encode(self.updatedAt, forKey: "updatedAt")
        
        coder.encode(self.fb_session_id, forKey: "fb_session_id")
        coder.encode(self.fb_email, forKey: "fb_email")
        coder.encode(self.fb_last_name, forKey: "fb_last_name")
        coder.encode(self.fb_first_name, forKey: "fb_first_name")
        
        
        coder.encode(self.householdsize, forKey: "householdsize")
        coder.encode(self.metricSystem, forKey: "metricSystem")
        
        coder.encode(self.ingredients, forKey: "ingredients")
    }
    
    func initWithCoder(_ decoder: NSCoder) -> User {
        
        self.user_id = decoder.decodeObject(forKey: "user_id") as! String
        self.username = decoder.decodeObject(forKey: "username") as! String
        self.password = decoder.decodeObject(forKey: "password") as! String
        self.email = decoder.decodeObject(forKey: "email") as! String
        self.token_id = decoder.decodeObject(forKey: "token_id") as! String
        
        self.createdAt = decoder.decodeObject(forKey: "createdAt") as! String
        self.updatedAt = decoder.decodeObject(forKey: "updatedAt") as! String
        
        self.fb_session_id = decoder.decodeObject(forKey: "fb_session_id") as! String
        self.fb_email = decoder.decodeObject(forKey: "fb_email") as! String
        self.fb_session_id = decoder.decodeObject(forKey: "fb_session_id") as! String
        self.fb_email = decoder.decodeObject(forKey: "fb_email") as! String
        
        self.householdsize = decoder.decodeObject(forKey: "householdsize") as! Int
        self.metricSystem = decoder.decodeObject(forKey: "metricSystem") as! MentricOption
        
        self.ingredients = decoder.decodeObject(forKey: "ingredients") as! [Ingredient]
        
        return self
    }

}
