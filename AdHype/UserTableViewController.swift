//
//  UserTableViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/18/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

enum FIRUserFilterResult{
    case Add(User)
    case DoNotAdd
}
enum CanAddQueryResults{
    case Yes(startValue: String?)
    case No
}

class UserTableViewController: UIViewController{
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var searchContainer: UIView!
    
    let QUERYLIMIT: Int = 20
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredUsers = [User]()
    var searchFilterString: String?
    var canAddQueryResults: CanAddQueryResults = .Yes(startValue: nil)
    
    var userFullName: String?
    
    var friendIDsToAddDict = [String: Bool](){
        didSet{
            if friendIDsToAddDict.count == 0 {
                sendButton.enabled = false
            } else {
                sendButton.enabled = true
            }
        }
    }
    var existingFriendsIDS: [String]!
    var checkedIDSForNoSearch: [String]!

    var queryDetachInfo: FIRDetachInfo?
    
    override func viewDidLoad() {
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("error getting username")
            return
        }
        
        existingFriendsIDS.append(user.uid)
        userTableView.delegate = self
        userTableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchContainer.addSubview(searchController.searchBar)
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
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self,
             selector: #selector(self.keyboardNotification(_:)),
             name: UIKeyboardWillChangeFrameNotification,
             object: nil)
        
    }
    private func shouldAddResultToUsers(userDict: [String: String], userName: String) -> FIRUserFilterResult{
    
        guard let id = userDict[Constants.USERUID] else {
            return .DoNotAdd
        }
        guard let searchString = searchFilterString else {
            return .DoNotAdd
        }
        
        if existingFriendsIDS.contains(id){
            return .DoNotAdd
        }
        if searchString == " " {
            let newUser = User(key: id, userName: userName, fullName: userDict[Constants.USERFULLNAME])
            return .Add(newUser)
        }

        if var fullName = userDict[Constants.USERFULLNAME] {
            fullName = fullName.lowercaseString
            if userName.containsString(searchString) || fullName.containsString(searchString){
                let newUser = User(key: id, userName: userName, fullName: fullName)
                return .Add(newUser)
            } else {
                return .DoNotAdd
            }
        } else {
            if userName.containsString(searchString) {
                let newUser = User(key: id, userName: userName, fullName: nil)
                return .Add(newUser)
            } else {
                return .DoNotAdd
            }
        }
        
    }
    
    func queryUsernames(startKey: String?){
        print("CALLED QUERY")
        var ref: FIRDatabaseReference
        var count: Int = 0
        
        if let info = queryDetachInfo{
            info.ref.removeObserverWithHandle(info.handle)
            ref = info.ref
        } else {
            ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE)
        }
        
        var query = ref.queryOrderedByKey().queryLimitedToFirst(UInt(QUERYLIMIT))
        if let sK = startKey{
            query = query.queryStartingAtValue(sK)
        }
        
        self.canAddQueryResults = .No
        
        let friendQueryHandle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            
            count += 1
            if count == self.QUERYLIMIT{
                self.canAddQueryResults = .Yes(startValue: snapshot.key)
                self.userTableView.reloadData()
                return
            }
            
            if let dict = snapshot.value as? [String: String]{
                
                if case let .Add(user) = self.shouldAddResultToUsers(dict, userName: snapshot.key){
                    self.filteredUsers.append(user)
                    let newIndex = self.filteredUsers.count - 1
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    self.userTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            } else {
                print("ERROR: Parsing user for add friend")
            }
        })
        queryDetachInfo = FIRDetachInfo(ref: ref, handle: friendQueryHandle)
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let detach = queryDetachInfo{
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
        
        searchController.active = false
        
        var nameDict = [Constants.USERDISPLAYNAME: user.displayName!]
        if let fn = userFullName{
            nameDict[Constants.USERFULLNAME] = fn
        }
        
        let recipientIDs = Array(friendIDsToAddDict.keys)
        
        for id in recipientIDs{
            let baseRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
            let ref = baseRef.child(id).child(Constants.USERFRIENDREQUESTSNODE)
            ref.child(user.uid).setValue(nameDict)
            
            let sentReqRef = baseRef.child(user.uid).child(Constants.SENTFRIENDREQUESTSNODE)
            sentReqRef.child(id).setValue(true)
            
        }
        
        self.performSegueWithIdentifier("unwindFromUserTableViewSegue", sender: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animateWithDuration(duration,
                   delay: NSTimeInterval(0),
                   options: animationCurve,
                   animations: { self.view.layoutIfNeeded() },
                   completion: nil)
        }
    }
    
}

extension UserTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DetailSelectionCell
        
        let id = filteredUsers[indexPath.row].key
        
        if friendIDsToAddDict[id] == true{
            cell.cellDeselected()
            friendIDsToAddDict.removeValueForKey(id)
        } else {
            cell.cellSelected()
            friendIDsToAddDict[id] = true
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailSelectionCell") as! DetailSelectionCell
        
        let userInfo = filteredUsers[indexPath.row]
        
        if friendIDsToAddDict[userInfo.key] == true{
            cell.initCell(true)
        } else {
            cell.initCell(false)
        }
        cell.mainLabel.text = userInfo.userName
        cell.detailLabel.text = userInfo.fullName
        return cell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (filteredUsers.count - indexPath.row) < 5{
            if case let .Yes(startValue: val) = canAddQueryResults{
                queryUsernames(val)
                print("CALLED QUERY FROM WILL SHOW")
            }
        }
    }
}

extension UserTableViewController: UISearchResultsUpdating, UISearchControllerDelegate{
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text!.lowercaseString
        
        guard searchText != "" && searchFilterString != searchText else{
            return
        }
        searchFilterString = searchText
        userTableView.hidden = false
        initialView.hidden = true
        filteredUsers.removeAll()
        userTableView.reloadData()
        queryUsernames(nil)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        userTableView.hidden = false
        initialView.hidden = true
    }
    
    func searchBarSearchButtonClicked( searchBar: UISearchBar!) {
        searchController.resignFirstResponder()
    }

    func didDismissSearchController(searchController: UISearchController) {
        if let info = queryDetachInfo{
            info.ref.removeObserverWithHandle(info.handle)
        }
        filteredUsers.removeAll()
        userTableView.reloadData()
        searchFilterString = nil
        userTableView.hidden = true
        initialView.hidden = false
    }
}



