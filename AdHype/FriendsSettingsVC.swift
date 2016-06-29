//
//  FriendsSettingsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class FriendsSettingsVC: UIViewController, FriendsCellDelegate, FriendsSectionCellDelegate{
    @IBOutlet weak var friendTableView: UITableView!
    
    var isAddFriendButtonDisabled = false
    var delegate: FriendsSettingsVCDelegate!
    
    var friendRequests = SelectionDataSource<SelectionCellTextData>()
    
    var friends = SelectionDataSource<SelectionCellTextData>()
    
    var friendReqDetachInfo: FIRDetachInfo?
    var friendDetachInfo: FIRDetachInfo?
    
    var usersRef: FIRDatabaseReference!
    var userFullName: String?
    var messageDelegate: DisplayMessageDelegate!
    var hasFriendRequests = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendTableView.dataSource = self
        friendTableView.delegate = self
        friendTableView.allowsSelection = false
        let nib = UINib(nibName: "FriendsSectionCellView", bundle: nil)
        friendTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "friendsSectionHeader")
        
        let user = (FIRAuth.auth()?.currentUser)!
        
        let userFullNameRef = FIRDatabase.database().reference().child(Constants.USERNAMESNODE).child(user.displayName!).child(Constants.USERFULLNAME)
        userFullNameRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if let fn = snapshot.value as? String{
                self.userFullName = fn
            }
        })
        
        usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        let friendRequestQueryRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
        let friendRequestQuery = friendRequestQueryRef.queryOrderedByValue()
        let friendReqHandle = friendRequestQuery.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            print(snapshot)
            self.hasFriendRequests = true
            if let nameDict = snapshot.value as? [String: String]{
                let un = nameDict[Constants.USERDISPLAYNAME]!
                let fn = nameDict[Constants.USERFULLNAME]
                let newTextData = SelectionCellTextData(main: un, detail: fn)
                self.friendRequests.putPair((key: snapshot.key, value: newTextData))
                self.friendTableView.reloadData()
                
            } else {
                print("error fetching friend requests")
            }
        })
        friendReqDetachInfo = FIRDetachInfo(ref: friendRequestQueryRef, handle: friendReqHandle)
        
        let friendsQueryRef = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE)
        let friendsQuery = friendsQueryRef.queryOrderedByValue()
        let friendHandle = friendsQuery.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            if let nameDict = snapshot.value as? [String: String]{
                let un = nameDict[Constants.USERDISPLAYNAME]!
                let fn = nameDict[Constants.USERFULLNAME]
                let newTextData = SelectionCellTextData(main: un, detail: fn)
                self.friends.putPair((key: snapshot.key, value: newTextData))
                let curIndex = self.friends.getCount() - 1
                var section = 0
                if self.hasFriendRequests{
                    section = 1
                }
                
                let newIndexpath = NSIndexPath(forRow: curIndex, inSection: section)
                //THERE WAS AN ERROR HERE
                self.friendTableView.insertRowsAtIndexPaths([newIndexpath], withRowAnimation: .Automatic)
            } else {
                print("error fetching friends")
            }
        })
        friendDetachInfo = FIRDetachInfo(ref: friendsQueryRef, handle: friendHandle)
    }
    
    func onFriendRequestAccepted(info: (key: String, value: SelectionCellTextData)?){
        if let i = info{
            if let index = friendRequests.getIndexOfPairForKey((i.key)){
                if let user = FIRAuth.auth()?.currentUser{
                    
                    messageDelegate.displayMessage("Friend request accepted!", duration: 1.5)
                    
                    friendRequests.deletePairAtIndex(index)
                    
                    friendTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
                    
                    //delete the friend request
                    let requestRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
                    requestRef.child(i.key).removeValue()
                    
                    //delete sent friend request from new friends account
                    let sentRequestRef = usersRef.child(i.key).child(Constants.SENTFRIENDREQUESTSNODE)
                    sentRequestRef.child(user.uid).removeValue()
                    
                    //add the new friend to the user's friend list
                    let friendsRef = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE)
                    friendsRef.child(i.key).setValue(convertSelectionCellTextDataToUserNamesDict(i.value))
                    
                    //add the user to the new friend's friend list
                    let newFriendsRef = usersRef.child(i.key).child(Constants.USERFRIENDSNODE)
                    var nameDict = [Constants.USERDISPLAYNAME: user.displayName!]
                    if let fullName = userFullName{
                        nameDict[Constants.USERFULLNAME] = fullName
                    }
                    newFriendsRef.child(user.uid).setValue(nameDict)
                }
            }
        }
    }
    
    func addFriendButtonClicked(){
        let existingFriendsAndRequests = friends.getKeys() + friendRequests.getKeys()
        delegate.onAddFriendClicked(existingFriendsAndRequests)
    }
    
}

extension FriendsSettingsVC: UITableViewDelegate{
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("friendsSectionHeader") as! FriendsSectionCell
        cell.delegate = self
        if section == 0 && hasFriendRequests{
            cell.sectionLabel.text = "Friend Requests"
            cell.hideAddFriendButton()
        } else {
            cell.sectionLabel.text = "Friends"
            cell.showAddFriendButton()
            if isAddFriendButtonDisabled{
                cell.disableAddFriendButton()
            }
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
            
            if indexPath.section == 0 && hasFriendRequests{
                
                //delete the friend request
                let friendReqID = friendRequests.getKeyAtIndex(indexPath.row)
                
                let requestRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
                requestRef.child(friendReqID).removeValue()
                
                let sentRequestRef = usersRef.child(friendReqID).child(Constants.SENTFRIENDREQUESTSNODE)
                sentRequestRef.child(user.uid).removeValue()
                
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

extension FriendsSettingsVC: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if hasFriendRequests{
            return 2
        }
        return 1

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && hasFriendRequests{
            return friendRequests.getCount()
        }
        return friends.getCount()

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendsCell") as! FriendsCell
        cell.delegate = self
        if indexPath.section == 0 && hasFriendRequests{
            cell.showCircleView()
            cell.setFriendInfo(friendRequests.getPairAtIndex(indexPath.row))
        } else {
            cell.hideCircleView()
            cell.setFriendInfo(friends.getPairAtIndex(indexPath.row))
        }
        return cell
    }
}

protocol FriendsSettingsVCDelegate{
    func onAddFriendClicked(existingFriendsAndRequestsIDS: [String])
}
