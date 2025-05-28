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
    @IBOutlet weak var btnTestApp: UIButton!
    
    
    
    
    @IBAction func loginUser(_ sender: UIButton)
    {
        let usuario :String = self.usernameField.text!
        let password :String = self.passwordField.text!
        let recordar_switch :Int = (self.recordarSwitch.isOn == true) ? 1 : 0
        
        if !self.checkNull(usuario, ipassword: password) {
            self.login(usuario, ipassword:password, recordar: recordar_switch)
        }
    }
    
    func generarAlerta(_ frameTitulo: String, mensaje: String, btnTitulo: String)
    {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: frameTitulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: btnTitulo, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.title = frameTitulo
            sosAlert.message = mensaje
            sosAlert.addButton(withTitle: btnTitulo)
            sosAlert.show()
        }
    }
    
    @IBAction func olvideContraseñaTapped(_ sender: UIButton) {
        let title = "Recuperar Contraseña"
        let message = "Ingrese nombre de usuario."
        let action_title = "Cancelar"
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: action_title ,style: .default) { (action: UIAlertAction) -> Void in}
            
            alert.addTextField(configurationHandler: {(textField: UITextField) in textField.placeholder = "Nombre de usuario" })
            
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Enviar", style: .default, handler:{ (alertAction:UIAlertAction) in
                let login :String = (alert.textFields?.first?.text!)!
                LibraryAPI.sharedInstance.recuperarContraseña(login)
                self.indicator.alpha = 1
                self.indicator.startAnimating()
            }))
            
            self.present(alert,
                animated: true,
                completion: nil)
        } else if iOS7{
            
            let sosAlert: UIAlertView = UIAlertView()
            sosAlert.delegate = self
            sosAlert.alertViewStyle = UIAlertViewStyle.plainTextInput
            sosAlert.title = title
            sosAlert.message = message
            sosAlert.addButton(withTitle: action_title)
            sosAlert.addButton(withTitle: "OK")
            sosAlert.show()
            
        }
    }
    
    
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 0:
            break;
            
        case 1:
            let email :String = View.textField(at: 0)!.text! as String
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
        self.recordarSwitch.isOn = (LibraryAPI.sharedInstance.getCurrentUser().recordar == 1) ? true : false
        
        NotificationCenter.default.addObserver(self, selector:#selector(LoginViewController.procesarLogin(_:)), name: NSNotification.Name(rawValue: "respuestaLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector:, name: NSNotification.Name(rawValue: "respuestaRecuperaContraseña"), object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: "usuario") != nil){
            btnTestApp.alpha = 0
        }
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func login(_ ilogin :String, ipassword :String,recordar :Int){
        LibraryAPI.sharedInstance.logIn(ilogin, ipassword: ipassword, recordar: recordar)
    }
    
    func procesarLogin(_ notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool!
        if (respuesta == true)  {
            self.performSegue(withIdentifier: "verMenuPrincipal", sender: self)
        } else {
            self.generarAlerta("Error", mensaje: "Ingrese credenciales válidas", btnTitulo: "OK")
        }
    }
    
    func procesarRecuperaContraseña(_ notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let mensaje = userInfo["respuesta"] as! String!
        
        self.generarAlerta("Recuperar Contraseña", mensaje: mensaje!, btnTitulo: "OK")
        
        self.indicator.stopAnimating()
        self.indicator.alpha = 0
    }
    
    func checkNull(_ ilogin:String, ipassword: String) -> Bool {
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
        if(UserDefaults.standard.object(forKey: "usuario") != nil){
            
            var usuarioDataEncoded: [Data] = UserDefaults.standard.object(forKey: "usuario") as! [Data]
            let unpackedIlogin: String = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[0] as Data) as! String
            let unpackedIpassword: String = NSKeyedUnarchiver.unarchiveObject(with: usuarioDataEncoded[1] as Data) as! String
            
            self.usernameField.text = unpackedIlogin
            self.passwordField.text = unpackedIpassword
        }
    }
}
