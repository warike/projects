//
//  VisualRecognitionExtension.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/20/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import Firebase

let add_ingredient_button = "add_ingredient_button"
let camera_tap_icon = "camera_tap_icon"




extension ManualViewController : AVCapturePhotoCaptureDelegate
{
    // AVCaptureSession init
    // assigning layout-ad-hoc
    // prsents a previewLayer
    
    
    @IBAction func openVisualRecognition(){
        self.hideKeyboard()
        self.setupSession()
        
        self.view.layer.addSublayer(previewLayer!)
        
        session.startRunning()
        let screenFrame = collectionView.frame
        
        self.previewLayer?.frame = screenFrame
        self.presentSnapButton()
        self.presentAddIngredientsButton()
        
        
        
        self.view.addSubview(self.buttonAddIngredients)
        self.view.bringSubview(toFront: self.buttonAddIngredients)
        
        self.view.addSubview(self.snapButton)
        self.view.bringSubview(toFront: self.snapButton)
        self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.snapIt)
        
    }

    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
    }
    
    func setupSession() {
        
        session = AVCaptureSession()
        
        if session.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
            session.sessionPreset =  AVCaptureSessionPresetPhoto
        }
        
        let camera = AVCaptureDevice
            .defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do { input = try AVCaptureDeviceInput(device: camera) } catch { return }
        
        
        output = AVCapturePhotoOutput()
        let AVCapurePhotoSettings = AVCapturePhotoSettings(format: [ AVVideoCodecKey: AVVideoCodecJPEG ])
        output.photoSettingsForSceneMonitoring = AVCapurePhotoSettings
        
        
        guard session.canAddInput(input)
            && session.canAddOutput(output) else { return }
        
        session.addInput(input)
        session.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.connection?.videoOrientation = .portrait
    }
    
    func presentSnapButton()
    {
        let screenFrame = collectionView.frame
        let w = (screenFrame.width/1.659)
        let h = (screenFrame.height/2.931)
        
        self.snapButton.setImage(UIImage(named: camera_tap_icon), for: UIControlState.normal)
        self.snapButton.frame = CGRect(x: screenFrame.width/5.4, y:screenFrame.height/2.3, width: w, height:h)
        self.snapButton.addTarget(self, action: #selector(ManualViewController.capturePhoto), for: .touchUpInside)
        
    }
    
    func presentAddIngredientsButton()
    {
        
        let screenFrame = collectionView.frame
        let buttonFrame = CGRect(x: (screenFrame.width/2)+17, y:screenFrame.origin.y+10, width: 150, height:50)
        self.buttonAddIngredients.setImage(UIImage(named: add_ingredient_button), for: UIControlState.normal)
        self.buttonAddIngredients.frame = buttonFrame
        self.buttonAddIngredients.addTarget(self, action: #selector(ManualViewController.closeOrCancelVisualRecognition), for: .touchUpInside)
        
        
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard photoSampleBuffer != nil && error == nil else { return }
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        
        guard let image = UIImage(data: imageData!) else { return }
        
        let image_name = ProcessInfo.processInfo.globallyUniqueString + ".png"
        let user_identification = FIRAuth.auth()?.currentUser?.email
        
        let picture_id = "\(user_identification!)/\(image_name)"
        
        //self.requestS3(with: imageData!, image: picture_id)
        
        self.ingredientSuggestions.removeAll()
        self.receivedCloudVisionRequest = false
        self.receivedClarifaiRequest = false
        
        
        LibraryAPI.sharedInstance.getIngredientsFromClarifai(picture: image, { (result) in
            DispatchQueue.main.async(execute: {
                self.receivedClarifaiRequest = true
                self.processVisualResult(results: result, picture_id: picture_id)
            })
            
        })
        
        self.receivedCloudVisionRequest = true
        /*
        LibraryAPI.sharedInstance.getIngredientsFromCloudVision(picture: image, {
            (result) in
            DispatchQueue.main.async(execute: {
                self.receivedCloudVisionRequest = true
                self.processVisualResult(results: result, picture_id: picture_id)
            })
        })*/
    }

    
    
    func processVisualResult(results: [String], picture_id: String){
        
        self.ingredientSuggestions = self.processResults(results: results)
        
        
        DispatchQueue.main.async (execute: { () -> Void in
            
            if self.ingredientSuggestions.count > 0 {
                if self.isSuggestionsDisplayed {
                    self.tableView.reloadData()
                }
                else{
                    self.presentVisualSuggestions()
                    self.isSuggestionsDisplayed = true
                }
            }else {
                if self.receivedCloudVisionRequest && self.receivedClarifaiRequest {
                    self.presentMessage(message: noMatchesMessage)
                }
                
            }
        })
    }
    
    func processResults(results: [String]) -> [Ingredient]
    {
        if receivedCloudVisionRequest && receivedClarifaiRequest {
            dismissActivity()
        }
        
        var matched_ingredients : [Ingredient] = []
        
        for suggestion in results {
            for var i in IngredientList{
                let exist = ingredientSuggestions.filter { $0._ID == i._ID }
                if exist.count == 0{
                    if i.text.caseInsensitiveCompare(suggestion.lowercased()) == .orderedSame {
                        i.isAvailable = true
                        matched_ingredients.append(i)
                        break
                        
                    }
                    else if i.pluralName.caseInsensitiveCompare(suggestion.lowercased()) == .orderedSame {
                        i.isAvailable = true
                        matched_ingredients.append(i)
                        break
                        
                    }
                    else if i.synonym.contains(where: { $0.caseInsensitiveCompare(suggestion.lowercased()) == .orderedSame}){
                        i.isAvailable = true
                        matched_ingredients.append(i)
                        break
                    }
                        
                    else if i.synonymPlural.contains(where: { $0.caseInsensitiveCompare(suggestion.lowercased()) == .orderedSame }) {
                        i.isAvailable = true
                        matched_ingredients.append(i)
                        break
                    }
                
                }
                
                
            }
        }
 
        return matched_ingredients
    }
    
    func closeOrCancelVisualRecognition()
    {
        
        DispatchQueue.main.async(execute: {
            self.session.stopRunning()
            self.buttonAddIngredients.removeFromSuperview()
            self.snapButton.removeFromSuperview()
            self.previewLayer?.removeFromSuperlayer()
            self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.addIt)
        })
        
        
    }
    
    
    
    
    func presentActivity()
    {
        
        if !self._activity.isAnimating {
            self._activity.startAnimating()
            
            let screenFrame = collectionView.frame
            let activityFrame = CGRect(x: 10, y:screenFrame.origin.y+25, width: self._activity.frame.width, height:self._activity.frame.height)
            
            self._activity.frame = activityFrame
            self.view.addSubview(self._activity)
            
            let loading_text = "identifying ingredient..."
            let loading_frame = CGRect(x: 35, y: collectionView.frame.origin.y+30, width: self._activity.frame.width, height:self._activity.frame.height)
            self._loadingText = UILabel(frame: loading_frame)
            self._loadingText?.text = loading_text
            self._loadingText?.textColor = .white
            self._loadingText?.font = UIFont.systemFont(ofSize: 9)
            self._loadingText?.sizeToFit()
            
            self.view.addSubview(self._loadingText!)
            
            self.view.bringSubview(toFront: self._activity)
            self.view.bringSubview(toFront: self._loadingText!)
        }
        
        
    }
    
    func dismissActivity()
    {
        self._activity.stopAnimating()
        self._activity.removeFromSuperview()
        self._loadingText?.removeFromSuperview()
    }
    
    func processImageCapured()
    {
        guard let connection = output.connection(withMediaType: AVMediaTypeVideo) else { return }
        connection.videoOrientation = .portrait
        let AVCapurePhotoSettings = AVCapturePhotoSettings(format: [ AVVideoCodecKey: AVVideoCodecJPEG ])
        output.photoSettingsForSceneMonitoring = AVCapurePhotoSettings
        output.capturePhoto(with: AVCapurePhotoSettings, delegate: self)
        /*
         */
        
        
    }
    
    func capturePhoto() {
        self.presentActivity()
        self.processImageCapured()
        
    }
    
    func presentVisualSuggestions()
    {
        self.presentSuggestions()
    }
    
    
    func requestS3(with data: Data, image: String) -> Void{
        
        
        
        let completion: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            DispatchQueue.main.async(execute: { if let _ = error {} })
        }
        let progressBlock: AWSS3TransferUtilityProgressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: { })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityUploadExpression()
        
        expression.progressBlock = progressBlock
        
        
        transferUtility.uploadData(data, bucket: S3BucketName, key: image, contentType: "image/png", expression: expression, completionHandler: completion).continueWith { (task) -> Any? in
            if let _ = task.error { }
            if let _ = task.result { }
            return nil;
        }
        
        
    }
    

}
