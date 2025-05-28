//
//  ShopTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 4/7/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class ShopTableViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var ingredientTextField: UILabel!
    @IBOutlet var quantityTextField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
