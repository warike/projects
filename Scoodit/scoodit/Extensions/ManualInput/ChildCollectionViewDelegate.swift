//
//  ChildCollectionViewDelegate.swift
//  scoodit
//
//  Created by Sergio Cardenas on 6/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class ChildCollectionViewDelegate: NSObject, UICollectionViewDelegate, MessageProtocol {
    
    var data : NSArray!
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let ingredient = data[indexPath.row] as? Ingredient        
        if LibraryAPI.sharedInstance.validateSelectedIngredient(ingredient!._ID)
        {
            self.presentMessage(message: ingredientAlreadySelected)
            return
        }
         DispatchQueue.main.async
         {
            LibraryAPI.sharedInstance.addIngredient(ingredient!) { (result :[String : AnyObject]) -> Void in
                
            }
            self.presentMessage(message: ingredientAddedToInventory)
         }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
}
