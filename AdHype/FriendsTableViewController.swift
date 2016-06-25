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
    
    var friends = SelectionDataSource<String>()
    
    var adName: String!
    var adKey: String!
    
    var captionText: String?
    var canPublish = false
    
    var recipientIDS = [String]()
    var delegate: FriendsTableViewControllerDelegate!
    
    override func viewDidLoad() {
        
        friendTableView.selectionDelegate = self
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER FOR SEND TO FRIENDS")
            return
        }
        
        if canPublish{
            friends.putPair((key: Constants.PUBLISHID, value: "Publish Caption"))
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERSNODE).child(user.uid).child(Constants.USERFRIENDSNODE)
        let query = ref.queryOrderedByValue()
        query.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let name = snapshot.value as? String{
                self.friends.putPair((key: snapshot.key, value: name))
                let newIndex = self.friends.getCount() - 1
                let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                self.friendTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            } else {
                print("Error getting username")
            }
        })
    }
    
    @IBAction func onSendButtonClicked(sender: AnyObject) {
        let usersRef = FIRDatabase.database().reference().child(Constants.USERSNODE)
        
        guard recipientIDS.count > 0 else {
            return
        }
        
        if recipientIDS[0] == Constants.PUBLISHID{
            let adRef = FIRDatabase.database().reference().child(Constants.PUBLICADCOMMENTS).child(adKey)
            
            //WHY WAS THIS HERE?
//            adRef.child(Constants.ADNAMENODE).setValue(adName)
            
            let commentRef = adRef.child(Constants.ADCOMMENTSNODE).childByAutoId()
            
            commentRef.child(Constants.ADCOMMENTTEXTNODE).setValue(captionText)
            commentRef.child(Constants.ADCOMMENTVOTENODE).setValue(0)
            recipientIDS.removeFirst()
        }
        
        for i in recipientIDS{
            let recRef = usersRef.child(i).child(Constants.RECEIVEDADQUEUENODE).child(adKey)
            recRef.child(Constants.ADNAMENODE).setValue(adName + ".jpg")
            if let caption = captionText{
                recRef.child(Constants.ADCAPTIONNODE).setValue(caption)
            }
            recRef.setPriority(Constants.FROMFRIENDPRIORITY)
        }
        delegate.onSentToFriends()
    }
    
    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        delegate.onBackButtonClicked()
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
    func getCellTextAtIndex(index: Int) -> String? {
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