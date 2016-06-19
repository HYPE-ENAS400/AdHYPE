//
//  SettingsViewController.swift
//  Hype-2
//
//  Created by max payson on 4/13/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate, FriendsCellDelegate, FriendsSectionCellDelegate{
    
    @IBOutlet weak var userIconOuterView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var delegate: SettingsViewControllerDelegate!
    
    var usersRef: FIRDatabaseReference!
    
    var oldUserName: String?
//    var uid: String?
    
    var friendRequests = KeyValueArrays()
    var friends = KeyValueArrays()
    
    override func viewDidLoad() {
        logOutButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        logOutButton.layer.shadowRadius = 4
        logOutButton.layer.shadowOpacity = 0.8
        logOutButton.layer.shadowOffset = CGSizeZero
        logOutButton.layer.shadowColor = UIColor.grayColor().CGColor
        
        usernameTextField.delegate = self
        
        userIconOuterView.layer.cornerRadius = (userIconOuterView.bounds.size.height/2)
        
        friendTableView.dataSource = self
        friendTableView.delegate = self
        friendTableView.allowsSelection = false
        let nib = UINib(nibName: "FriendsSectionCellView", bundle: nil)
        friendTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "friendsSectionHeader")

        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER OPENING SETTINGS")
            return
        }
        
        if let name = user.displayName{
            usernameTextField.text = name
            oldUserName = name
        }
        
        usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        let friendRequestQuery = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE).queryOrderedByValue()
        friendRequestQuery.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let name = snapshot.value as? String{
                self.friendRequests.putPair((key: snapshot.key, value: name))
                
                let curIndex = self.friendRequests.getCount() - 1
                let newIndexPath = NSIndexPath(forRow: curIndex, inSection: 0)
                self.friendTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                
            } else {
                print("error fetching friend requests")
            }
        })
        
        let friendsQuery = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE).queryOrderedByValue()
        friendsQuery.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) -> Void in
            if let name = snapshot.value as? String{
                self.friends.putPair((key: snapshot.key, value: name))
                let curIndex = self.friends.getCount() - 1
                let newIndexpath = NSIndexPath(forRow: curIndex, inSection: 1)
                
                //THERE WAS AN ERROR HERE
                self.friendTableView.insertRowsAtIndexPaths([newIndexpath], withRowAnimation: .Automatic)
            } else {
                print("error fetching friends")
            }
        })
        
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("closing first responder")
        return true
    }
    
    func updateUsername(name: String) {
        oldUserName = name
        
        if let user = FIRAuth.auth()?.currentUser{
            let changeRequest = user.profileChangeRequest()
            
            changeRequest.displayName = name
            changeRequest.commitChangesWithCompletion({error in
                if let error = error{
                    print("COULD NOT CHANGE USERNAME: \(error.localizedDescription)")
                } else {
                    print("successfully changed username")
                }
            })
            let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE).child(user.uid)
            ref.setValue(name)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let newName = textField.text
        if newName == oldUserName {
            return
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        let query = ref.queryEqualToValue(newName)
        query.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if let test = snapshot.value as? String{
                print("CHECK USERNAME IS RETURNING: \(test)")
                self.updateUsername(self.oldUserName!)
                self.usernameTextField.text = ""
                self.usernameTextField.placeholder = "username must be unique"
            }
        })
        
        updateUsername(newName!)
    }
    
    
    @IBAction func onSignOutClicked(sender: AnyObject){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.removeObjectForKey(Constants.PASSKEY)
        keychainWrapper.removeObjectForKey(Constants.USERKEY)
        
        try! FIRAuth.auth()!.signOut()
        
    }
    
    func onFriendRequestAccepted(info: (key: String, value: String)?){
        if let i = info{
            if let index = friendRequests.getIndexOfPairForKey((i.key)){
                if let user = FIRAuth.auth()?.currentUser{
                    
                    friendRequests.deletePairAtIndex(index)
                    friendTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
                    
                    //delete the friend request
                    let requestRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
                    requestRef.child(i.key).removeValue()
                    
                    //add the new friend to the user's friend list
                    let friendsRef = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE)
                    friendsRef.child(i.key).setValue(i.value)
                    
                    //add the user to the new friend's friend list
                    let newFriendsRef = usersRef.child(i.key).child(Constants.USERFRIENDSNODE)
                    newFriendsRef.child(user.uid).setValue(user.displayName)
                    
                }
            }
        }
    }
    
    func addFriendButtonClicked(){
        delegate.onAddFriendClicked(friends.getKeys())
    }

}

extension SettingsViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("friendsSectionHeader") as! FriendsSectionCell
        cell.delegate = self
        if section == 0 {
            cell.sectionLabel.text = "Friend Requests"
            cell.hideAddFriendButton()
        } else {
            cell.sectionLabel.text = "Friends"
            cell.showAddFriendButton()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            print("DELETE")
            
            guard let user = FIRAuth.auth()?.currentUser else {
                print("could not get current user")
                return
            }
            
            if indexPath.section == 0 {
                
                //delete the friend request
                let requestRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
                requestRef.child(friendRequests.getKeyAtIndex(indexPath.row)).removeValue()
                
                friendRequests.deletePairAtIndex(indexPath.row)
                
                
            } else {
                
                let friendID = friends.getKeyAtIndex(indexPath.row)
                
                //delete the friend from the user's list
                let friendsRef = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE)
                friendsRef.child(friendID).removeValue()
            
                //delete the user from the friend's list
                let newFriendsRef = usersRef.child(friendID).child(Constants.USERFRIENDSNODE)
                newFriendsRef.child(user.uid).removeValue()
                
                
                friends.deletePairAtIndex(indexPath.row)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

}

extension SettingsViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return friendRequests.getCount()
        } else {
            return friends.getCount()
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendsCell") as! FriendsCell
        cell.delegate = self
        if indexPath.section == 0{
            cell.showCircleView()
            cell.setFriendInfo(friendRequests.getPairAtIndex(indexPath.row))
        } else {
            cell.hideCircleView()
            cell.setFriendInfo(friends.getPairAtIndex(indexPath.row))
        }
        return cell
    }
}

protocol SettingsViewControllerDelegate{
    func onAddFriendClicked(existingFriendIDS: [String])
}


