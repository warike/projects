//
//  Manual.swift
//  scoodit
//
//  Created by Sergio Cardenas on 6/10/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

extension ManualViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? MainCollectionViewCell else { return }
        
        collectionViewCell.delegate = self
        
        let dataSourceChildCollectionView = ChildCollectionViewDataSource()
        let delegateChildCollection = ChildCollectionViewDelegate()
        let index = indexPath.row
        let dataset = (dataSet[index] as NSArray)
            
        dataSourceChildCollectionView.data = dataset
        delegateChildCollection.data = dataset
            
        collectionViewCell.initializeCollectionViewWithDataSource(dataSource: dataSourceChildCollectionView, delegate: delegateChildCollection, forRow: index, title: self.cateroriesDataSet[index])
            
        collectionViewCell.collectionViewOffset = storedOffsets[index] ?? 0
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? MainCollectionViewCell else { return }
        let index = indexPath.row
        storedOffsets[index] = collectionViewCell.collectionViewOffset
    }
    
}


extension ManualViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 170)
    }
}

extension ManualViewController: UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        self.view.endEditing(true)
        return false
    }
    
    
    
    @IBAction func texthasChanged(textField: UITextField)
    {
        
        let search_text = textField.text!
        if search_text.isEmpty
        {
            self._isSearching = false
            self.searchList = IngredientList
        }
        else
        {
            let char_count = search_text.characters.count
            
            self._isSearching = true
            self.searchList.removeAll(keepingCapacity: true)
            for index in 0 ..< self.IngredientList.count
            {
                let v = self.IngredientList[index] as Ingredient
                let ingredient_name = v.text
                let evaluate_lenght = (ingredient_name.characters.count > char_count)
                let index = (evaluate_lenght) ? ingredient_name.index(ingredient_name.startIndex, offsetBy: char_count) : ingredient_name.endIndex
                
                let result = ingredient_name.substring(to: index).lowercased()
                
                // this algorithm search if the text is the same of the ingredient name
                if search_text.lowercased() == result {
                    self.searchList.append(v)
                }else{
                    var separated_results : [String] = ingredient_name.components(separatedBy: " ")
                    separated_results = separated_results.filter { $0 != "" }
                    separated_results = separated_results.filter { $0 != " " }
                    
                    if separated_results.count > 1
                    {
                        for r in separated_results
                        {
                            let evaluate_lenght = (r.characters.count > char_count)
                            let index = (evaluate_lenght) ? r.index(r.startIndex, offsetBy: char_count) : r.endIndex
                            let result = r.substring(to: index).lowercased()
                            if search_text.lowercased() == result
                            {
                                self.searchList.append(v)
                                break
                            }
                        }
                    }
                }

            }
        }
        
        self.getUpdatedData(data: self.searchList)
        self.collectionView.reloadData()
    }
 
}

extension ManualViewController : CollectionViewSelectedProtocol {
    
    func collectionViewSelected(_ collectionViewItem: Int) {
        
        let dataProvider = ChildCollectionViewDataSource()
        dataProvider.data = dataSet[collectionViewItem] as NSArray
    }
    
}


