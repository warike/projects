//
//  UsuarioDemoViewController.swift
//  lobarnecheagps
//
//  Created by Diego Robles on 11-12-15.
//  Copyright © 2015 SAMTECH SA. All rights reserved.
//

import Foundation
import UIKit

class UsuarioDemoViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtIlogin: UITextField!
    @IBOutlet weak var txtIpassword: UITextField!
    @IBOutlet weak var txtIpassword2: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtRut: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        //scrollView.contentSize.height = scrollView.contentSize.height + 200
        //scrollView.contentSize.width = view.frame.width
        NotificationCenter.default.addObserver(self, selector:#selector(UsuarioDemoViewController.procesarInsertaUsuarioDemo(_:)), name: NSNotification.Name(rawValue: "respuestaInsertarUsuarioDemo"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        let btnGuard: UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsuarioDemoViewController.guardarCambios(_:)))
        self.navigationItem.rightBarButtonItem = btnGuard
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
    }
    
    func guardarCambios(_ sender: AnyObject){
        if (!checkNull(txtEmail!.text!) && !checkNull(txtIlogin!.text!) &&
            !checkNull(txtIpassword!.text!) && !checkNull(txtIpassword2!.text!) &&
            !checkNull(txtName!.text!) && !checkNull(txtLastname!.text!) &&
            !checkNull(txtRut!.text!) && /**!checkNull(txtAdress!.text!) &&**/
            !checkNull(txtPhone!.text!)) {
                if(checkPassword(txtIpassword!.text!, password2: txtIpassword2!.text!)){
                    let rut = validaRut(txtRut!.text!)
                    print("Entra")
                    print(rut)
                    LibraryAPI.sharedInstance.InsertarUsuarioDemo(txtEmail!.text!, ilogin: txtIlogin!.text!, ipassword: txtIpassword!.text!, nombre: txtName!.text!, apellido: txtLastname!.text!, rut: rut, fono: txtPhone!.text!)
                } else {
                    generarAlerta("Error", mensaje: "Las contraseñas deben coincidir", btnTitulo: "OK")
                }
        } else {
            generarAlerta("Error", mensaje: "Todos los campos son obligatorios", btnTitulo: "OK")
        }
    }
    
    func checkNull(_ string: String) -> Bool{
        if (string.isEmpty){
            return true
        } else {
            return false
        }
    }
    
    func checkPassword(_ password1: String, password2: String) -> Bool {
        var resultado = false
        if(!password1.isEmpty && !password2.isEmpty){
            if (password1 == password2){
                resultado = true
            }
        }
        return resultado
    }
    
    func validaRut(_ rut: String) -> String{
        var rut = rut
        rut = rut.replacingOccurrences(of: ".", with: "")
        return rut
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
    
    func procesarInsertaUsuarioDemo(_ notification: Notification){
        let userInfo = notification.userInfo as! [String: AnyObject]
        let respuesta = userInfo["respuesta"] as! Bool!
        let mensaje = userInfo["mensaje"] as! String!
        if (respuesta == true)  {
            self.generarAlerta("Atención", mensaje: "Usuario creado con éxito", btnTitulo: "Ok")
        } else {
            self.generarAlerta("Error", mensaje: mensaje!, btnTitulo: "OK")
        }
    }
    
}

class UsuarioDemoFrontViewController: UIViewController{
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let btnNext: UIBarButtonItem = UIBarButtonItem(title: "Siguiente", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsuarioDemoFrontViewController.verCrearUsuarioDemo(_:)))
        let btnBack: UIBarButtonItem = UIBarButtonItem(title: "Volver", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UsuarioDemoFrontViewController.verLogin(_:)))
        self.navigationItem.rightBarButtonItem = btnNext
        self.navigationItem.leftBarButtonItem = btnBack
        self.cargarFront()
    }
    
    func verCrearUsuarioDemo(_ sender: AnyObject){
        performSegue(withIdentifier: "verCrearUsuarioDemo", sender: self)
    }
    
    func verLogin(_ sender: AnyObject){
        performSegue(withIdentifier: "verLogin", sender: self)
    }
    
    func cargarFront()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 183/255.0, green: 28/255.0, blue: 28/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        navigationItem.backBarButtonItem?.target = "back" as AnyObject?
    }
}
