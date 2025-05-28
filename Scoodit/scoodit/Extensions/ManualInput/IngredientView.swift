//
//  IngredientView.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/18/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientView: UIView {
    
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var ingredientPicture: UIImageView!

    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()
    {
        
        self.view = loadViewFromXibFile()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.view.backgroundColor = addItBackground
        
        self.ingredientPicture.image = UIImage()
        self.ingredientName.textColor = .darkGray
        self.addSubview(view)
    }
    
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "IngredientView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
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
