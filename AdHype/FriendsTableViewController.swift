//
//  FriendsTableViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class FriendsTableViewController: UIViewController{

    
    @IBOutlet weak var friendTableView: UITableView!
    
    var friendStore: FriendStore!

    @IBOutlet weak var sendButton: UIButton!
    var adMetaData: HypeAdMetaData!
    
    var captionText: String?
    var canPublish = false
    var publishSelected = false {
        didSet{
            if !publishSelected && recipientIDSet.count == 0 {
                sendButton.enabled = false
            } else {
                sendButton.enabled = true
            }
        }
    }
    
    var recipientIDSet = Set<String>() {
        didSet{
            if recipientIDSet.count == 0 {
                sendButton.enabled = false
            } else {
                sendButton.enabled = true
            }
        }
    }
    
    weak var delegate: FriendsTableViewControllerDelegate!
    
    override func viewDidLoad() {
    
        friendStore.attatchNewFriendListener(self)
        friendTableView.delegate = self
        friendTableView.dataSource = self
        
    }
    
    @IBAction func onSendButtonClicked(sender: AnyObject) {
        let usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        
        let user = FIRAuth.auth()?.currentUser
        let baseRef = FIRDatabase.database().reference()
        let timeStamp = String(Int(NSDate().timeIntervalSince1970))
        
        if publishSelected{
            let adRef = baseRef.child(Constants.PUBLICADCOMMENTS).child(adMetaData.key)
            
            let commentRef = adRef.child(Constants.ADCOMMENTSNODE).childByAutoId()
            
            commentRef.child(Constants.ADCOMMENTTEXTNODE).setValue(captionText)
            commentRef.child(Constants.ADCOMMENTVOTENODE).setValue(0)
            commentRef.child(Constants.ADCOMMENTTOTALVOTES).setValue(0)
            
            if let id = user?.uid{
                let aggregateUserCaptionsRef = baseRef.child(Constants.USERSNODE).child(id).child(Constants.AGGREGATEUSERCAPTIONS).child(adMetaData.key)
                aggregateUserCaptionsRef.child(timeStamp).setValue(captionText)
            }
            
        }
        let setCount = recipientIDSet.count
        guard setCount > 0 else{
            delegate.onSentToFriends()
            return
        }
        
        if let id = user?.uid{
            let aggregateSentRef = baseRef.child(Constants.USERSNODE).child(id).child(Constants.AGGREGATECARDSSENT).child(adMetaData.key)
            aggregateSentRef.child(timeStamp).setValue(setCount)
        }
        
        var caption: String?
        if let text = captionText{
            if let un = FIRAuth.auth()?.currentUser?.displayName{
                caption =  text + " -\(un)"
            }
        }
        
        let recipientIDs = Array(recipientIDSet)
        
        for id in recipientIDs{
            let recRef = usersRef.child(id).child(Constants.RECEIVEDADQUEUENODE).child(adMetaData.key)
            var dict = [Constants.ADNAMENODE: adMetaData.name, Constants.ADURLNODE: adMetaData.url, Constants.ADPRIMARYTAGNODE: adMetaData.primaryTag]
            if let text = caption{
                dict[Constants.ADCAPTIONNODE] = text
            }
            recRef.setValue(dict)
            
        }
        delegate.onSentToFriends()
    }
    
    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        delegate.onBackButtonClicked()
    }
    
    deinit{
        friendStore.detachNewFriendListener()
    }
    
}

extension FriendsTableViewController: FriendStoreDelegate{
    func onNewFriendLoaded(indexPath: NSIndexPath) {
        friendTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}

extension FriendsTableViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if canPublish && indexPath.section == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectionCell
            if publishSelected {
                publishSelected = false
                cell.cellDeselected()
            } else {
                publishSelected = true
                cell.cellSelected()
            }
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! DetailSelectionCell
            var adjPath: NSIndexPath
            if canPublish{
                adjPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)
            } else {
                adjPath = indexPath
            }
            
            guard let friend =  friendStore.getFriendAtIndexpath(adjPath) else {
                return
            }
            
            if recipientIDSet.contains(friend.key){
                cell.cellDeselected()
                recipientIDSet.remove(friend.key)
            } else {
                cell.cellSelected()
                recipientIDSet.insert(friend.key)
            }

        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if canPublish {
            return friendStore.getNumberOfSections() + 1
        }
        return friendStore.getNumberOfSections()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if canPublish && section == 0 {
            return nil
        } else if canPublish{
            return friendStore.getSectionHeaderAtIndex(section - 1)
        }
        return friendStore.getSectionHeaderAtIndex(section)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return friendStore.getSectionTitles()
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if canPublish && index == 0{
            return index
        }
        return friendStore.getSectionForSectionIndexTitle(title)
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView{
            view.textLabel!.textColor = UIColor(red: 131/255, green: 130/255, blue: 139/255, alpha: 1)
            view.textLabel?.font = UIFont.boldSystemFontOfSize(20)
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if canPublish && section == 0 {
            return 1
        } else if canPublish{
            return friendStore.getNumberOfItemsInSection(section - 1)
        }
        return friendStore.getNumberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if canPublish && indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("selectionCell") as! SelectionCell
            cell.mainLabel.text = "Publish"
            if publishSelected {
                cell.initCell(true)
            } else {
                cell.initCell(false)
            }
            return cell
            
        } else{
            let cell = tableView.dequeueReusableCellWithIdentifier("detailSelectionCell") as! DetailSelectionCell
            
            var adjPath: NSIndexPath
            if canPublish{
                adjPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)
            } else {
                adjPath = indexPath
            }
            
            if let friendInfo = friendStore.getFriendAtIndexpath(adjPath) {
                if recipientIDSet.contains(friendInfo.key){
                    cell.initCell(true)
                } else {
                    cell.initCell(false)
                }
                cell.mainLabel.text = friendInfo.userName
                cell.detailLabel.text = friendInfo.userName
            }
            return cell
        }
    }
}

protocol FriendsTableViewControllerDelegate: class{
    func onBackButtonClicked()
    func onSentToFriends()
}