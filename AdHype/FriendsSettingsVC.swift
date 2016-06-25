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
    
    var friendRequests = SelectionDataSource<String>()
    var friends = SelectionDataSource<String>()
    
    var friendReqDetachInfo: FIRDetachInfo?
    var friendDetachInfo: FIRDetachInfo?
    
    var usersRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendTableView.dataSource = self
        friendTableView.delegate = self
        friendTableView.allowsSelection = false
        let nib = UINib(nibName: "FriendsSectionCellView", bundle: nil)
        friendTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "friendsSectionHeader")
        
        let user = (FIRAuth.auth()?.currentUser)!
        
        usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        let friendRequestQueryRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
        let friendRequestQuery = friendRequestQueryRef.queryOrderedByValue()
        let friendReqHandle = friendRequestQuery.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let name = snapshot.value as? String{
                self.friendRequests.putPair((key: snapshot.key, value: name))
                
                let curIndex = self.friendRequests.getCount() - 1
                let newIndexPath = NSIndexPath(forRow: curIndex, inSection: 0)
                self.friendTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                
            } else {
                print("error fetching friend requests")
            }
        })
        friendReqDetachInfo = FIRDetachInfo(ref: friendRequestQueryRef, handle: friendReqHandle)
        
        let friendsQueryRef = usersRef.child(user.uid).child(Constants.USERFRIENDSNODE)
        let friendsQuery = friendsQueryRef.queryOrderedByValue()
        let friendHandle = friendsQuery.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
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
        friendDetachInfo = FIRDetachInfo(ref: friendsQueryRef, handle: friendHandle)
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
        let existingFriendsAndRequests = friends.getKeys() + friendRequests.getKeys()
        delegate.onAddFriendClicked(existingFriendsAndRequests)
    }
    
}

extension FriendsSettingsVC: UITableViewDelegate{
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

extension FriendsSettingsVC: UITableViewDataSource{
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

protocol FriendsSettingsVCDelegate{
    func onAddFriendClicked(existingFriendsAndRequestsIDS: [String])
}
