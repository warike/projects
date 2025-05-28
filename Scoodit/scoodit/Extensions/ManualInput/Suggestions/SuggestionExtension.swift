//
//  SuggestionExtension.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/21/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

extension ManualViewController: UITableViewDataSource, UITableViewDelegate,MessageProtocol
{

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)")
        
        ingredientSuggestions.remove(at: indexPath.row)
        
        if ingredientSuggestions.count == 0 {
            self.closeSuggestionModal()
        }else{
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "ElementCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! selectCell
        let i = ingredientSuggestions[indexPath.row]
        cell.postText.text = i.text
        cell.configureAvailability(i)
        if !(indexPath.row % 2 == 0){
            cell.colorCell()
        }
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.ingredientSuggestions.count
        return count
    }
    
    func closeSuggestionModal()
    {
        
        self.tableView.removeFromSuperview()
        self.suggestionView?.removeFromSuperview()
        self.isSuggestionsDisplayed = false
    
    }
    
    func matchIngredients()
    {
        let ingredients = LibraryAPI.sharedInstance.getUserIngredients()
        let suggestions = self.ingredientSuggestions
        var clean : [Ingredient] = []
        var index = 0
        for s in suggestions {
            var isRepeated = false
            for i in ingredients {
                if s._ID == i._ID {
                    isRepeated = true
                    break
                }
            }
            if !isRepeated {
                clean.append(s)
            }
            index = index + 1
        }
        
        let count = clean.count
        if count > 0 {
            for i in clean {
                LibraryAPI.sharedInstance.addIngrdientInRuntimeMemory(i: i, is_required: false)
            }
            self.presentMessage(message: ingredientsAddedToInventory)
        }
    }
    
    func closeOrCancelSuggestions()
    {
        
        self.matchIngredients()
        self.closeSuggestionModal()
        
    }
    
    func presentSuggestions()
    {
        DispatchQueue.main.async {
            let suggestionsCount = self.ingredientSuggestions.count
            
            let isShortOrLong = (suggestionsCount>3) ? true : false
            
            let heightTable = isShortOrLong ? 350 : 175
            let heightView = isShortOrLong ? 400 : 300
            let kWindow = UIApplication.shared.keyWindow
            
            let collectionFrame = self.collectionView.frame
            let x = (collectionFrame.size.width)
            let y = (collectionFrame.size.height)
            
            
            
            
            self.tableView.frame = CGRect(x: 5, y:5, width: 245 , height: heightTable)
            self.tableView.estimatedRowHeight = 60.0
            self.tableView.reloadData()
            self.suggestionView?.frame.size = CGSize(width: 250, height: heightView)
            self.suggestionView?.center = CGPoint(x: (x/2), y: ((y/2)+50) )
            self.suggestionView?.addSubview(self.tableView)
            self.suggestionView?.bringSubview(toFront: self.tableView)
            
            self.suggestionView?.alpha = 0
            DispatchQueue.main.async (execute: { () -> Void in
                kWindow?.addSubview(self.suggestionView!)
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                    self.suggestionView?.alpha = 1
                    }, completion: nil)
                
            })
            
            
            
        }
    }

}
