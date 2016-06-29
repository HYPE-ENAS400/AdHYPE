//
//  FriendsCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/17/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell{
    
    @IBOutlet weak var confirmRequestButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    private var friendInfo: (key: String, value: SelectionCellTextData)?
    
    var delegate: FriendsCellDelegate!
    
    func showCircleView(){
        confirmRequestButton.hidden = false
    }
    func hideCircleView(){
        confirmRequestButton.hidden = true
    }
    func getFriendInfo() -> (key: String, value: SelectionCellTextData)?{
        return friendInfo
    }
    func setFriendInfo(info: (key: String, value: SelectionCellTextData)){
        nameLabel.text = info.value.main
        fullNameLabel.text = info.value.detail
        friendInfo = info
    }
    
    @IBAction func onFriendRequestAcceptedButtonClicked(sender: AnyObject) {
        delegate.onFriendRequestAccepted(friendInfo)
    }

}

protocol FriendsCellDelegate{
    func onFriendRequestAccepted(info: (key: String, value: SelectionCellTextData)?)
}
