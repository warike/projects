//
//  ChildCollectionsViewDataSource.swift
//  scoodit
//
//  Created by Sergio Cardenas on 6/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Nuke
class ChildCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    var data : NSArray!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection = data.count
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseChildCollectionViewCellIdentifier, for: indexPath) as! IngredientViewCollectionViewCell
        let index = indexPath.row
        let ingredient = data[index] as? Ingredient
        
        cell.setTitle(title: ingredient!.text)
        let defaultImage = UIImage(named: "default_image_ingredient")
        cell.setImage(image: defaultImage!)
        
        if (ingredient?.imageUrl.characters.count)! > 0 {
            let url = URL(string: (ingredient?.imageUrl)!)!
            let request = Request(url: url)
            Nuke.loadImage(with: request, into: cell.ingredientPicture)

            
        }
        
        return cell
    }
    
}
