//
//  RecipiesListExtension.swift
//  scoodit
//
//  Created by RWBook Retina on 1/23/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//


import UIKit

extension RecipesListViewController: MessageProtocol {
    
    func getTitleView(_ title: String) -> UIView {
    
        let UILabelTitle = UILabel()
        UILabelTitle.text = title
        UILabelTitle.font = UIFont(name: "Kannada Sangam", size: 20)
        UILabelTitle.sizeToFit()
        
        let TitleView = UIView(frame: CGRect(x: 0,y: 0,width: UILabelTitle.frame.width,height: UILabelTitle.frame.height))
        TitleView.addSubview(UILabelTitle)
        
        
        return TitleView
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        return true
    }
    
    func requestRecommendations()
    {
        let shouldAskForRecommendations = LibraryAPI.sharedInstance.getIngredientsHaveChangedState()
        
        if shouldAskForRecommendations {
            LibraryAPI.sharedInstance.ingredientsHaveChangedState(state: false)
            INotificationView.shared.showInitLoading(self.view, text: "Loading")
            LibraryAPI.sharedInstance.getUserRecipes()
        }

    }
    
    func initData() -> Void{
        NotificationCenter.default.addObserver(self, selector:#selector(RecipesListViewController.loadData(_:)), name: NSNotification.Name(rawValue: "recommendedRecipes"), object: nil)
        
    }
    
    func loadData(_ notificacion: Notification)
    {
        let data = (notificacion as NSNotification).userInfo as! [String: AnyObject]
        let _result = data["result"] as! [String: AnyObject]
        let msg = _result["message"] as! String
        INotificationView.shared.hideProgressView()

        if let status : Bool = _result["status"] as? Bool{
            if status {
                if let success : Bool = _result["success"] as? Bool{
                    if success {
                        let recipesDTO = _result["data"] as! [Recipe]
                        DispatchQueue.main.async
                            {
                                self.RecipesList.removeAll(keepingCapacity: true)
                                self.RecipesList = recipesDTO
                                self.RecipesList.sort(by: self.sortByMissingIngredients)
                                self.RecipesTableView?.reloadData()
                        }
                    }else{
                        self.notificateStatus(title: "Recipes", message: msg, target: self)
                    }
                }
            }else{
                self.notificateStatus(title: "Recipes", message: msg, target: self)
            }
        }
    }
    
    func sortByRecipeName(_ compare1: Recipe, compare2: Recipe) -> Bool {
        return compare1.title.localizedCaseInsensitiveCompare(compare2.title) == ComparisonResult.orderedAscending
    }
    
    func sortByQtyIngredients(_ compare1: Recipe, compare2: Recipe) -> Bool {
        return compare1.ingredients.count < compare2.ingredients.count
    }
    
    func sortByCookingTime(_ compare1: Recipe, compare2: Recipe) -> Bool{
        return compare1.cookingTime < compare2.cookingTime
    }
    
    func sortByMissingIngredients(_ compare1: Recipe, compare2: Recipe) -> Bool{
        return compare1.missingFromUser < compare2.missingFromUser
    }
    
    
    @IBAction func SortByAction() {
        
        
        let alertController = UIAlertController(title: alert_sortbyaction_title, message: "Sorted by", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let cookingItem = UIAlertAction(title: action_cookingtime_title, style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            self.RecipesList.sort(by: self.sortByCookingTime)
            self.searchList.sort(by: self.sortByCookingTime)
            self.RecipesTableView?.reloadData()
        })
        alertController.addAction(cookingItem)
        
        let qtyIngredients = UIAlertAction(title: action_ningredient_title, style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            
            self.RecipesList.sort(by: self.sortByQtyIngredients)
            self.searchList.sort(by: self.sortByQtyIngredients)
            self.RecipesTableView?.reloadData()
        })
        alertController.addAction(qtyIngredients)
        
        let cancelItem = UIAlertAction(title: action_cancel_title, style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
        })
        alertController.addAction(cancelItem)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        let search_text = sender.text!
        if search_text.isEmpty{
            self._isSearching = false
            self.RecipesTableView.reloadData()
        } else {
            self._isSearching = true
            self.searchList.removeAll(keepingCapacity: true)
            for index in 0 ..< self.RecipesList.count
            {
                let r = self.RecipesList[index] as Recipe
                if r.title.lowercased().range(of: search_text.lowercased())  != nil  {
                    self.searchList.append(r)
                }
            }
            self.RecipesTableView.reloadData()
        }
    }
}
