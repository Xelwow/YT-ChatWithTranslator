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
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatTextFieldDelegate, YandexTranslatorDelegate {
    
    
    @IBOutlet weak var bubbleView : BubbleView!
    @IBOutlet weak var textField : ChatTextField!
    @IBOutlet weak var chatTableView : ChatTableView!
    var cellwasadded = false
    var didKeyboardAppeard = false
    var translator = YandexTranslator()
    var messages : [messageStruct] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendedMessage", for: indexPath) as! ChatCell
        
        /*
        if messages[indexPath.row].sendingdNotRecieved {
            cell = tableView.dequeueReusableCell(withIdentifier: "SendedMessage", for: indexPath) as! ChatCell
        }
        else {
             cell = tableView.dequeueReusableCell(withIdentifier: "RecievedMessage", for: indexPath) as! ChatCell
        }
        */
        cell.bubbleView.translatedTextLabel.text = messages[indexPath.row].translatedText
        cell.bubbleView.translatedTextLabel.sizeToFit()
        cell.bubbleView.originTextLabel.text = messages[indexPath.row].originText
        cell.bubbleView.originTextLabel.sizeToFit()
        cell.bubbleView.sizeToFit()
        cell.bubbleView.layer.cornerRadius = 8
        let inset = self.chatTableView.contentInset.top
        print(inset)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
        textField.delegate = self
        chatTableView.contentInset = UIEdgeInsets(top: chatTableView.frame.height, left: 0, bottom: 0, right: 0)
        chatTableView.delegate = self
        chatTableView.dataSource = self
        translator.delegate = self
        
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
    func getTranslation(origin : String, translation: String) {
        
        let message = messageStruct(origin: origin, translation: translation, sending: true)
        self.messages.append(message)
        cellwasadded = true
        self.chatTableView.beginUpdates()
        self.chatTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: UITableView.RowAnimation.none)
        self.chatTableView.endUpdates()
        self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        /*
        bubbleView.translatedTextLabel.text = translation
        bubbleView.translatedTextLabel.sizeToFit()
        bubbleView.originTextLabel.text = origin
        bubbleView.originTextLabel.sizeToFit()
        bubbleView.layer.cornerRadius = 4
        
        let y = textField.frame.origin.y - bubbleView.frame.height + textField.frame.height
        let x = textField.textField.frame.origin.x
        bubbleView.frame = CGRect(x: x, y: y, width: bubbleView.frame.width, height: bubbleView.frame.height)
        let x1 = 5
        let y1 = self.chatTableView.frame.origin.y + self.chatTableView.frame.height - bubbleView.frame.height
        view.addSubview(bubbleView)
        UIView.animate(withDuration: 0.2) {
            self.bubbleView.frame = CGRect(x: CGFloat(x1), y: y1, width: self.bubbleView.frame.width, height: self.bubbleView.frame.height)
            self.bubbleView.isHidden = false
            
        }
        bubbleView.removeFromSuperview()
        */
        
    }
    func sendMessage() {
        if textField.textField.text!.count == 0 { return }
        self.translator.translate(text: self.textField.textField.text!, hint: "ru")
    }
    func sendMessageAnimation(origin : String, translation: String){
        /*
        bubbleView.translatedTextLabel.text = translation
        bubbleView.translatedTextLabel.sizeToFit()
        bubbleView.originTextLabel.text = origin
        bubbleView.originTextLabel.sizeToFit()
        bubbleView.layer.cornerRadius = 4
        let cell = chatTableView.cellForRow(at: IndexPath(item: messages.count - 1 , section: 0)) as! ChatCell
        let y = textField.frame.origin.y - cell.frame.height + textField.frame.height
        let x = textField.textField.frame.origin.x
        bubbleView.frame = CGRect(x: x, y: y, width: cell.bubbleView.frame.width, height: cell.bubbleView.frame.height)
        let x1 = cell.bubbleView.frame.origin.x
        let y1 = self.chatTableView.frame.origin.y + self.chatTableView.frame.height - cell.frame.height
        view.addSubview(bubbleView)
        UIView.animate(withDuration: 0.2) {
            self.bubbleView.frame = CGRect(x: x1, y: y1, width: cell.bubbleView.frame.width, height: cell.bubbleView.frame.height)
            self.bubbleView.isHidden = false
            self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        }
        bubbleView.removeFromSuperview()
        */
    }

}

