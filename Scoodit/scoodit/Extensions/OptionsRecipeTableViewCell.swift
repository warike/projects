//
//  OptionsTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/2/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class OptionsRecipeTableViewCell: UITableViewCell {

    @IBOutlet var ingredientsBtn: UIButton!
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var nutritionBtn: UIButton!
    
    @IBOutlet weak var nKCalories: UILabel!
    @IBOutlet weak var cookingTime: UILabel!
    @IBOutlet weak var nIngredients: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
