//
//  RecipeIngredientsViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 9/28/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//


import Foundation
import XLPagerTabStrip
import Toaster



class RecipeIngredientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {
    
    
    
    var ingredientsList : [Ingredient] = []
    var ingredients_list : [Ingredient]?
    var recipe_id : String?
    var recipeName = ""
    
    var recipeServingNumber = ""
    var selectedServing = ""
    
    
    
    var itemInfo = IndicatorInfo(title: "View")
    var tableView :UITableView = UITableView()
    var servingView :UIServingView?
    var selectServingView : UISelectServingView?
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewWillLayoutSubviews() {
        
        let width = view.frame.size.width
        let height = view.frame.size.height

        tableView.frame = CGRect(x: 0, y: 50, width: width, height: height-50)
        servingView?.frame = CGRect(x: 0, y: 0, width: width+2, height: 50)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        
        self.servingView = UIServingView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.selectServingView = UISelectServingView(frame: CGRect(x: 50, y: 0, width: 212 , height: 209))
        
        self.selectServingView?.servingPickerView.delegate = self
        self.selectServingView?.servingPickerView.dataSource = self
        
        
        self.servingView?.addServingButton.addTarget(self, action: #selector(RecipeIngredientsViewController.increaseServing(sender:)), for: UIControlEvents.touchUpInside)
        
        self.servingView?.whatsappButton.addTarget(self, action: #selector(RecipeIngredientsViewController.showWhatsapp(_:)), for: UIControlEvents.touchUpInside)
        self.servingView?.shoppingButton.addTarget(self, action: #selector(RecipeIngredientsViewController.addToShoppingList(_:)), for: UIControlEvents.touchUpInside)
        
        self.selectServingView?.doneButton.addTarget(self, action: #selector(RecipeIngredientsViewController.didSelectServingNumber(sender:)), for: UIControlEvents.touchUpInside)
        
        
        self.ingredients_list = self.ingredientsList
        self.servingView?.setServingNumber(number: self.selectedServing)
        self.selectServingView?.alpha = 0
        
        
        self.tableView.frame = CGRect(x: 1, y: 60, width: 0, height: 0)
        self.tableView.register(UINib(nibName: "selectCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        self.tableView.estimatedRowHeight = 60.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsSelection = true
        
        self.view.addSubview(tableView)
        self.view.addSubview(self.servingView!)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients_list!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! selectCell
        
        var i = ingredients_list?[indexPath.row]
        cell.selectionStyle = .none
        i?.isAvailable = !(i?.isAvailable)!
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! selectCell
        
        let i = ingredients_list?[indexPath.row]
        let selected = Float(selectedServing)!
        
        let recipeNumber = Float(recipeServingNumber)!
        let serving = selected/recipeNumber
        
        cell.configureWithData(i!,serving: serving)
        cell.configureToBuy(i!)

        cell.postText.font = menuFont
        cell.selectionStyle = .none
        if !(indexPath.row % 2 == 0 ){
            cell.colorCell()
        }
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension RecipeIngredientsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func addToShoppingList(_ sender: UIButton)
    {
        for i in self.ingredients_list! {
            if !i.isAvailable {
                
                
                let selected = Float(selectedServing)!
                let recipeNumber = Float(recipeServingNumber)!
                let qty = Float(i.quantity)!
                
                let serving = selected/recipeNumber
                let total = qty * serving
                
                var ingredient_dto =  Ingredient(_ID: i._ID, text: i.text, imageUrl: i.imageUrl, pluralName: "", status: true, synonym: [], synonymPlural: [], categories: [], nv: [], dv: [], metric: i.metric, isRequired: i.isRequired, isAvailable: i.isAvailable, quantity: String(total), tempImg: Data())
                
                
                
                LibraryAPI.sharedInstance.addMissingIngredient(ingredient_dto)
            }
        }
        
        let toaster = Toast(text: "Added to the shopping cart", delay: 0.0, duration: 0.3)
        toaster.show()
    }
    
    @IBAction func showWhatsapp(_ sender: UIButton){
        
        var text = "Hey%20I%20need%20to%20buy%20this%3A%20"
        var k = 0
        for i in self.ingredients_list! {
            if !i.isAvailable {
                let text_full: String?
                if i.metric == "" {
                    text_full = i.quantity == "0" ? i.text : "\(i.quantity) \(i.text)"
                }
                else{
                    text_full = "\(i.quantity) \(i.metric) \(i.text)"
                }
                
                let ingredient = text_full!.replacingOccurrences(of: " ", with: "%20")
                print("k: \(k) ingredient: \(text_full)")
                text = text + ingredient + "%2C%20"
                
                
            }
            k = k + 1
        }
        let url = "whatsapp://send?text=\(text)"
        
        let whatsappURL = URL(string: url)
        if UIApplication.shared.canOpenURL(whatsappURL!)
        {
            UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
        }
        
        
    }
    
    func removeSelectServing()
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.selectServingView?.alpha = 0
        }) { (Bool) in
            self.selectServingView?.removeFromSuperview()
        }
    
    }
    
    @IBAction func didSelectServingNumber(sender: AnyObject)
    {
        if !selectedServing.isEmpty {
            self.servingView?.setServingNumber(number: selectedServing)
            self.tableView.reloadData()
        }
        self.removeSelectServing()
        
    }
    
    @IBAction func increaseServing(sender: AnyObject)
    {
        if self.selectServingView?.alpha == 0 {
            let kWindow = UIApplication.shared.keyWindow
            let x = (kWindow?.frame.size.width)!
            let y = (kWindow?.frame.size.height)!

            self.selectServingView?.center = CGPoint(x: (x/2), y: ((y/2)+10) )
            self.selectServingView?.alpha = 0
            
            
            let defaultPos:Int? = Int(selectedServing)
            if (defaultPos?.hashValue)! > 0 {
                selectServingView?.servingPickerView.selectRow(defaultPos!-1, inComponent: 0, animated: false)
            }
            
            kWindow?.addSubview(self.selectServingView!)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.selectServingView?.alpha = 1
                }, completion: nil)
        }
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.removeSelectServing()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servingOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servingOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: servingOptions[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = servingOptions[row]
        if !selected.isEmpty {
            self.selectedServing = String(row+1)
        }
        
        
    }
}



