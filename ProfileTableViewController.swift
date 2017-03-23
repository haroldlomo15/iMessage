//
//  ProfileTableViewController.swift
//  iMessage
//
//  Created by Harold  on 6/20/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "EDIT PROFILE"
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        
        if let user = DataService.dataService.currentUser {
            username.text = user.displayName
            email.text = user.email
            if user.photoURL != nil {
                if let data = try? Data(contentsOf: user.photoURL!) {
                    self.profileImage.image = UIImage.init(data: data)
                }
            }
            
        } else {
            //No user is signed in
            
        }
        
    }

    func selectPhoto(_ tap: UITapGestureRecognizer) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // ImagePicker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveDidTapped(_ sender: AnyObject) {
        var data = Data()
        data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
        ProgressHUD.show("Please Wait...", interaction: false)
        DataService.dataService.saveProfile(username.text!, email: email.text!, data: data)
    }
    
}
