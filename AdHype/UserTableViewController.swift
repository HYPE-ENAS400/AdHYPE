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
    
    var usersDataSource = SelectionDataSource<SelectionCellTextData>()
    var searchUsersDataSource = SelectionDataSource<SelectionCellTextData>()
    
    var userFullName: String?
    
    var friendsIDSToAdd = [String](){
        didSet{
            if friendsIDSToAdd.count == 0 {
                sendButton.enabled = false
            } else {
                sendButton.enabled = true
            }
        }
    }
    var existingFriendsIDS: [String]!
    var checkedIDSForNoSearch: [String]!
    
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
        searchController.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.view.tintColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)
        
        let baseRef = FIRDatabase.database().reference()
        
        let userFullNameRef = baseRef.child(Constants.USERNAMESNODE).child(user.displayName!).child(Constants.USERFULLNAME)
        userFullNameRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if let fn = snapshot.value as? String{
                self.userFullName = fn
            }
        })
        
        let sentReqRef = baseRef.child(Constants.USERSNODE).child(user.uid).child(Constants.SENTFRIENDREQUESTSNODE)
        sentReqRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: Bool]{
                for (id, _) in dict{
                    self.existingFriendsIDS.append(id)
                }
            }
            self.queryUsernames(baseRef.child(Constants.USERNAMESNODE))
        })
    
        
    }
    
    func queryUsernames(ref: FIRDatabaseReference){
        let query = ref.queryOrderedByKey()
        let friendQueryHandle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let dict = snapshot.value as? [String: String]{
                guard let id = dict[Constants.USERUID] else{
                    return
                }
                if !(self.existingFriendsIDS.contains(id)){
                    let fn = dict[Constants.USERFULLNAME]
                    let newTextData = SelectionCellTextData(main: snapshot.key, detail: fn)
                    self.usersDataSource.putPair((key: id, value: newTextData))
                    let newIndex = self.usersDataSource.getCount() - 1
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                } else {
                    print("Error loading user usernames")
                }
                
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
        searchController.active = false
        self.performSegueWithIdentifier("unwindFromUserTableViewSegue", sender: nil)
    }
    
    @IBAction func onSendButtonClicked(sender: AnyObject) {
        guard let user = FIRAuth.auth()?.currentUser else {
            print("could not get user when sending friend requests")
            return
        }
        
        var nameDict = [Constants.USERDISPLAYNAME: user.displayName!]
        if let fn = userFullName{
            nameDict[Constants.USERFULLNAME] = fn
        }
        
        for id in friendsIDSToAdd{
            let baseRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
            let ref = baseRef.child(id).child(Constants.USERFRIENDREQUESTSNODE)
            ref.child(user.uid).setValue(nameDict)
            
            let sentReqRef = baseRef.child(user.uid).child(Constants.SENTFRIENDREQUESTSNODE)
            sentReqRef.child(id).setValue(true)
        }
        
        searchController.active = false
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
            if let dict = snapshot.value as? [String: String]{
                guard let id = dict[Constants.USERUID] else{
                    return
                }
                if !(self.existingFriendsIDS.contains(id)){
                    let fn = dict[Constants.USERFULLNAME]
                    let newTextData = SelectionCellTextData(main: snapshot.key, detail: fn)
                    self.searchUsersDataSource.putPair((key: id, value: newTextData))
                    let newIndex = self.searchUsersDataSource.getCount() - 1
                    if self.friendsIDSToAdd.contains(id){
                        self.tableView.addPreselectedIndex(newIndex)
                    }
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            }
        })
        tableView.clearSelectedIndices()
        tableView.reloadData()
        queryDetachInfo = FIRDetachInfo(ref: ref, handle: handle)
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        if let info = queryDetachInfo{
            info.ref.removeObserverWithHandle(info.handle)
        }

        tableView.clearSelectedIndices()
        for id in friendsIDSToAdd{
            tableView.addPreselectedIndex(usersDataSource.getIndexOfPairForKey(id))
        }
        tableView.reloadData()
    }
}

extension UserTableViewController: SelectionTableViewDelegate{
    
    func isSearchActive() -> Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    func cellAtIndexSelected(index: Int) {
        if isSearchActive(){
            friendsIDSToAdd.append(searchUsersDataSource.getKeyAtIndex(index))
        } else{
            friendsIDSToAdd.append(usersDataSource.getKeyAtIndex(index))
        }
    }
    func cellAtIndexDeselected(index: Int) {
        var delID: String
        if isSearchActive(){
            delID = searchUsersDataSource.getKeyAtIndex(index)
        } else{
            delID = usersDataSource.getKeyAtIndex(index)
        }
        
        if let delIndex = friendsIDSToAdd.indexOf(delID){
            friendsIDSToAdd.removeAtIndex(delIndex)
        }
    }

    func getCellColorAtIndex(index: Int) -> UIColor? {
        return nil
    }
    func getNumberOfCells() -> Int {
        if isSearchActive() {
            return searchUsersDataSource.getCount()
        }
        return usersDataSource.getCount()
    }
    func getCellTextAtIndex(index: Int) -> SelectionCellTextData? {
        if isSearchActive(){
            return searchUsersDataSource.getValueAtIndex(index)
        }
        return usersDataSource.getValueAtIndex(index)
    }
}

