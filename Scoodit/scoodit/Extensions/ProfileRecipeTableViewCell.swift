//
//  ProfileRecipeTableViewCell.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/2/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class ProfileRecipeTableViewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet weak var favoriteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
