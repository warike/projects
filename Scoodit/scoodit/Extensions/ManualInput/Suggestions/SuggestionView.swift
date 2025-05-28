//
//  SuggestionView.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/19/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

class SuggestionView: UIView {

    @IBOutlet weak var okBtn: UIButton!
    
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
        self.view = loadViewFromXibFile()
        self.view.frame = bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        view.layer.cornerRadius = 6.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)

        self.addSubview(view)
        
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SuggestionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
}
