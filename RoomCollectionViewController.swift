//
//  RoomCollectionViewController.swift
//  iMessage
//
//  Created by Harold  on 6/20/16.
//  Copyright © 2016 Harold . All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage


class RoomCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var rooms = [Room]()

    override func viewDidLoad() {
        super.viewDidLoad()

        /*DataService.dataService.fetchDataFromServer{(room) in
            self.rooms.append(room)
            let indexPath = NSIndexPath(forItem: self.rooms.count - 1, inSection: 0)
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
        }*/
        DataService.dataService.ROOM_REF.observe(.childAdded, with: { (snapshot) -> Void in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            self.rooms.append(room)
            let indexPath = IndexPath(item: self.rooms.count - 1, section: 0)
            self.collectionView?.insertItems(at: [indexPath])
        
        })
        
    }

    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return rooms.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomCell", for: indexPath) as! RoomCollectionViewCell
        
        let room = rooms[(indexPath as NSIndexPath).row]
        cell.configureCell(room)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 5, height: view.frame.size.width/2 - 5)
    }

    @IBAction func logOut(_ sender: AnyObject) {
        let actionSheetController = UIAlertController(title: "Please Select", message: "Option To Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            print("Cancel")
        }
        let profileActionButton = UIAlertAction(title: "Profile", style: UIAlertActionStyle.default) { (action) in
        
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! ProfileTableViewController
            self.navigationController?.pushViewController(profileVC, animated: true)
        
        }
        actionSheetController.addAction(profileActionButton)
        actionSheetController.addAction(cancelActionButton)
        
        let logoutActionButton = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.default) { (action) in
            print("Log Out")
            self.logOutDidTapped()
        }
        actionSheetController.addAction(logoutActionButton)

        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func logOutDidTapped() {
        DataService.dataService.logOut()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatSegue" {
            let cell = sender as! RoomCollectionViewCell
            let indexPath = collectionView?.indexPath(for: cell)
            let room = rooms[(indexPath! as NSIndexPath).item]
            let chatViewController = segue.destination as! ChatViewController
            chatViewController.roomId = room.id
            
        }
    }
}
