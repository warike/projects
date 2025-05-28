//
//  ProfileViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 3/16/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Firebase
import Nuke


class ProfileViewController: UIViewController {

    @IBOutlet var profileTableView: UITableView!

    @IBOutlet weak var houseHoldSizeLAbel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var metricSegmentedControl: UISegmentedControl!
    
    
    //selectServingView
    var modalHouseholdSize : UISelectServingView?
    var selectedServing = ""
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.removeSelectServing()
    }
    
    func changeMetricSystem(){
        
        let metric_value = MentricOption.getMetric(from: metricSegmentedControl.selectedSegmentIndex)
        LibraryAPI.sharedInstance.setMetricSystem(from: metric_value)
    }
    
    
    func setupMetricControl(from metricSystem: MentricOption){
        
        self.metricSegmentedControl.selectedSegmentIndex = metricSystem.rawValue
        self.metricSegmentedControl.addTarget(self, action: #selector(ProfileViewController.changeMetricSystem), for: UIControlEvents.valueChanged)
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        
        let user_entity = LibraryAPI.sharedInstance.getUserEntity()
        self.setupProfileImage(from: user_entity)
        
        let householdSize = user_entity.householdsize
        self.setupHouseHouseholdSize(from: householdSize)
        
        let metric = user_entity.metricSystem
        self.setupMetricControl(from: metric)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addCloseButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupProfileImage(from user: User){
        
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {

                if let photoURL = profile.photoURL{
                    let url = photoURL
                    let request = Request(url: url)
                    Nuke.loadImage(with: request, into: profileImageView)
                    
                    self.profileImageView.layer.cornerRadius = 50
                    
                    self.profileImageView.layer.borderWidth = 1.5
                    self.profileImageView.layer.borderColor = UIColor.white.cgColor
                    
                    self.profileImageView.layer.masksToBounds = true
                    self.profileImageView.contentMode = .scaleAspectFill
                    
                }
                
                self.metricSegmentedControl.layer.cornerRadius = 10
                self.languageButton.layer.borderWidth = 1.5
                self.languageButton.layer.borderColor = UIColor.white.cgColor
                
                
                
            }
        } else {
        }
        
    }
    func setupHouseHouseholdSize(from entity: Int){
        self.selectedServing = String(entity)
        
        let onTapLabel = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.increaseServing(sender:)))
        
        self.houseHoldSizeLAbel.addGestureRecognizer(onTapLabel)
        
        
        self.modalHouseholdSize = UISelectServingView(frame: CGRect(x: 50, y: 0, width: 212 , height: 209))
        
        self.modalHouseholdSize?.servingPickerView.delegate = self
        self.modalHouseholdSize?.servingPickerView.dataSource = self
        
        self.modalHouseholdSize?.doneButton.addTarget(self, action: #selector(ProfileViewController.didSelectServingNumber(sender:)), for: UIControlEvents.touchUpInside)
        self.modalHouseholdSize?.alpha = 0
        
        
        
        self.houseHoldSizeLAbel.text = "Household size : \(entity)"
    }
    
    

}
extension ProfileViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func removeSelectServing()
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.modalHouseholdSize?.alpha = 0
        }) { (Bool) in
            self.modalHouseholdSize?.removeFromSuperview()
        }
        
    }
    
    @IBAction func didSelectServingNumber(sender: AnyObject)
    {
        if !selectedServing.isEmpty {
            
            let new_householdsize = Int(selectedServing)!
            self.houseHoldSizeLAbel.text = "Household size : \(new_householdsize)"
            LibraryAPI.sharedInstance.updateHouseHold(number: new_householdsize)
        }
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
    
    @IBAction func increaseServing(sender: AnyObject)
    {
        if self.modalHouseholdSize?.alpha == 0 {
            let kWindow = UIApplication.shared.keyWindow
            let x = (kWindow?.frame.size.width)!
            let y = (kWindow?.frame.size.height)!
            
            self.modalHouseholdSize?.center = CGPoint(x: (x/2), y: ((y/2)+10) )
            self.modalHouseholdSize?.alpha = 0
            
            
            let defaultPos:Int? = Int(selectedServing)
            if (defaultPos?.hashValue)! > 0 {
                modalHouseholdSize?.servingPickerView.selectRow(defaultPos!-1, inComponent: 0, animated: false)
            }
            
            kWindow?.addSubview(self.modalHouseholdSize!)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                self.modalHouseholdSize?.alpha = 1
            }, completion: nil)
        }
        
    }
}


extension ProfileViewController : ScooditHelper, UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        //let option = options[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "profileCell")! as UITableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.blue;
        var text = empty_string_value
        
        text = options[indexPath.row] as String
        
        if let font = UIFont(name: "Montserrat", size: 14.16) {
            cell.textLabel!.font = font
            cell.textLabel?.textAlignment = .center
        }
        cell.textLabel!.text = text
        
        return cell
    }

}
