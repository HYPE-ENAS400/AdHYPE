//
//  UserTableViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/18/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewController: UIViewController, UsersCellDelegate{

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var users = KeyValueArrays()
    
    var friendsIDSToAdd = [String]()
    var existingFriendsIDS: [String]!
    
    override func viewDidLoad() {
        
        tableView.dataSource = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error getting username")
            return
        }
        
        existingFriendsIDS.append(user.uid)
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        let query = ref.queryOrderedByValue()
        query.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let name = snapshot.value as? String{
                if !(self.existingFriendsIDS.contains(snapshot.key)) {
                    self.users.putPair((key: snapshot.key, value: name))
                    let newIndex = self.users.getCount() - 1
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            } else {
                print("Error getting username")
            }
        })
    }
    
    func onUserButtonClicked(isSelected: Bool, indexNumber: Int){
        if isSelected{
            friendsIDSToAdd.append(users.getKeyAtIndex(indexNumber))
        } else{
            if let delIndex = friendsIDSToAdd.indexOf(users.getKeyAtIndex(indexNumber)){
                friendsIDSToAdd.removeAtIndex(delIndex)
            }
        }
    }
    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindFromUserTableViewSegue", sender: nil)
    }
    
    @IBAction func onSendButtonClicked(sender: AnyObject) {
        guard let user = FIRAuth.auth()?.currentUser else {
            print("could not get user when sending friend requests")
            return
        }
        for id in friendsIDSToAdd{
            let ref = FIRDatabase.database().reference().child(Constants.USERSNODE).child(id).child(Constants.USERFRIENDREQUESTSNODE)
            ref.child(user.uid).setValue(user.displayName)
        }
        self.performSegueWithIdentifier("unwindFromUserTableViewSegue", sender: nil)
    }
}

extension UserTableViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.getCount()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UsersCell
        cell.initCell(indexPath.row)
        cell.userCell.text = users.getValueAtIndex(indexPath.row)
        cell.delegate = self
        
        return cell
    }
}

