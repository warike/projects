//
//  ViewController.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/5/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var recordar: Int?
    typealias callBack = (String?, NSError?) -> Void
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var olvideContrasenaBtn: UIButton!
    @IBOutlet var recordarSwitch: UISwitch!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    
    
    @IBAction func loginUser(sender: UIButton)
    {
        let usuario :String = usernameField.text!
        let password :String = passwordField.text!
        let recordar_switch :Int = (self.recordarSwitch.on == true) ? 1 : 0
        
        if !self.checkNull(usuario, ipassword: password){
            self.login(usuario, ipassword:password, recordar: recordar_switch)
        }
    }
    
    func generarAlerta(frameTitulo: String, mensaje: String, btnTitulo: String){
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: frameTitulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = frameTitulo
            sosAlert.message = mensaje
            sosAlert.addButtonWithTitle(btnTitulo)
            sosAlert.show()
        }
        
        
    }
    
    @IBAction func olvideContraseñaTapped(sender: UIButton) {
            
        let title = "Recuperar Contraseña"
        let message = "Ingrese nombre de usuario."
        let action_title = "Cancelar"
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: action_title ,style: .Default) { (action: UIAlertAction) -> Void in}
            
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in textField.placeholder = "Nombre de usuario" })
            
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Enviar", style: .Default, handler:{ (alertAction:UIAlertAction) in
                let login :String = (alert.textFields?.first?.text!)!
                LibraryAPI.sharedInstance.recuperarContraseña(login)
                self.indicator.alpha = 1
                self.indicator.startAnimating()
            }))
            
            self.presentViewController(alert,
                animated: true,
                completion: nil)
        } else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            sosAlert.title = title
            sosAlert.message = message
            sosAlert.addButtonWithTitle(action_title)
            sosAlert.addButtonWithTitle("OK")
            sosAlert.show()
        
        }
    }
    

    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 0:
            break;
            
        case 1:
            let email :String = View.textFieldAtIndex(0)!.text! as String
            LibraryAPI.sharedInstance.recuperarContraseña(email)
            self.indicator.alpha = 1
            self.indicator.startAnimating()
            break;
        
        default:
            break;
            
        }
    }
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.autoCompletar()
        self.recordarSwitch.on = (LibraryAPI.sharedInstance.getCurrentUser().recordar == 1) ? true : false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.procesarLogin(_:)), name: "respuestaLogin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.procesarRecuperaContraseña(_:)), name: "respuestaRecuperaContraseña", object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func login(ilogin :String, ipassword :String,recordar :Int){
        LibraryAPI.sharedInstance.logIn(ilogin, ipassword: ipassword, recordar: recordar)
    }
    
    func procesarLogin(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool!
        if (respuesta == true)  {
            self.performSegueWithIdentifier("verMenuPrincipal", sender: self)
        } else {
            self.generarAlerta("Error", mensaje: "Ingrese credenciales válidas", btnTitulo: "OK")
        }
    }
    
    func procesarRecuperaContraseña(notification: NSNotification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let mensaje = userInfo["respuesta"] as! String!
        
        self.generarAlerta("Recuperar Contraseña", mensaje: mensaje, btnTitulo: "OK")
        
        self.indicator.stopAnimating()
        self.indicator.alpha = 0
    }
    
    func checkNull(ilogin:String, ipassword: String) -> Bool {
        var checkNull = false
        
        if (ilogin.isEmpty && ipassword.isEmpty){
            generarAlerta("Error", mensaje: "Ingrese nombre de usuario y contraseña", btnTitulo: "OK")
            checkNull = true
        } else if (ilogin.isEmpty || ipassword.isEmpty){
            if (ilogin.isEmpty) {
                self.generarAlerta("Error", mensaje: "Ingrese nombre de usuario", btnTitulo: "OK")
            } else if (ipassword.isEmpty){
                self.generarAlerta("Error", mensaje: "Ingrese contraseña", btnTitulo: "OK")
            }
            checkNull = true
        }
        return checkNull
    }
    
    func autoCompletar(){
        if(NSUserDefaults.standardUserDefaults().objectForKey("usuario") != nil){
            
            var usuarioDataEncoded: [NSData] = NSUserDefaults.standardUserDefaults().objectForKey("usuario") as! [NSData]
            let unpackedIlogin: String = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[0] as NSData) as! String
            let unpackedIpassword: String = NSKeyedUnarchiver.unarchiveObjectWithData(usuarioDataEncoded[1] as NSData) as! String
            
            self.usernameField.text = unpackedIlogin
            self.passwordField.text = unpackedIpassword
        }
    }
}