//
//  MenuViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 5/16/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import MessageUI

// let itemList = ["Dietary preferences", "Favourite recipes", "Invite Friends", "Rate our app", "We love feedbacks", "About Scoodit"]
enum MenuOptions : String {
    
    case Dietary = "Dietary preferences"
    case Favorites = "Favourite recipes"
    case Invite = "Invite Friends"
    case Rate = "Rate our app"
    case Feedback = "We love feedbacks"
    case About = "About Scoodit"
    
    static func getMenuOptions() -> [MenuOptions]
    {
        let options = [
            //MenuOptions.Dietary,
            MenuOptions.Favorites,
            MenuOptions.Invite,
            MenuOptions.Rate,
            MenuOptions.Feedback,
            MenuOptions.About
        ]
        return options
    }
    
}


class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableViewMenu: UITableView!
    var menu_options: [MenuOptions] = MenuOptions.getMenuOptions()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewMenu.delegate = self
        self.tableViewMenu.dataSource = self
        self.tableViewMenu.separatorColor = .clear
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addCloseButton()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
        cell.selectionStyle = UITableViewCellSelectionStyle.blue;
        
        
        var image : UIImage? = UIImage()
        let option = menu_options[indexPath.row]
        let text = option.rawValue
        
        switch (option) {
        case .Dietary:
            image = UIImage(named:"menu_icon_dietarypreference")    
            break;
        case .Favorites:
            image = UIImage(named:"menu_icon_favoriterecipes")
            break;
        case .Invite:
            image = UIImage(named:"menu_icon_invitefriends")
            break;
        case .Rate:
            image = UIImage(named:"menu_icon_rateourapp")
            break;
        case .Feedback:
            image = UIImage(named:"menu_icon_feedback")
            break;
        case .About:
            image = UIImage(named:"menu_icon_aboutscoodit")
            break;
        }
        
        if let font = UIFont(name: "Montserrat", size: 14.16) {
            cell.textLabel!.font = font
        }

        cell.textLabel!.text = text.uppercased()
        cell.imageView?.image = image
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = menu_options[indexPath.row]
        
        switch (option) {
        case .Dietary:
            //dietary preferences
            let dietary_preferences_segue = "dietary_preferences_segue"
            self.performSegue(withIdentifier: dietary_preferences_segue, sender: self)
            break;
        case .Favorites:
            //favourite recipes
            let favorite_recipes_segue = "favorite_recipes_segue"
            self.performSegue(withIdentifier: favorite_recipes_segue, sender: self)
            break;
        case .Invite:
            //invite friends
            // send email
            
            let subject = "You have to try this awesome new App"
            var body = "Hey, <br />"
            
            body = body + "I just found this awesome recipe app for iPhone called <a href='<URL>'>Scoodit</a> and I think you'll love it too! <br /><br />"
            
            body = body + "Scoodit is the first cooking app with visual recognition: you take pictures of the ingredients and it tells you what you can cook! It's a great way to find recipe inspiration and also create shopping lists. \n"
            
            body = body + "You should definitely check it out <a href='<URL>'>here</a>. <br /><br />"
            
            body = body + "© Scoodit 2016"
            self.sendEmail(subject: subject, body: body)
            break;
        case .Rate:
            //rate our app
            let appId = ""
            let url_link = "itms-apps://itunes.apple.com/app/id\(appId)"
            
            let url = URL(string: url_link)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            break;
        case .Feedback:
            //we love feedback
            // send email
            let subject = "Feedback"
            let body = ""
            self.sendEmail(subject: subject, body: body)
            break;
        case .About:
            //about scoodit
            let aboutus_segue = "aboutUs_segue"
            self.performSegue(withIdentifier: aboutus_segue, sender: self)
            break;
        }

    }


}

extension MenuViewController: MFMailComposeViewControllerDelegate, MessageProtocol
{
    
    func sendEmail(subject:String, body: String){
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        self.presentMessage(message: "Email Sent!")
    }
    

}
