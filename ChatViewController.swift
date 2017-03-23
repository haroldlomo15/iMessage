//
//  ChatViewController.swift
//  iMessage
//
//  Created by Harold  on 6/21/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

private struct Constant {
    static let cellIdMessageRecieved = "messageCellYou"
    static let cellIdMessageSent = "messageCellMe"
}
class ChatViewController: UIViewController, UITextViewDelegate {
    


    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var roomId: String!
    var messages: [FIRDataSnapshot] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.dataService.fetchMessageFromServer(roomId) { (snap) in
            self.messages.append(snap)
            print(self.messages)
            print("*********************************\(self.roomId)")    // 1

            self.tableView.reloadData()
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showOrHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showOrHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    

    func showOrHideKeyboard(_ notification: Notification) {
        if let keyboardInfo: Dictionary = (notification as NSNotification).userInfo {
            if notification.name == NSNotification.Name.UIKeyboardWillShow {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                    self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    // move to the last message
                    self.moveToLastMessage()
                }) 
            } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    // move to the last message
                    self.moveToLastMessage()
                }) 

                
            }
        }
        
    }
    func moveToLastMessage() {
        if self.tableView.contentSize.height > self.tableView.frame.height {
            let contentOfSet = CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height)
            self.tableView.setContentOffset(contentOfSet, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    @IBAction func sendButtonDidTapped(_ sender: AnyObject) {
        self.chatTextField.resignFirstResponder()
        if chatTextField.text != "" {
            if let user = FIRAuth.auth()?.currentUser {
                DataService.dataService.CreateNewMessage(user.uid, roomId: roomId, textMessage: chatTextField.text!)
            } else {
                // No user is signed in
                print("No user is signed in")

            }
            self.chatTextField.text = nil
        } else {
            print("error: Empty String")
        }
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageSnapshot = messages[(indexPath as NSIndexPath).row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        let messageId = message["senderId"] as! String
        if messageId == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellIdMessageSent, for: indexPath) as! ChatTableViewCell
            cell.configCell(messageId, message: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellIdMessageRecieved, for: indexPath) as! ChatTableViewCell
            cell.configCell(messageId, message: message)
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
}
