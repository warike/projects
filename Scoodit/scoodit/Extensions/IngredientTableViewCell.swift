//
//  IngredientTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/10/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var ingredientImage: UIImageView!
    @IBOutlet weak var starImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
