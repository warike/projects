//
//  IngredientCollectionViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/12/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var image: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
}