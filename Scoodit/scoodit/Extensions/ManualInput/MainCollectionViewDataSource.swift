//
//  MainCollectionViewDataSource.swift
//  scoodit
//
//  Created by Sergio Cardenas on 6/11/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class MainCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    var  dataSet : NSArray!
    var  sectionDataSet : NSArray!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection = sectionDataSet.count
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseMainCollectionViewCellIdentifier, for: indexPath)
        cell.backgroundColor = addItBackground
        return cell
    }
    
}
