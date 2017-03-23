//
//  DataService.swift
//  iMessage
//
//  Created by Harold  on 6/21/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

let roofRef = FIRDatabase.database().reference()

class DataService {
    
    static let dataService = DataService()
    
    
    fileprivate var _BASE_REF = roofRef
    fileprivate var _ROOM_REF = FIRDatabase.database().reference().child("rooms")
    fileprivate var _MESSAGE_REF = roofRef.child("messages")
    fileprivate var _PEOPLE_REF = roofRef.child("people")
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    var ROOM_REF: FIRDatabaseReference {
        return _ROOM_REF
    
    }
    var MESSAGE_REF: FIRDatabaseReference {
        return _MESSAGE_REF
    }
    var PEOPLE_REF: FIRDatabaseReference {
        return _PEOPLE_REF
    }
    
    var fileUrl: String!
    
    var currentUser: FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    func CreateNewRoom(_ user: FIRUser, caption: String, data: Data) {
        
        let filePath = "\(user.uid)/\(Int(Date.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.child(filePath).put(data, metadata: metaData) { (metaData, error) in
            if let error = error {
            //    print("Error Uploading: \(error.description)")
                return
            }
            
            // Creating a url for data (thumbnail image)
            self.fileUrl = metaData?.downloadURLs![0].absoluteString
            if let user = FIRAuth.auth()?.currentUser {
                let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                idRoom.setValue(["caption": caption, "thumbnailUrlFromStorage": self.storageRef.child(metaData!.path!).description, "fileUrl": self.fileUrl ])
            }
        }
        
    
    }
    
    func fetchDataFromServer (_ callback: @escaping (Room) -> ()) {
        DataService.dataService.ROOM_REF.observe(.childAdded, with: { (snapshot) in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            callback(room)
            
        })
    
    }
    
    
    //Sign Up function
    func SignUp (_ username: String, email: String, password: String, data: Data) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
            
            let filePath = "profileImage/\(user!.uid)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).put(data, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
             //       print("\(error.description)")
                    return
                }
                
                self.fileUrl = metadata?.downloadURLs![0].absoluteString
                
                let changeRequestPhoto = user?.profileChangeRequest()
                changeRequestPhoto?.photoURL = URL(string: self.fileUrl)
                changeRequestPhoto?.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else {
                        print("Profile Updated")
                    }
                })
                
                self.PEOPLE_REF.child((user?.uid)!).setValue(["username": username, "email": email, "profileImage": self.storageRef.child((metadata?.path)!).description])
                
                ProgressHUD.showSuccess("Succeeded.")
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            })
        })
        
    }
    
    
    // Implementing Log In
    func logIn(_ email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Succeeded")
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.login()
        })
        
    }
    
    
    // Implementing Log Out
    func logOut() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
            UIApplication.shared.keyWindow?.rootViewController = logInVC
        } catch let signOutError as NSError {
            print("Error Signing Out: \(signOutError)")
        }
    }
    
    //Update Profile
    func saveProfile(_ username: String, email: String, data: Data) {
        let user = FIRAuth.auth()?.currentUser
        let filePath = "\(user!.uid)/\(Int(Date.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        self.storageRef.child(filePath).put(data, metadata: metaData) { (metadata, error) in
            if let error = error {
              //  print("Error uploading editing: \(error.description)")
                return
            }
            self.fileUrl = metadata?.downloadURLs![0].absoluteString
            let changeRequestProfile = user?.profileChangeRequest()
            changeRequestProfile?.photoURL = URL(string: self.fileUrl)
            changeRequestProfile?.displayName = username
            changeRequestProfile?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    ProgressHUD.showError("Network Error")
                } else {
                    
                    
                }
            })
            
            if let user = user {
                
                user.updateEmail(email, completion: { (error) in
                    if let error = error {
                      //  print(error.description)
                    } else {
                        
                        print("email update")
                    }
                })
            }
            ProgressHUD.showSuccess("Saved")
            
            //NB This set enables profile picture to change in messaging when user edits and update profile
            self.PEOPLE_REF.child((user?.uid)!).setValue(["email": email, "profileImage": self.storageRef.child((metadata?.path)!).description, "username": username, "fileUrl": self.fileUrl])
        }
        
    }
    
    
    func CreateNewMessage(_ userId: String, roomId: String, textMessage: String) {
        let idMessage = roofRef.child("messages").childByAutoId()
        DataService.dataService.MESSAGE_REF.child(idMessage.key).setValue(["message": textMessage, "senderId": userId])
        DataService.dataService.ROOM_REF.child(roomId).child("messages").child(idMessage.key).setValue(true)
        
    }
    
    func fetchMessageFromServer(_ roomId: String, callback: @escaping (FIRDataSnapshot) -> ()) {
        DataService.dataService.ROOM_REF.child(roomId).child("messages").observe(.childAdded, with: {snapshot -> Void in
            DataService.dataService.MESSAGE_REF.child(snapshot.key).observe(.value, with: {
               
                
                snap -> Void in
                callback(snap)
                
            })
        })
        
    }

}
