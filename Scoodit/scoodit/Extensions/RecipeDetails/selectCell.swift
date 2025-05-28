

import UIKit

class selectCell: UITableViewCell, IngredientHelper {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 10.0
    }
    
    
    func configureWithData(_ i: Ingredient, serving: Float?){
        let ingredient_metric = i.metric
        let ingredient_qty = i.quantity
        let user_metric = LibraryAPI.sharedInstance.getMetricSystem()
        let converted_qty = self.transform(from: ingredient_metric, to: user_metric, value: ingredient_qty)
        let converted_metric = self.getMetric(from: ingredient_metric, to: user_metric)
        let serving = converted_qty * serving!
        
        
        
        self.postText.font = menuFont
        self.postText.text = "\(serving) \(converted_metric) \(i.text)"
        
        
    }
    
    func configureToBuy(_ i: Ingredient)
    {
        self.userImage.image = i.isAvailable ? UIImage(named: "checked_icon") : UIImage(named: "add_ingredient_icon")
    }
    
    func configureAvailability(_ i: Ingredient)
    {
        self.userImage.image = i.isAvailable ? UIImage(named: "delete_ingredient_icon") : UIImage(named: "add_ingredient_icon")
    }
    
    func setImage(img: UIImage)
    {
        self.userImage.image = img
    }
    
    func colorCell()
    {
        backgroundColor = lightGrayColor
    
    }
   
}
