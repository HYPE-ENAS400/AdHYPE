//
//  FriendsSectionCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/18/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class FriendsSectionCell: UITableViewHeaderFooterView{
    
    weak var delegate: FriendsSectionCellDelegate!
    
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    
    func showAddFriendButton(){
        addFriendButton.hidden = false
        addFriendButton.layer.cornerRadius = (addFriendButton.layer.bounds.size.height/2)
        addFriendButton.layer.shadowOffset = CGSizeZero
        addFriendButton.layer.shadowRadius = 2
        addFriendButton.layer.shadowOpacity = 0.8
    }
    func hideAddFriendButton(){
        addFriendButton.hidden = true
    }
    func disableAddFriendButton(){
        addFriendButton.enabled = false
    }
    func enableAddFriendButton(){
        addFriendButton.enabled = true
    }
    
    @IBAction func onAddFriendButtonClicked(sender: AnyObject) {
        delegate.addFriendButtonClicked()
    }
    
}

protocol FriendsSectionCellDelegate: class{
    func addFriendButtonClicked()
}
