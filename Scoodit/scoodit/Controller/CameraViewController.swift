//
//  CameraViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 4/30/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import SwiftyJSON




class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()
    var ingredientsFound: Array<String>= ["Tap on Camera to find suggestions"]
    var listIngredientScoodit: Dictionary<String,Ingredient> = [:]
    var ingredientsScoodit: Array<String>= []
   
    @IBOutlet var resultText: UILabel!
    @IBOutlet var ingredientImageView: UIImageView!
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        
        if sender.tag == 1 {
            imagePicker.sourceType = .photoLibrary
        }else{
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func matchIngredientValues(_ labelsAnnot :[String])
    {
        self.ingredientsFound.removeAll()
        for l in labelsAnnot
        {
            if self.ingredientsScoodit.contains(l.lowercased()) {
                self.ingredientsFound.append(l)
            }
            
        }
    }
    
    func filterValues(_ labelsAnnot: [String]) -> [String]
    {
        var labelsAnnotResults = labelsAnnot.filter {!$0.contains("food")}
        
        labelsAnnotResults = labelsAnnotResults.filter {!$0.contains("fruit")}
        labelsAnnotResults = labelsAnnotResults.filter {!$0.contains("plant")}
        labelsAnnotResults = labelsAnnotResults.filter {!$0.contains("vegetable")}
        labelsAnnotResults = labelsAnnotResults.filter {!$0.contains("produce")}
        labelsAnnotResults = labelsAnnotResults.filter {!$0.contains("dish")}
        
        return labelsAnnotResults
    }
    
    func initData()-> Void
    {        
        DispatchQueue.main.async
        {
            LibraryAPI.sharedInstance.getAllIngredient({ (_result) in
                let ingredientsDTO = _result["data"] as! [Ingredient]
                
                let status = _result["status"] as! Bool
                if status {
                    DispatchQueue.main.async
                    {
                        self.ingredientsScoodit.removeAll(keepingCapacity: true)
                        self.listIngredientScoodit.removeAll()
                        
                        for i in ingredientsDTO {
                            self.ingredientsScoodit.append(i.text.lowercased())
                            
                            self.listIngredientScoodit[i.text.lowercased()] = i
                        }
                        
                    }
                }else {
                    
                }
            })
        }
    }

}
