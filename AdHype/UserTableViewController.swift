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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var usersDataSource = SelectionDataSource<String>()
    var searchUsersDataSource = SelectionDataSource<String>()
    
    var friendsIDSToAdd = [String]()
    var existingFriendsIDS: [String]!
    
    var detachInfo: FIRDetachInfo?
    var queryDetachInfo: FIRDetachInfo?
    
    let nextCharDict = ["a": "b", "b": "c", "c": "d","d": "e","e": "f","f": "g","g": "h","h": "i","i": "j","j": "k","k": "l","l": "m","m": "n","n": "o","o": "p","p": "q","q": "r","r": "s","s": "t","t": "u","u": "v","v": "w","w": "x","x": "y","y": "z","z": "~",]
    
    override func viewDidLoad() {
        
        tableView.selectionDelegate = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error getting username")
            return
        }
        
        existingFriendsIDS.append(user.uid)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        let query = ref.queryOrderedByKey()
        let friendQueryHandle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let id = snapshot.value as? String{
//                if !(self.existingFriendsIDS.contains(id)) {
                    self.usersDataSource.putPair((key: id, value: snapshot.key))
                    let newIndex = self.usersDataSource.getCount() - 1
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
//                }
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

extension UserTableViewController: UISearchResultsUpdating, UISearchControllerDelegate{
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        guard searchText != "" else{
            return
        }
        if let info = queryDetachInfo{
            info.ref.removeObserverWithHandle(info.handle)
            searchUsersDataSource.clear()
        }

        let startText = searchText.lowercaseString
        print(startText)
        let lastChar = String(startText.characters.last!)
        var endText = String(startText.characters.dropLast())
        
        if let str = nextCharDict[lastChar]{
            endText.appendContentsOf(str)
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        
        let query = ref.queryOrderedByKey().queryStartingAtValue(startText).queryEndingAtValue(endText)
        let handle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)->Void in
            if let key = snapshot.value as? String{
                self.searchUsersDataSource.putPair((key: key, value: snapshot.key))
                self.tableView.reloadData()
            }
        })
        queryDetachInfo = FIRDetachInfo(ref: ref, handle: handle)
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        if let info = queryDetachInfo{
            info.ref.removeObserverWithHandle(info.handle)
        }
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
        if searchController.active && searchController.searchBar.text != "" {
            return searchUsersDataSource.getCount()
        }
        return usersDataSource.getCount()
    }
    func getCellTextAtIndex(index: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return searchUsersDataSource.getValueAtIndex(index)
        }
        return usersDataSource.getValueAtIndex(index)
    }
}

