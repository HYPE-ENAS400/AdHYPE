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

    
    @IBOutlet weak var friendTableView: SelectionTableView!
    
    var friends = SelectionDataSource<SelectionCellTextData>()
    
    var adMetaData: HypeAdMetaData!
    
    var captionText: String?
    var canPublish = false
    
    var recipientIDS = [String]()
    var delegate: FriendsTableViewControllerDelegate!
    var detachInfo: FIRDetachInfo!
    
    override func viewDidLoad() {
        
        friendTableView.selectionDelegate = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER FOR SEND TO FRIENDS")
            return
        }
        
        if canPublish{
            friends.putPair((key: Constants.PUBLISHID, value: SelectionCellTextData(main: "Publish", detail: nil)))
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERSNODE).child(user.uid).child(Constants.USERFRIENDSNODE)
        let query = ref.queryOrderedByValue()
        let handle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let nameDict = snapshot.value as? [String: String]{
                let un = nameDict[Constants.USERDISPLAYNAME]!
                let fn = nameDict[Constants.USERFULLNAME]
                let newNameData = SelectionCellTextData(main: un, detail: fn)
                self.friends.putPair((key: snapshot.key, value: newNameData))
                let newIndex = self.friends.getCount() - 1
                let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                self.friendTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            } else {
                print("Error getting username")
            }
        })
        detachInfo = FIRDetachInfo(ref: ref, handle: handle)
    }
    
    @IBAction func onSendButtonClicked(sender: AnyObject) {
        let usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        
        guard recipientIDS.count > 0 else {
            return
        }
        
        let user = FIRAuth.auth()?.currentUser
        let baseRef = FIRDatabase.database().reference()
        let timeStamp = String(Int(NSDate().timeIntervalSince1970))
        
        if let i = recipientIDS.indexOf(Constants.PUBLISHID){
        
            let adRef = baseRef.child(Constants.PUBLICADCOMMENTS).child(adMetaData.key)
            
            let commentRef = adRef.child(Constants.ADCOMMENTSNODE).childByAutoId()
            
            commentRef.child(Constants.ADCOMMENTTEXTNODE).setValue(captionText)
            commentRef.child(Constants.ADCOMMENTVOTENODE).setValue(0)
            commentRef.child(Constants.ADCOMMENTTOTALVOTES).setValue(0)
            
            if let id = user?.uid{
                let aggregateUserCaptionsRef = baseRef.child(Constants.USERSNODE).child(id).child(Constants.AGGREGATEUSERCAPTIONS).child(adMetaData.key)
                aggregateUserCaptionsRef.child(timeStamp).setValue(captionText)
            }
            
            recipientIDS.removeAtIndex(i)
        }
        
        guard recipientIDS.count > 0 else{
            return
        }
        
        if let id = user?.uid{
            let aggregateSentRef = baseRef.child(Constants.USERSNODE).child(id).child(Constants.AGGREGATECARDSSENT).child(adMetaData.key)
            aggregateSentRef.child(timeStamp).setValue(recipientIDS.count)
        }
        
        var caption: String?
        if let text = captionText{
            if let un = FIRAuth.auth()?.currentUser?.displayName{
                caption = "from: \(un): " + text
            }
        }
        
        for i in recipientIDS{
            print("RECIPIENT ID: \(i)")
            let recRef = usersRef.child(i).child(Constants.RECEIVEDADQUEUENODE).child(adMetaData.key)
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        detachInfo.ref.removeObserverWithHandle(detachInfo.handle)
    }
    
}

extension FriendsTableViewController: SelectionTableViewDelegate{
    
    func getNumberOfCells() -> Int {
        return friends.getCount()
    }
    func getCellColorAtIndex(index: Int) -> UIColor? {
        if canPublish && index == 0{
            return UIColor.groupTableViewBackgroundColor()
        }
        return nil
    }
    func getCellTextAtIndex(index: Int) -> SelectionCellTextData? {
        return friends.getValueAtIndex(index)
    }
    func cellAtIndexDeselected(index: Int) {
        if let delIndex = recipientIDS.indexOf(friends.getKeyAtIndex(index)){
            recipientIDS.removeAtIndex(delIndex)
        }
    }
    func cellAtIndexSelected(index: Int) {
        recipientIDS.append(friends.getKeyAtIndex(index))
    }
}

protocol FriendsTableViewControllerDelegate{
    func onBackButtonClicked()
    func onSentToFriends()
}