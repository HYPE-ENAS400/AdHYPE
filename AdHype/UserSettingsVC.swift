//
//  UserSettingsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsVC: UIViewController{
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userIconOuterView: UIView!
    @IBOutlet weak var interestsTableView: UITableView!
    
    weak var messageDelegate: DisplayMessageDelegate!
    
    var interestsDataSource: UserInterestStore!
    
    override func viewDidLoad() {
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER OPENING SETTINGS")
            return
        }
        
        usernameTextField.enabled = false
        if let name = user.displayName{
            usernameTextField.text = name
        }
        initializeAppButtonLayer(logOutButton.layer)
        userIconOuterView.layer.cornerRadius = (userIconOuterView.bounds.size.height/2)
     
        interestsTableView.delegate = self
        interestsTableView.dataSource = self
    }
    
    
    @IBAction func onSignOutClicked(sender: AnyObject) {
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.removeObjectForKey(Constants.PASSKEY)
        keychainWrapper.removeObjectForKey(Constants.USERKEY)
        
        try! FIRAuth.auth()!.signOut()
    }
}

extension UserSettingsVC: UITableViewDelegate{
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

extension UserSettingsVC: UITableViewDataSource{
    
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


