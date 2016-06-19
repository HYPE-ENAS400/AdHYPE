//
//  UsersCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/18/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell{
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var userCell: UILabel!
    var isUserSelected: Bool = false
    var delegate: UsersCellDelegate!
    var indexNumber: Int!
    
    func initCell(indexNumber: Int){
        self.indexNumber = indexNumber
        
        button.layer.cornerRadius = (button.layer.bounds.size.width/2)
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSizeZero
        button.layer.shadowOpacity = 0.8
    }
    
    @IBAction func onButtonClicked(sender: AnyObject) {
        if isUserSelected{
            isUserSelected = false

            button.backgroundColor = UIColor.whiteColor()
        } else {
            isUserSelected = true
            button.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1.0)
        }
        delegate.onUserButtonClicked(isUserSelected, indexNumber: indexNumber)
    }
    
}

protocol UsersCellDelegate{
    func onUserButtonClicked(isSelected: Bool, indexNumber: Int)
}