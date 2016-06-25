//
//  UserTableViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/18/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewController: UIViewController{

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tableView: SelectionTableView!
    @IBOutlet weak var searchBarContainer: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var usersDataSource = SelectionDataSource<String>()
    
    var friendsIDSToAdd = [String]()
    var existingFriendsIDS: [String]!
    
    var detachInfo: FIRDetachInfo?
    
    override func viewDidLoad() {
        
        tableView.selectionDelegate = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error getting username")
            return
        }
        
        existingFriendsIDS.append(user.uid)
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        let query = ref.queryOrderedByKey()
        let friendQueryHandle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let id = snapshot.value as? String{
                if !(self.existingFriendsIDS.contains(id)) {
                    self.usersDataSource.putPair((key: id, value: snapshot.key))
                    let newIndex = self.usersDataSource.getCount() - 1
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            } else {
                print("Error loading user usernames")
            }
        })
        detachInfo = FIRDetachInfo(ref: ref, handle: friendQueryHandle)
        
    }
    override func viewDidDisappear(animated: Bool) {
        if let detach = detachInfo{
            detach.ref.removeObserverWithHandle(detach.handle)
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

extension UserTableViewController: SelectionTableViewDelegate{
    
    func cellAtIndexSelected(index: Int) {
        friendsIDSToAdd.append(usersDataSource.getKeyAtIndex(index))
    }
    func cellAtIndexDeselected(index: Int) {
        if let delIndex = friendsIDSToAdd.indexOf(usersDataSource.getKeyAtIndex(index)){
            friendsIDSToAdd.removeAtIndex(delIndex)
        }
    }
    func getCellColorAtIndex(index: Int) -> UIColor? {
        return nil
    }
    func getNumberOfCells() -> Int {
        return usersDataSource.getCount()
    }
    func getCellTextAtIndex(index: Int) -> String? {
        return usersDataSource.getValueAtIndex(index)
    }
}

