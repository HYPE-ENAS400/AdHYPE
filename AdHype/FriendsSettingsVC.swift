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
    weak var delegate: FriendsSettingsVCDelegate!
    
    var friendRequests = [User]()
    var friends: FriendStore!
    
    var friendReqDetachInfo: FIRDetachInfo?
    var friendDetachInfo: FIRDetachInfo?
    
    var usersRef: FIRDatabaseReference!
    var userFullName: String?
    weak var messageDelegate: DisplayMessageDelegate!
    var hasFriendRequests = false
    weak var userClickDelegate: UserClickDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendTableView.dataSource = self
        friendTableView.delegate = self
        
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
            
            if let nameDict = snapshot.value as? [String: String]{
                self.hasFriendRequests = true
                let un = nameDict[Constants.USERDISPLAYNAME]!
                let fn = nameDict[Constants.USERFULLNAME]
                let newUser = User(key: snapshot.key, userName: un, fullName: fn)
                self.friendRequests.append(newUser)
                self.friendTableView.reloadData()
                
            } else {
                print("error fetching friend requests")
            }
        })
        friendReqDetachInfo = FIRDetachInfo(ref: friendRequestQueryRef, handle: friendReqHandle)
        friends.attatchNewFriendListener(self)
    }
    
    func onFriendRequestAccepted(user: User?){
        
        if let u = user{
            if let currentUser = FIRAuth.auth()?.currentUser{
                guard let i = friendRequests.indexOf(u) else {
                    return
                }
                messageDelegate.displayMessage("Friend request accepted!", duration: 1.5)
                
                friendRequests.removeAtIndex(i)
                if friendRequests.count == 0 {
                    hasFriendRequests = false
                    friendTableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                } else{
                    friendTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: .Automatic)
                }
                
                
                //delete the friend request
                let requestRef = usersRef.child(currentUser.uid).child(Constants.USERFRIENDREQUESTSNODE)
                requestRef.child(u.key).removeValue()
                
                //delete sent friend request from new friends account
                let sentRequestRef = usersRef.child(u.key).child(Constants.SENTFRIENDREQUESTSNODE)
                sentRequestRef.child(currentUser.uid).removeValue()
                
                //add the new friend to the user's friend list
                var dict = [Constants.USERDISPLAYNAME: u.userName]
                if let fullName = u.fullName{
                    dict[Constants.USERFULLNAME] = fullName
                }
                let friendsRef = usersRef.child(currentUser.uid).child(Constants.USERFRIENDSNODE)
                friendsRef.child(u.key).setValue(dict)
                
                //add the user to the new friend's friend list
                let newFriendsRef = usersRef.child(u.key).child(Constants.USERFRIENDSNODE)
                var nameDict = [Constants.USERDISPLAYNAME: currentUser.displayName!]
                if let fullName = userFullName{
                    nameDict[Constants.USERFULLNAME] = fullName
                }
                newFriendsRef.child(currentUser.uid).setValue(nameDict)
            }

        }
    }
    
    func addFriendButtonClicked(){
        if hasFriendRequests{
            delegate.onAddFriendClicked(friendRequests)
        } else {
            delegate.onAddFriendClicked(nil)
        }
    }
    
    func detachFriendSettingsListeners(){
        if let reqInfo = friendReqDetachInfo{
            reqInfo.ref.removeObserverWithHandle(reqInfo.handle)
        }
        friends.detachNewFriendListener()
    }
    
    private func isRequestSection(section: Int) -> Bool{
        if section == 0 && hasFriendRequests {
            return true
        }
        return false
    }
    private func isFriendOrRequestSection(section: Int) -> Bool{
        if (hasFriendRequests && section < 2) || section == 0 {
            return true
        }
        return false
    }
    private func getAdjustedSection(section: Int)->Int{
        if hasFriendRequests{
            return section - 1
        }
        return section
    }
    
    deinit{
        print("FRIENDS SETTINGS VC DEINIT")
    }
    
}

extension FriendsSettingsVC: UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        userClickDelegate.onShowUserProfile(friends.getFriendAtIndexpath(indexPath))
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFriendOrRequestSection(section){
            return 50
        }
        return tableView.sectionHeaderHeight
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if isFriendOrRequestSection(section){
            let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("friendsSectionHeader") as! FriendsSectionCell
            cell.delegate = self
            if isRequestSection(section){
                cell.sectionLabel.text = "FriendRequests"
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
        return nil
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFriendOrRequestSection(section) {
            return nil
        }
        return friends.getSectionHeaderAtIndex(getAdjustedSection(section))
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if isFriendOrRequestSection(section){
            return
        }
        if let view = view as? UITableViewHeaderFooterView{
            view.textLabel!.textColor = UIColor(red: 131/255, green: 130/255, blue: 139/255, alpha: 1)
            view.contentView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
            view.textLabel?.font = UIFont.boldSystemFontOfSize(20)
        }
    }

    
    @available(iOS 8.0, *)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.onDeleteFriendorRequest(indexPath)
        })
        button1.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)
        
        return [button1]
    }
    
    func onDeleteFriendorRequest(indexPath: NSIndexPath) {
            
        guard let user = FIRAuth.auth()?.currentUser else {
            print("could not get current user")
            return
        }
        
        if isRequestSection(indexPath.section){
            
            //delete the friend request
            let friendReqID = friendRequests[indexPath.row].key
            
            let requestRef = usersRef.child(user.uid).child(Constants.USERFRIENDREQUESTSNODE)
            requestRef.child(friendReqID).removeValue()
            
            let sentRequestRef = usersRef.child(friendReqID).child(Constants.SENTFRIENDREQUESTSNODE)
            sentRequestRef.child(user.uid).removeValue()
            
            friendRequests.removeAtIndex(indexPath.row)
            if friendRequests.count == 0 {
                hasFriendRequests = false
                friendTableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            } else{
                friendTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            
            
        } else {
            let adjIndexpath = NSIndexPath(forRow: indexPath.row, inSection: getAdjustedSection(indexPath.section))
            friends.deleteFriendAtIndexPath(adjIndexpath)
            friendTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var titles = friends.getSectionTitles()
        titles.insert("F", atIndex: 0)
        if hasFriendRequests{
            titles.insert("R", atIndex: 0)
        }
        return titles
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if isFriendOrRequestSection(index){
            return(index)
        } else{
            return friends.getSectionForSectionIndexTitle(title)
        }
    }
}

extension FriendsSettingsVC: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if hasFriendRequests{
            return friends.getNumberOfSections() + 1
        }
        return friends.getNumberOfSections()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRequestSection(section){
            return friendRequests.count
        }
        return friends.getNumberOfItemsInSection(getAdjustedSection(section))

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendsCell") as! FriendsCell
        cell.delegate = self
        if isRequestSection(indexPath.section){
            cell.showCircleView()
            cell.setCellUser(friendRequests[indexPath.row])
        } else {
            cell.hideCircleView()
            let adjIndexPath = NSIndexPath(forRow: indexPath.row, inSection: getAdjustedSection(indexPath.section))
            cell.setCellUser(friends.getFriendAtIndexpath(adjIndexPath))
        }
        return cell
    }
}

extension FriendsSettingsVC: FriendStoreDelegate{
    func onNewFriendLoaded(indexPath: NSIndexPath) {
        friendTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}

protocol FriendsSettingsVCDelegate: class{
    func onAddFriendClicked(existingRequests: [User]?)
}
