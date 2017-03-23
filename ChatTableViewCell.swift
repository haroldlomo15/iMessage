//
//  ChatTableViewCell.swift
//  iMessage
//
//  Created by Harold  on 6/25/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    func configCell(_ idUser: String, message: Dictionary<String, AnyObject>) {
        self.messageTextLabel.text = message["message"] as? String
        self.messageTextLabel.lineBreakMode = .byWordWrapping
        
        /*if let user = DataService.dataService.currentUser {
            if user.photoURL != nil {
                if let data = NSData(contentsOfURL: user.photoURL!) {
                    self.profileImageView.image = UIImage.init(data: data)
                }
            }
            
        }*/
        
        DataService.dataService.PEOPLE_REF.child(idUser).observe(.value, with: { snapshot -> Void in
            let dict = snapshot.value as! Dictionary<String, AnyObject>
            let imageUrl = dict["profileImage"] as! String
            if imageUrl.hasPrefix("gs://") {
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("Error Downloading: \(error)")
                        return
                    }
                    self.profileImageView.image = UIImage.init(data: data!)
                })
            }
            
        })

    }


}
