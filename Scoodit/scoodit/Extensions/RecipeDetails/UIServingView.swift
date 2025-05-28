//
//  UIServingView.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/2/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class UIServingView: UIView {

    // Our custom view from the XIB file
    var view: UIView!
    
    
    @IBOutlet weak var addServingButton: UIButton!
    @IBOutlet weak var servingNumber: UILabel!
    @IBOutlet weak var shoppingButton: UIButton!
    @IBOutlet weak var whatsappButton: UIButton!
    
    
    /**
     Initialiser method
     */
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
        self.view.backgroundColor = lightGrayColor
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        self.view.layer.borderWidth = 0.5
        
        self.view.layer.borderColor = UIColor.lightGray.cgColor
        self.addSubview(view)
    }
    
    func setServingNumber(number: String)
    {
        self.servingNumber.text = "Serving : \(number) "
    
    }
    
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "UIServingView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    
}
