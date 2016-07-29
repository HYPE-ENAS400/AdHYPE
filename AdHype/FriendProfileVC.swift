//
//  FriendProfileVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/29/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

enum Relationship{
    case Friends(NSIndexPath)
    case NotFriends
    case OutstandingRequest
}

class FriendProfileVC: UIViewController{

    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var userIconOuterView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var interestsButton: UIButton!
    @IBOutlet weak var interestsIndicator: UIView!
    @IBOutlet weak var friendsIndicator: UIView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    
    weak var messageDelegate: DisplayMessageDelegate!
    var userRelationship: Relationship!
    var user: User!
    
    var isFriendTVActive: Bool = false {
        didSet{
            if isFriendTVActive{
                friendsIndicator.hidden = false
                interestsIndicator.hidden = true
            } else {
                friendsIndicator.hidden = true
                interestsIndicator.hidden = false
            }
        }
    }
    
    var interestsDataSource: UserInterestStore!
    var friendStore: FriendStore!
    
    override func viewDidLoad() {
        
        usernameTextField.enabled = false
        usernameTextField.text = user.userName
        
        profileTableView.delegate = self
        profileTableView.dataSource = self

        initializeAppButtonLayer(logOutButton.layer)
        userIconOuterView.layer.cornerRadius = (userIconOuterView.bounds.size.height/2)
        
        switch userRelationship!{
        case .Friends:
            logOutButton.setTitle("Delete Friend", forState: .Normal)
        case .NotFriends:
            logOutButton.setTitle("Add Friend", forState: .Normal)
        case .OutstandingRequest:
            logOutButton.setTitle("Delete Request", forState: .Normal)
        }

    }
    
    func reloadInterestTVIfShould(){
        if isViewLoaded() && !isFriendTVActive{
            profileTableView.reloadData()
        }
    }
    
    deinit{
        print("PROFILE VC DEINIT")
    }
    
}

extension FriendProfileVC: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let interestInfo = interestsDataSource.getUserInterestEntryAtIndex(indexPath.row)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectionCell
        if interestInfo.isInterested{
            cell.cellDeselected()
            interestsDataSource.setIsInterestedInCategory(interestInfo.category, isInterested: false)
        } else {
            cell.cellSelected()
            interestsDataSource.setIsInterestedInCategory(interestInfo.category, isInterested: true)
        }
    }
}

extension FriendProfileVC: UITableViewDataSource{
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interestsDataSource.getUserInterestCount()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectionCell") as! SelectionCell
        let interestInfo = interestsDataSource.getUserInterestEntryAtIndex(indexPath.row)
        
        if interestInfo.isInterested {
            cell.initCell(true)
        } else {
            cell.initCell(false)
        }
        cell.mainLabel.text = interestInfo.category
        return cell
    }
}
