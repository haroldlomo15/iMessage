//
//  CreateRoomViewController.swift
//  iMessage
//
//  Created by Harold  on 6/20/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateRoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var choosePhotoBtn: UIButton!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var captionLbl: UITextField!
    
    var selectedPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dismissKeyboard = UITapGestureRecognizer(target:  self, action: #selector(CreateRoomViewController.dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
        
    }

    func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func cancelDidTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhotoDidTapped(_ sender: AnyObject) {
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImg.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
        choosePhotoBtn.isHidden = true
    }
    
    @IBAction func createRoomDidTapped(_ sender: AnyObject) {
        
        var data: Data = Data()
        data = UIImageJPEGRepresentation(photoImg.image!, 0.1)!
        
        DataService.dataService.CreateNewRoom((FIRAuth.auth()?.currentUser)!, caption: captionLbl.text!, data: data)
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
