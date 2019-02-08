//
//  ViewController.swift
//  Chat_With_Translator
//
//  Created by Admin on 23/01/2019.
//  Copyright © 2019 xelwow98. All rights reserved.
//

import UIKit

struct messageStruct {
    var originText = ""
    var translatedText = ""
    var sendingdNotRecieved = true
    
    init(origin : String, translation : String, sending : Bool){
        self.originText = origin
        self.translatedText = translation
        self.sendingdNotRecieved = sending
    }
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatTextFieldDelegate, YandexTranslatorDelegate {
    
    @IBOutlet weak var textField : ChatTextField!
    @IBOutlet weak var chatTableView : UITableView!
    var cellwasadded = false
    var didKeyboardAppeard = false
    var translator = YandexTranslator(ApiKey: "YOUR-API-KEY")
    var messages : [messageStruct] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messages[indexPath.row].sendingdNotRecieved ? tableView.dequeueReusableCell(withIdentifier: "SendedMessage", for: indexPath) as! ChatCell : tableView.dequeueReusableCell(withIdentifier: "RecievedMessage", for: indexPath) as! ChatCell
        
        
        
        cell.bubbleView.originTextLabel.text = messages[indexPath.row].originText
        cell.bubbleView.originTextLabel.sizeToFit()
        cell.bubbleView.translatedTextLabel.text = messages[indexPath.row].translatedText
        cell.bubbleView.translatedTextLabel.sizeToFit()
        
        cell.bubbleView.layer.cornerRadius = 16
        //Баг с перерисовкой
        /*
        let botCorner = messages[indexPath.row].sendingdNotRecieved ? UIRectCorner.bottomRight : .bottomLeft
        
        let maskPath = UIBezierPath(roundedRect: cell.bubbleView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight, botCorner],
                                    cornerRadii: CGSize(width: 16.0, height: 0.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        cell.bubbleView.layer.mask = maskLayer
        */
        cell.bubbleView.sizeToFit()
        
        let inset = self.chatTableView.contentInset.top
        if inset != 0 && cellwasadded {
            let newTopInset = inset - cell.frame.height
            self.chatTableView.contentInset = UIEdgeInsets(top: newTopInset > 0 ? newTopInset : 0, left: 0, bottom: 0, right: 0)
            cellwasadded = false
        }
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
        textField.delegate = self
        chatTableView.contentInset = UIEdgeInsets(top: chatTableView.frame.height, left: 0, bottom: 0, right: 0)
        chatTableView.delegate = self
        chatTableView.dataSource = self
        translator.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let message = messageStruct(origin: "Привет! Как дела?", translation: "Hi! How's it going?", sending: false)
        showMessage(message: message)
    }
    
    @objc func keyboardWillAppear(notification : Notification){
        if didKeyboardAppeard == true {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            textField.frame.origin.y -= keyboardSize.height
            chatTableView.frame = CGRect(x: chatTableView.frame.origin.x, y: chatTableView.frame.origin.y, width: chatTableView.frame.width, height: chatTableView.frame.height - keyboardSize.height)
            didKeyboardAppeard = true
            if messages.count != 0 {
                self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
            
        }
    }
    @objc private func keyboardWillDisappear(notification : Notification){
        if didKeyboardAppeard == false {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            textField.frame.origin.y += keyboardSize.height
            chatTableView.frame = CGRect(x: chatTableView.frame.origin.x, y: chatTableView.frame.origin.y, width: chatTableView.frame.width, height: chatTableView.frame.height + keyboardSize.height)
            didKeyboardAppeard = false
        }
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func showMessage(message : messageStruct){
        self.messages.append(message)
        cellwasadded = true
        self.chatTableView.beginUpdates()
        self.chatTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: UITableView.RowAnimation.none)
        self.chatTableView.endUpdates()
        self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    func getTranslation(origin : String, translation: String) {
        let message = messageStruct(origin: origin, translation: translation, sending: true)
        showMessage(message: message)
    }
    func sendMessage() {
        if textField.textField.text!.count == 0 { return }
        self.translator.translate(text: textField.textField.text!, hint: "ru")
    }

}

