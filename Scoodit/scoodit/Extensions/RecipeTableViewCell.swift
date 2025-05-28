//
//  RecipeTableViewCell.swift
//  scoodit
//
//  Created by RWBook Retina on 1/24/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var RecipeNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var CookingTimeLabel: UILabel!
    @IBOutlet weak var MissingIngredientsNumber : UILabel!
    
    var recipe = Recipe()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addLinearGradientToView(UIColor.black, transparntToOpaque: true, vertical: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
        
    func addLinearGradientToView(_ colour: UIColor, transparntToOpaque: Bool, vertical: Bool)
    {
        let gradient = CAGradientLayer()
        let gradientFrame = CGRect(x: 0, y: 0, width: photoImageView.frame.size.width, height: photoImageView.frame.size.height)
        gradient.frame = gradientFrame
        
        var colours = [
            colour.withAlphaComponent(0.5).cgColor,
            colour.withAlphaComponent(0.2).cgColor,
            colour.withAlphaComponent(0).cgColor,
            colour.withAlphaComponent(0).cgColor,
            colour.withAlphaComponent(0).cgColor,
            colour.withAlphaComponent(0).cgColor,
            UIColor.clear.cgColor
        ]
        
        if transparntToOpaque == true
        {
            colours = colours.reversed()
        }
        
        if vertical == true
        {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        }
        gradient.colors = colours
        photoImageView.layer.insertSublayer(gradient, at: 0)
    }

    override func didMoveToWindow() {

    }
}
