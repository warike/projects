//
//  IUserService.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

protocol IUserService {
    
    func loginUser(_ username: String, password: String, completion:@escaping ((_ result :[String : AnyObject])->Void)) -> Void
    func loginFbUser(_ fb_email: String,  fb_first_name: String, fb_last_name: String,fb_session_id: String, fb_completion: @escaping ((_ result :[String : AnyObject])->Void)) -> Void
    func setEncodedUser(_ user :User) -> Void
    func getUserFromMemory() -> User?

}
