//
//  SignUpViewController.swift
//  iMessage
//
//  Created by Harold  on 6/20/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.selectPhoto(_:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
       
    }

    func selectPhoto (_ tap: UITapGestureRecognizer) {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func CancelDidTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    
    }

    @IBAction func SignUpDidTapped(_ sender: AnyObject) {
        guard let email = emailTextField.text , !email.isEmpty, let password = passwordTextField.text , !password.isEmpty, let username = usernameTextField.text , !username.isEmpty else {
            return
        }
        var data = Data()
        data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
        
        // Signing Up
        
        ProgressHUD.show("Please Wait...", interaction: false)
        DataService.dataService.SignUp(username, email: email, password: password, data: data)
         
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

}
