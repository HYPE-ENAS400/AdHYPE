//
//  FriendsTableViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class FriendsTableViewController: UIViewController, UsersCellDelegate{

    @IBOutlet weak var friendTableView: UITableView!
    
    var friends = KeyValueArrays()
    
    var adName: String!
    var captionText: String?
    var canPublish = false
    
    var recipientIDS = [String]()
    
    override func viewDidLoad() {
        friendTableView.dataSource = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER FOR SEND TO FRIENDS")
            return
        }
        
        if canPublish{
            friends.putPair((key: Constants.PUBLISHID, value: "Publish Caption"))
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERSNODE).child(user.uid).child(Constants.USERFRIENDSNODE)
        let query = ref.queryOrderedByValue()
        query.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let name = snapshot.value as? String{
                self.friends.putPair((key: snapshot.key, value: name))
                let newIndex = self.friends.getCount() - 1
                let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                self.friendTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            } else {
                print("Error getting username")
            }
        })
    }
    
    func onUserButtonClicked(isSelected: Bool, indexNumber: Int){
        if isSelected{
            recipientIDS.append(friends.getKeyAtIndex(indexNumber))
        } else {
            if let index = recipientIDS.indexOf(friends.getKeyAtIndex(indexNumber)){
                recipientIDS.removeAtIndex(index)
            }
        }
    }
    @IBAction func onSendButtonClicked(sender: AnyObject) {
//        let usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
//        
//        guard recipientIDS.count > 0 else {
//            return
//        }
//        
//        if recipientIDS[0] == Constants.PUBLISHID{
//            let commentRef = FIRDatabase.database().reference().child(Constants.ADSNODE).child(adName).child(Constants.ADCOMMENTSNODE).childByAutoId()
//            commentRef.child(Constants.ADCOMMENTTEXTNODE).setValue(captionText)
//            commentRef.child(Constants.ADCOMMENTVOTENODE).setValue(0)
//            recipientIDS.removeFirst()
//        }
//        
//        for i in recipientIDS{
//            let recRef = usersRef.child(i).child(Constants.ADQUEUENODE).childByAutoId()
//            recRef.child(Constants.ADNAMENODE).setValue(adName)
//            if let caption = captionText{
//                recRef.child(Constants.ADCOMMENTTEXTNODE).setValue(caption)
//            }
//        }

    }
    
    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        
    }
    
}

extension FriendsTableViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.getCount()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UsersCell
        
        cell.initCell(indexPath.row)
        if indexPath.row == 0 && canPublish{
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
        cell.userCell.text = friends.getValueAtIndex(indexPath.row)
        cell.delegate = self
        
        return cell
    }
}