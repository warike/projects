//
//  IngredientCollectionViewCell.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/29/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientViewCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var ingredientName: UILabel!
    @IBOutlet var ingredientPicture: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView()
    {
        self.backgroundColor = addItBackground
    }
    
    func setTitle(title: String)
    {
        self.ingredientName.text = title.uppercased()
    }
    
    func setImage(image: UIImage)
    {
        self.ingredientPicture.image = image
        
    }
}
