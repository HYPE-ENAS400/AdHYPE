//
//  SettingsNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class SettingsNavVC: CustomNavVC, FriendsSettingsVCDelegate, DisplayMessageDelegate{
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var settingsNavVCContainerView: UIView!{
        didSet{
            super.containerView = settingsNavVCContainerView
        }
    }
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBOutlet weak var messageBar: UIView!
    @IBOutlet weak var messageBarLabel: UILabel!
    private var hiddenBarFrame: CGRect!
    private var visibleBarFrame: CGRect!
    
    
    var existingIDS: [String]?
    
    var userInterests: SelectionDataSource<Bool>!
    
    var userSettingsVC: UserSettingsVC?
    var friendsSettingsVC: FriendsSettingsVC?
    var helpSettingsVC: HelpSettingsVC?
    
    @IBOutlet weak var userUnderlineView: UIView!
    @IBOutlet weak var friendUnderlineView: UIView!
    @IBOutlet weak var helpUnderlineView: UIView!
    
    override func loadView() {
        super.loadView()
        
        var storyboard = UIStoryboard(name: "UserSettingsView", bundle: nil)
        userSettingsVC = storyboard.instantiateViewControllerWithIdentifier("userSettingsView") as? UserSettingsVC
        userSettingsVC?.messageDelegate = self
        userSettingsVC?.interestsDataSource = userInterests
        setActiveViewController(nil, viewController: userSettingsVC)
        
        storyboard = UIStoryboard(name: "FriendsSettingsView", bundle: nil)
        friendsSettingsVC = storyboard.instantiateViewControllerWithIdentifier("friendsSettingsView") as? FriendsSettingsVC
        friendsSettingsVC?.delegate = self
        friendsSettingsVC?.messageDelegate = self
        
        storyboard = UIStoryboard(name: "HelpSettingsView", bundle: nil)
        helpSettingsVC = storyboard.instantiateViewControllerWithIdentifier("helpSettingsView") as? HelpSettingsVC
        helpSettingsVC?.messageDelegate = self
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hiddenBarFrame = messageBar.frame
        visibleBarFrame = hiddenBarFrame
        visibleBarFrame.origin.y += hiddenBarFrame.size.height
    }
    
    func displayMessage(message: String, duration: Double){
        messageBarLabel.text = message
        self.messageBar.hidden = false
        let animateDuration = 0.2
        UIView.animateWithDuration(animateDuration, animations: {
            self.messageBar.frame = self.visibleBarFrame
        })
        delay(duration + animateDuration){
            UIView.animateWithDuration(animateDuration, animations: {
                self.messageBar.frame = self.hiddenBarFrame
                }, completion: {(succes) in
                    self.messageBar.hidden = true
            })
        }
    }
    
    
    @IBAction func onUserButtonClicked(sender: AnyObject) {
        if !isViewControllerActiveVC(userSettingsVC){
            userUnderlineView.hidden = false
            friendUnderlineView.hidden = true
            helpUnderlineView.hidden = true
            setActiveViewController(.toRight, viewController: userSettingsVC)
            transitionDirection = .toRight
        }
    }
    @IBAction func onFriendButtonClicked(sender: AnyObject) {
        if !isViewControllerActiveVC(friendsSettingsVC){
            friendUnderlineView.hidden = false
            helpUnderlineView.hidden = true
            userUnderlineView.hidden = true
            if isViewControllerActiveVC(userSettingsVC){
                setActiveViewController(.toLeft, viewController: friendsSettingsVC)
            } else{
                setActiveViewController(.toRight, viewController: friendsSettingsVC)
            }
        }
    }
    
    @IBAction func onHelpButtonClicked(sender: AnyObject) {
        if !isViewControllerActiveVC(helpSettingsVC){
            helpUnderlineView.hidden = false
            userUnderlineView.hidden = true
            friendUnderlineView.hidden = true
            setActiveViewController(.toLeft, viewController: helpSettingsVC)
        }
    }
    func onAddFriendClicked(existingFriendsAndRequestsIDS: [String]){
        existingIDS = existingFriendsAndRequestsIDS
        self.performSegueWithIdentifier("showUsersTableVC", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "showUsersTableVC" {
            if let ids = existingIDS{
                let newVC = segue.destinationViewController as! UserTableViewController
                newVC.existingFriendsIDS = ids
            }
        }
    }
    
    @IBAction func unwindFromUserTableViewSegue(segue: UIStoryboardSegue){
        existingIDS = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let friendDetachInfo = friendsSettingsVC?.friendDetachInfo{
            friendDetachInfo.ref.removeObserverWithHandle(friendDetachInfo.handle)
        }
        if let friendReqDetachInfo = friendsSettingsVC?.friendReqDetachInfo{
            friendReqDetachInfo.ref.removeObserverWithHandle(friendReqDetachInfo.handle)
        }
    }

}