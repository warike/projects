//
//  IngredientCategoryView.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/17/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class IngredientCategoryView: UIView {
    
    @IBOutlet weak var titleCell: UILabel!

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
        
        let manualInputCellBackgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        let titleCellColor = UIColor(red:0.20, green:0.24, blue:0.28, alpha:1.0)
        
        
        self.view = loadViewFromXibFile()
        self.view.backgroundColor = manualInputCellBackgroundColor
        self.titleCell.tintColor = titleCellColor
        self.view.frame = bounds
        
        
        
        
        self.view.layer.borderWidth = 0.4
        self.view.layer.borderColor = UIColor.lightGray.cgColor
        
        self.titleCell.textColor = .darkGray
        self.addSubview(view)
    }
    
    func setShadow()
    {
        self.view.layer.shadowColor = UIColor.lightGray.cgColor
        self.view.layer.shadowOpacity = 1
        self.view.layer.shadowOffset = CGSize.zero
        self.view.layer.shadowRadius = 3
    
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "IngredientCategoryView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func setTitle(title: String)
    {
        self.titleCell.text = title.uppercased()
    }

}
