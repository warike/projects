//
//  VoiceRecognitionExtension.swift
//  scoodit
//
//  Created by Sergio Esteban on 10/19/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import Speech
import Toaster



extension ManualViewController {
    
    func authRequest()
    {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in

            switch authStatus {
            case .authorized:
                self.isButtonEnabled = true
                
            case .denied:
                self.isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                self.isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = false
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil
            {
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal
            {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                if result != nil {
                    let resultTranscript = result?.bestTranscription.formattedString
                    self.processTranscipt(phrase: resultTranscript!)
                }
                
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do
        {
            try audioEngine.start()
        } catch
        {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    func processTranscipt(phrase: String)
    {
        let phrase = phrase == "^" ? "carrot" : phrase.lowercased()
        self.ingredientSuggestions.removeAll(keepingCapacity: true)
        if phrase != "" {
            let word_list = phrase.characters.split{$0 == " "}.map(String.init)
            
            let single_word_name_ingredients = IngredientList.filter { $0.text.characters.split{$0 == " "}.map(String.init).count == 1}
            let multiple_words_name_ingredients = IngredientList.filter { $0.text.characters.split{$0 == " "}.map(String.init).count > 1}
            
            for suggestion in word_list {
                for var i in single_word_name_ingredients{
                    let name = i.text
                    let plural_name = i.pluralName
                    
                    let name_comparison = (name.lowercased() == suggestion.lowercased())
                    let plural_comparison = (plural_name.lowercased() == suggestion.lowercased())
                    
                    if name_comparison || plural_comparison {
                        i.isAvailable = true
                        self.ingredientSuggestions.append(i)
                    }
                }
            }
            for var i in multiple_words_name_ingredients{
                let plural_name = i.pluralName.lowercased()
                let singular_name = i.text.lowercased()
                
                let singular_comparison = (phrase.lowercased().contains(singular_name))
                let plural_comparison = (phrase.lowercased().contains(plural_name))
                
                if plural_comparison || singular_comparison {
                    i.isAvailable = true
                    self.ingredientSuggestions.append(i)
                }
                
            }
            
            
        }
        if self.ingredientSuggestions.count > 0
        {
            self.presentVoiceSuggestions()
        }else
        {
            self.presentMessage(message: noMatchesMessage)
        }
        
    }
    
    @IBAction func didStartVoiceRecognition(sender: AnyObject)
    {
        
        self.tapGRecogStart = UITapGestureRecognizer(target:self, action:#selector(ManualViewController.didStartVoiceRecognition(sender:)))
        self.tapGRecogStop = UITapGestureRecognizer(target:self, action:#selector(ManualViewController.didStopVoiceRecognition(sender:)))
        
        self.voiceRecognitionView?.titleText.alpha = 0
        UIView.animate(withDuration: 0.1, animations: {
            AudioServicesPlaySystemSound(self.systemSoundIDStart)
            self.voiceRecognitionView?.imageMic.image = UIImage(named: "microphone_stop_recording_icon")
            self.voiceRecognitionView?.titleText.text = "Recording..."
            self.voiceRecognitionView?.titleText.alpha = 1
        })
        
        self.voiceRecognitionView?.imageMic.removeGestureRecognizer(self.tapGRecogStart!)
        self.voiceRecognitionView?.imageMic.addGestureRecognizer(self.tapGRecogStop!)
        
        self.runRecognition()

    }
    
    func runRecognition()
    {
        if audioEngine.isRunning {
            self.stopAudioEngine()
        }else{
            self.startRecording()
        }

    }
    
    
    func stopAudioEngine()
    {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    
    }
    
    func removeVoiceRecognitionModal()
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.voiceRecognitionView?.alpha = 0
        }) { (Bool) in
            self.voiceRecognitionView?.removeFromSuperview()
        }
    }
    
    @IBAction func didEndOrCancelVoiceRecognition(sender: AnyObject)
    {
        if audioEngine.isRunning {
            self.stopAudioEngine()
        }
        self.removeVoiceRecognitionModal()
        
        
        
    }
    @IBAction func didStopVoiceRecognition(sender: AnyObject)
    {
        
        self.tapGRecogStart = UITapGestureRecognizer(target:self, action:#selector(ManualViewController.didStartVoiceRecognition(sender:)))
        self.tapGRecogStop = UITapGestureRecognizer(target:self, action:#selector(ManualViewController.didStopVoiceRecognition(sender:)))
        
        self.voiceRecognitionView?.imageMic.removeGestureRecognizer(tapGRecogStop!)
        self.voiceRecognitionView?.imageMic.addGestureRecognizer(tapGRecogStart!)
        self.voiceRecognitionView?.titleText.alpha = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.voiceRecognitionView?.imageMic.image = UIImage(named: "microphone_icon")
            self.voiceRecognitionView?.titleText.text = "Press to turn on"
            self.voiceRecognitionView?.titleText.alpha = 1
            AudioServicesPlaySystemSound(self.systemSoundIDStop)
        })
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            startRecording()
        }
        
        
        
    }
    
    
    @IBAction func OpenVoiceRecognitionModal(sender: UIImageView)
    {
        self.hideKeyboard()
        let kWindow = UIApplication.shared.keyWindow
        let x = (kWindow?.frame.size.width)!
        let y = (kWindow?.frame.size.height)!
        
        self.tapGRecogStart = UITapGestureRecognizer(target:self, action:#selector(ManualViewController.didStartVoiceRecognition(sender:)))
        
        
        self.voiceRecognitionView = UIVoiceRecognitionView(frame: CGRect(x: 50, y: 0, width: 250 , height: 276))
        
        self.voiceRecognitionView?.center = CGPoint(x: (x/2), y: ((y/2)+10) )
        self.voiceRecognitionView?.imageMic.isUserInteractionEnabled = true
        self.voiceRecognitionView?.alpha = 0
        
        
        self.voiceRecognitionView?.btnExit.addTarget(self, action: #selector(ManualViewController.didEndOrCancelVoiceRecognition(sender:)), for: UIControlEvents.touchUpInside)
        self.voiceRecognitionView?.imageMic.addGestureRecognizer(self.tapGRecogStart!)

        kWindow?.addSubview(self.voiceRecognitionView!)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.voiceRecognitionView?.alpha = 1
            }, completion: nil)
        
    }
    
    func presentVoiceSuggestions()
    {
        self.voiceRecognitionView?.removeAllSubViews()
        self.voiceRecognitionView?.imageMic.removeGestureRecognizer(tapGRecogStop!)
        self.voiceRecognitionView?.imageMic.removeGestureRecognizer(tapGRecogStart!)
        self.voiceRecognitionView?.removeFromSuperview()
        
        self.presentSuggestions()
        
    }
    
    
    
}
