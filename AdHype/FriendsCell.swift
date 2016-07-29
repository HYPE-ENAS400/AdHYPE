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
    
    private var user: User?
    
    weak var delegate: FriendsCellDelegate!
    
    func showCircleView(){
        confirmRequestButton.hidden = false
    }
    func hideCircleView(){
        confirmRequestButton.hidden = true
    }
    func getCellUser() -> User?{
        return user
    }
    func setCellUser(user: User?){
        self.user = user
        nameLabel.text = user?.userName
        fullNameLabel.text = user?.fullName
    }
    
    @IBAction func onFriendRequestAcceptedButtonClicked(sender: AnyObject) {
        delegate.onFriendRequestAccepted(user)
    }

}

protocol FriendsCellDelegate: class{
    func onFriendRequestAccepted(user: User?)
}
