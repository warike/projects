//
//  MainCollectionViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 6/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

import UIKit

protocol CollectionViewSelectedProtocol {
    
    func collectionViewSelected(_ collectionViewItem : Int)
    
}

class MainCollectionViewCell: UICollectionViewCell {
    
    var collectionViewDataSource : UICollectionViewDataSource!
    
    var collectionViewDelegate : UICollectionViewDelegate!
    
    var collectionView : UICollectionView!
    
    var delegate : CollectionViewSelectedProtocol!
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
    
    func initializeCollectionViewWithDataSource<D: protocol<UICollectionViewDataSource>,E: protocol<UICollectionViewDelegate>>(dataSource: D, delegate :E, forRow row: Int, title: String) {
        
        self.collectionViewDataSource = dataSource
        
        self.collectionViewDelegate = delegate as UICollectionViewDelegate!
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let boundsCollectionView = self.bounds
        
        let categoryWidth = boundsCollectionView.width
        let categoryHeight = 40
        
        let collectionViewWidth  = boundsCollectionView.width
        let collectionViewHeight  = 150
        
        let frameingredientCategoryView = CGRect(x: 0, y: 0, width: CGFloat(categoryWidth), height: CGFloat(categoryHeight))
        let frameIngredientViewCollectionViewCell = CGRect(x: 0, y: CGFloat(categoryHeight-10), width: CGFloat(collectionViewWidth), height: CGFloat(collectionViewHeight))
        
        let collectionView = UICollectionView(frame: frameIngredientViewCollectionViewCell, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = addItBackground
        collectionView.dataSource = self.collectionViewDataSource
        collectionView.delegate = self.collectionViewDelegate
        collectionView.tag = row
        
        self.addSubview(collectionView)
        collectionView.register(UINib(nibName: IngredientViewCollectionViewCellClass, bundle: nil), forCellWithReuseIdentifier: reuseChildCollectionViewCellIdentifier)
        self.collectionView = collectionView
        

        let ingredientCategoryView = IngredientCategoryView(frame: frameingredientCategoryView)
        ingredientCategoryView.setTitle(title: title)
        ingredientCategoryView.setShadow()
        
        self.addSubview(ingredientCategoryView)
        
        collectionView.reloadData()
    }
    
    func buttonAction(_ sender: UIButton!) {
        self.delegate.collectionViewSelected(collectionView.tag)
    }
    
}
