//
//  IJProgressExtension.swift
//  scoodit
//
//  Created by Sergio Cardenas on 4/21/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit

open class INotificationView {
    
    var containerView = UIView()
    var progressView = UIView()
    var notificactionView = UIImageView()
    var activityIndicator = UIActivityIndicatorView()
    var textLabel = UILabel()
    var timer = Timer()
    
    open class var shared: INotificationView {
        struct Static {
            static let instance: INotificationView = INotificationView()
        }
        return Static.instance
    }
    
    func showTextLoading(_ text:String){
        
        self.textLabel.text = text
        self.textLabel.textAlignment = NSTextAlignment.center
    
    }
    
    open func showInitLoading(_ view: UIView, text: String) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        
        progressView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        progressView.center = view.center
        progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()
        activityIndicator.center = CGPoint(x: (progressView.bounds.width / 2), y: (progressView.bounds.height / 2)-10)
        
        
        textLabel.textColor = UIColor.white
        textLabel.text = text
        
        textLabel.numberOfLines = 2
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        textLabel.frame.size.width = 170
        textLabel.sizeToFit()
        textLabel.center = CGPoint(x: activityIndicator.center.x, y: activityIndicator.center.y+35)
        
        
        
        progressView.addSubview(activityIndicator)
        progressView.addSubview(textLabel)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
    }
    
    
    @objc open func dissmissNotification(_ sender: UITapGestureRecognizer) {
        containerView.removeFromSuperview()
    }
    
    open func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
