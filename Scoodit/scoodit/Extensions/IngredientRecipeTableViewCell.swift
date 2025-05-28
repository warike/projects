//
//  IngredientRecipeTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/27/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientRecipeTableViewCell: UITableViewCell {
    
    @IBOutlet var textIngredient: UILabel!
    @IBOutlet var imgIngredient: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
