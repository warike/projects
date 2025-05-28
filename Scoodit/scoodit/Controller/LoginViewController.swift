//
//  LoginViewController.swift
//  scoodit
//
//  Created by RWBook Retina on 1/22/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import PMAlertController

let all_ingredient_subscription = "ingredient_progress_download"
let textfield_username_icon = "textfield_username_icon"
let textfield_password_icon = "textfield_password_icon"

class LoginViewController: UIViewController, MessageProtocol{
    
    @IBOutlet var twitterBtn: UIButton!
    @IBOutlet var facebookBtn: UIButton!
    @IBOutlet var signupBtn: UIButton!

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBarBackgroundView.backgroundColor = .clear
        statusBarBackgroundView.tintColor = .clear
        
        NotificationCenter.default.addObserver(self, selector:#selector(LoginViewController.finishDownloadAll(_:)), name: NSNotification.Name(rawValue: all_ingredient_subscription), object: nil)
        self.usernameTextField.delegate = self
        
        let userIcon = UIImageView(image: UIImage(named: textfield_username_icon))
        let passwordIcon = UIImageView(image: UIImage(named: textfield_password_icon))
        
        let iconFrame = CGRect(x: 0, y: 0, width: 18, height: 20)

        userIcon.frame = iconFrame
        passwordIcon.frame = iconFrame
        
        if let size = userIcon.image?.size {
            userIcon.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        if let size = passwordIcon.image?.size {
            passwordIcon.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        
        userIcon.contentMode = UIViewContentMode.center
        passwordIcon.contentMode = UIViewContentMode.center
        
        //usernameTextField.leftView = userIcon
        //passwordTextField.leftView = passwordIcon
        let userPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.white])
        let passwordPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.white])
        
        usernameTextField.attributedPlaceholder = userPlaceholder
        passwordTextField.attributedPlaceholder = passwordPlaceholder;
        
        usernameTextField.textColor = .white
        passwordTextField.textColor = .white

        
        usernameTextField.leftViewMode = .always
        passwordTextField.leftViewMode = .always
        
    }

    @IBAction func loginFacebook(_ sender: AnyObject) {
        
        LibraryAPI.sharedInstance.loginFacebook(from: self, { (result) in
            INotificationView.shared.hideProgressView()
            if let status : Bool = result["status"] as? Bool{
                if status {
                    //self.performSegue(withIdentifier: "post_login", sender: self)
                }
            }
        })
    }

    @IBAction func loginTwitter(_ sender: AnyObject) {
        LibraryAPI.sharedInstance.loginTwitter { (result) in
            INotificationView.shared.hideProgressView()
            if let status : Bool = result["status"] as? Bool{
                if status {
                    self.performSegue(withIdentifier: "post_login", sender: nil)
                }
            }
            
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        NotificationCenter.default.removeObserver(self)
        statusBarBackgroundView.backgroundColor = scoodit_menu_color
        statusBarBackgroundView.tintColor = .black
    }
    
    func dissmissLoading()
    {
        INotificationView.shared.dissmissNotification(UITapGestureRecognizer())
    }
    
    func finishDownloadAll(_ notification: Notification){
        let userInfo = (notification as NSNotification).userInfo as! [String: AnyObject]
        if let percentage = userInfo["percentage"] as! String! {
            if Int(percentage)! > 99  {
                self.dissmissLoading()
                self.notificateStatus(title: "Scoodit", message: "Successfully initialized", target: self)
            }else {
                INotificationView.shared.showTextLoading("  \(percentage) %")
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if LibraryAPI.sharedInstance.existIngredientsInMemory() {
            dissmissLoading()
        }
        
    }
    func isValidEmail(email :String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    @IBAction func login()
    {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        

        if username.isEmpty || password.isEmpty || !isValidEmail(email : username)
        {
            var textAlert : String = ""
            if username.isEmpty == true {
                textAlert = "Username field can't be empty"
            }
            if password.isEmpty == true {
                textAlert = "Password field can't be empty"
            }
            if !isValidEmail(email : username) {
                textAlert = "Username field must be a valid email"
            }
            
            self.presentMessage(message: textAlert)
            
        } else {
            LibraryAPI.sharedInstance.loginUser(username, password: password) { (result) -> Void in
                
                if result["status"] as! Bool == true {
                    
                    self.performSegue(withIdentifier: "post_login", sender: nil)
                }else {
                    self.presentMessage(message: result["message"] as! String)
                }
            }
        
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
}

