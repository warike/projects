 //
//  RecipeDetailViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageProtocol {
    
    @IBOutlet var contentTableView:UITableView!
    var IngredientList = [Ingredient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        self.contentTableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IngredientList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! IngredientRecipeTableViewCell
        var ingredient = IngredientList[(indexPath as NSIndexPath).row]
        
        if ingredient.isAvailable
        {
            cell.imgIngredient.image = UIImage(named: "unchecked")
            ingredient.isAvailable = false
        }
        else
        {
            cell.imgIngredient.image = UIImage(named: "checked")
            ingredient.isAvailable = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: IngredientRecipeTableViewCell = self.contentTableView!.dequeueReusableCell(withIdentifier: "IngredientRecipeTableViewCell") as! IngredientRecipeTableViewCell
        
        let ingredient = IngredientList[(indexPath as NSIndexPath).row]
        let text : String?
        if ingredient.metric == "" {
            text = ingredient.quantity == "0" ? ingredient.text : "\(ingredient.quantity) \(ingredient.text)"
        }
        else{
            text = "\(ingredient.quantity) \(ingredient.metric) \(ingredient.text)"
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textIngredient!.text = text
        cell.imgIngredient.image = (ingredient.isAvailable) ? UIImage(named: "checked") : UIImage(named: "unchecked")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    @IBAction func addToShoppingList(_ sender: UIButton)
    {
        for i in self.IngredientList {
            if !i.isAvailable {
                LibraryAPI.sharedInstance.addMissingIngredient(i)
                presentMessage(message: "Ingredient Added!")
                
            }
        }
    
    }
    
    @IBAction func showWhatsapp(_ sender: UIButton){
        
        var text = "Hey%20I%20need%20to%20buy%20this%3A%20"
        
        for var i in self.IngredientList {
            if !i.isAvailable {
                let text_full: String?
                if i.metric == "" {
                    text_full = i.quantity == "0" ? i.text : "\(i.quantity) \(i.text)"
                }
                else{
                    text_full = "\(i.quantity) \(i.metric) \(i.text)"
                }
                
                let ingredient = text_full!.replacingOccurrences(of: " ", with: "%20")
                text = text + ingredient + "%2C%20"
                

            }
        }
        let url = "whatsapp://send?text=\(text)"
        
        let whatsappURL = URL(string: url)
        if UIApplication.shared.canOpenURL(whatsappURL!)
        {
            UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
        }

        
    }
    
    @IBAction func SortByAction() {
        let alertController = UIAlertController(title: "Scoodit", message: "Metric System", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let americanItem = UIAlertAction(title: "American Metrics", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            self.contentTableView?.reloadData()
        })
        alertController.addAction(americanItem)
        
        let englishItem = UIAlertAction(title: "English Metrics", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            self.contentTableView?.reloadData()
        })
        alertController.addAction(englishItem)
        
        
        let cancelItem = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
        })
        alertController.addAction(cancelItem)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
