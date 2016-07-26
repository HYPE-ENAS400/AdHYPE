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
    var friendStore: FriendStore!
    var delegate: GridViewFriendsVCDelegate!
    var detachInfo: FIRDetachInfo?
    @IBOutlet weak var noFriendsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        if !friendStore.getHasFriends(){
            self.noFriendsView.hidden = false
            self.friendsTableView.hidden = true
        }
        
        friendStore.attatchNewFriendListener(self)
        

    }
    func getUserUID()->String{
        return (FIRAuth.auth()?.currentUser?.uid)!
    }

    func detachGridFriendListeners(){
        friendStore.detachNewFriendListener()
    }
    

}

extension GridViewFriendsVC: FriendStoreDelegate{
    func onNewFriendLoaded(indexPath: NSIndexPath) {
        friendsTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}

extension GridViewFriendsVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friendInfo =  friendStore.getFriendAtIndexpath(indexPath)
        if let info = friendInfo{
            delegate.onGridFriendClicked(info.key, username: info.userName)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendStore.getNumberOfSections()
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView{
            view.textLabel!.textColor = UIColor(red: 131/255, green: 130/255, blue: 139/255, alpha: 1)
            view.textLabel?.font = UIFont.boldSystemFontOfSize(20)
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return friendStore.getSectionHeaderAtIndex(section)
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return friendStore.getSectionTitles()
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return friendStore.getSectionForSectionIndexTitle(title)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendStore.getNumberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gridViewFriendCell") as! GridViewFriendCell
        let friendInfo = friendStore.getFriendAtIndexpath(indexPath)
        if let info = friendInfo{
            cell.usernameLabel.text = info.userName
            cell.fullnameLabel.text = info.userName
        }
        return cell
    }
}

protocol GridViewFriendsVCDelegate{
    func onGridFriendClicked(id: String, username: String)
}