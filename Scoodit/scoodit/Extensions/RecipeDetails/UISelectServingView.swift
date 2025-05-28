//
//  UISelectServingView.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/3/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit


class UISelectServingView: UIView {

    @IBOutlet weak var servingPickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var view: UIView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView()
    {
        servingPickerView = UIPickerView()
        
        self.view = loadViewFromXibFile()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
        
        /// Adds a shadow to our view
        view.layer.cornerRadius = 4.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        visualEffectView.layer.cornerRadius = 4.0
        visualEffectView.alpha = 0.8
        
        
        
        
    }

    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "UISelectServingView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    
}
