//
//  GridViewFriendsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/30/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class GridViewFriendsVC: UIViewController{
    
    @IBOutlet weak var friendsTableView: UITableView!
    var friends = [(id: String, names: SelectionCellTextData)]()
    var delegate: GridViewFriendsVCDelegate!
    var detachInfo: FIRDetachInfo?
    @IBOutlet weak var noFriendsView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        let ref = FIRDatabase.database().reference().child(Constants.USERSNODE).child(getUserUID()).child(Constants.USERFRIENDSNODE)
        
        delay(1){
            if self.friends.isEmpty{
                self.noFriendsView.hidden = false
                self.friendsTableView.hidden = true
                self.spinner.stopAnimating()
            }
        }
        
        let query = ref.queryOrderedByChild(Constants.USERDISPLAYNAME)
        let handle = query.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            if let nameDict = snapshot.value as? [String: String]{
                
                self.friendsTableView.hidden = false
                self.noFriendsView.hidden = true
                self.spinner.stopAnimating()
                
                let un = nameDict[Constants.USERDISPLAYNAME]!
                let fn = nameDict[Constants.USERFULLNAME]
                let newTextData = SelectionCellTextData(main: un, detail: fn)
                self.friends.append((id: snapshot.key, names: newTextData))
                self.friendsTableView.reloadData()
            }
        })
        detachInfo = FIRDetachInfo(ref: ref, handle: handle)
    }
    func getUserUID()->String{
        return (FIRAuth.auth()?.currentUser?.uid)!
    }

    func detachGridFriendListeners(){
                if let info = detachInfo{
                    info.ref.removeObserverWithHandle(info.handle)
                }
    }
    
    deinit{
        print("FUCKING FRIENDS DEINIT")
    }
}

extension GridViewFriendsVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let info = friends[indexPath.row]
        delegate.onGridFriendClicked(info.id, username: info.names.main)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gridViewFriendCell") as! GridViewFriendCell
        let nameData = friends[indexPath.row].names
        cell.usernameLabel.text = nameData.main
        cell.fullnameLabel.text = nameData.detail
        return cell
    }
}

protocol GridViewFriendsVCDelegate{
    func onGridFriendClicked(id: String, username: String)
}