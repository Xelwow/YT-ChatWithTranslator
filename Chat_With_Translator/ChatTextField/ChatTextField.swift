//
//  ChatTextField.swift
//  Chat_With_Translator
//
//  Created by Admin on 24/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct LanguageStruct {
    var placeholder = ""
    var locale = ""
    var lang = ""
    var recordingPlaceholder = ""
    
    init(placeholder: String, locale : String, lang : String, recordingPlaceholder : String) {
        self.placeholder = placeholder
        self.locale = locale
        self.lang = lang
        self.recordingPlaceholder = recordingPlaceholder
    }
}

protocol ChatTextFieldDelegate {
    func sendMessage()
}

class ChatTextField : UIView, UITextFieldDelegate, ChangeLanguageSwitchDelegate, CWTSpeechRecognizerDelegate {
    func getRecognizedText(recognized string: String) {
        textField.text = string
    }
    
    
    @IBOutlet weak var languageSwitch : ChangeLanguageSwitch!
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var actionButton : UIButton!
    @IBOutlet var view: UIView!
    
    var sendingNotRecording = false
    var stopNotStartRecording = false
    var languageChanged = false
    var speechRecognizer = CWTSpeechRecognizer()
    var delegate : ChatTextFieldDelegate?
    var firstLanguage = LanguageStruct(placeholder: "Русский", locale: "ru_RU", lang : "ru", recordingPlaceholder : "Говорите...")
    var secondLanguage = LanguageStruct(placeholder: "English", locale: "en-US", lang : "en", recordingPlaceholder : "Speak...")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
        
    }
    
    func getSelectedLanguage() -> String{
        if languageChanged {
           return secondLanguage.lang
        }
        else {
            return firstLanguage.lang
        }
    }
    
    private func setupTextField(){
        Bundle.main.loadNibNamed("ChatTextField", owner: self, options: nil)
        textField.attributedPlaceholder = NSAttributedString(string: firstLanguage.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)])
        self.layer.cornerRadius = 22.0
        view.layer.cornerRadius = 22.0
        addSubview(view)
        textField.delegate = self
        speechRecognizer?.CWTDelegate = self
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        languageSwitch.delegate = self
    }
    
    
    
    @IBAction func actionButtonTapped( sender : Any){
        if sendingNotRecording {
            delegate?.sendMessage()
            textField.text = ""
            changeImages()
            sendingNotRecording = false
            
        }
        else{
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            if stopNotStartRecording{
                AudioServicesPlaySystemSound(SystemSoundID(1114))
                speechRecognizer?.stopRecognition()
                stopNotStartRecording = false
                sendingNotRecording = true
                textField.attributedPlaceholder = NSAttributedString(string: languageChanged ? secondLanguage.placeholder : firstLanguage.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)])
                actionButton.setImage(UIImage(named: "Send"), for: .normal)
            }
            else{
                AudioServicesPlaySystemSound(SystemSoundID(1113))
                stopNotStartRecording = true
                textField.attributedPlaceholder = NSAttributedString(string: languageChanged ? secondLanguage.recordingPlaceholder : firstLanguage.recordingPlaceholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)])
                actionButton.setImage(UIImage(named: "VoiceRec"), for: .normal)
                speechRecognizer?.startRecognition(localiztion: (languageChanged ? secondLanguage.locale : firstLanguage.locale))
            }
        }
        
    }
    
    func LanguageChangeButtonTapped() {
        if languageChanged {
            self.view.backgroundColor = UIColor(red: 0.93, green: 0.3, blue: 0.36, alpha: 1)
            textField.attributedPlaceholder = NSAttributedString(string: firstLanguage.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)])
            languageChanged = false
            
        }
        else{
            self.view.backgroundColor = UIColor(red: 0, green: 0.49, blue: 0.91, alpha: 1)
            textField.attributedPlaceholder = NSAttributedString(string: secondLanguage.placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)])
            languageChanged = true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        sendingNotRecording = false
        changeImages()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.count != 0 { actionButtonTapped(sender: self) }
        
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var nextTextCount = 0
        if string.count == 0 {
            nextTextCount = textField.text!.count - 1
        }
        else{
            nextTextCount = textField.text!.count + string.count
        }
        if  sendingNotRecording && nextTextCount == 0{
            changeImages()
            sendingNotRecording = false
        }
        else{
            if !sendingNotRecording && nextTextCount > 0 {
                changeImages()
                sendingNotRecording = true
            }
        }
        return true
    }
    
  private func getTextInputMode() -> UITextInputMode{
        let languageLocale : String
        if languageChanged { languageLocale = secondLanguage.lang }
        else { languageLocale = firstLanguage.lang }
        for lngs in UITextInputMode.activeInputModes {
            if lngs.primaryLanguage!.contains(languageLocale){
                return lngs
            }
        }
        return super.textInputMode!
    }
    
    override var textInputMode: UITextInputMode? {
        return getTextInputMode()
    }
    
    func changeImages(){
        UIView.animate(withDuration: 0.2) {
            self.actionButton.frame = CGRect(x: self.actionButton.frame.origin.x, y: self.actionButton.frame.origin.y + 2, width: self.actionButton.frame.width
                , height: self.actionButton.frame.height - 4)
        }
        if self.sendingNotRecording {
            self.actionButton.setImage(UIImage(named: "Mic"), for: .normal)
        }
        else{
            self.actionButton.setImage(UIImage(named: "Send"), for: .normal)
        }
        UIView.animate(withDuration: 0.2) {
            self.actionButton.frame = CGRect(x: self.actionButton.frame.origin.x, y: self.actionButton.frame.origin.y - 2, width: self.actionButton.frame.width
                , height: self.actionButton.frame.height + 4)
        }
        
        
    }
}
