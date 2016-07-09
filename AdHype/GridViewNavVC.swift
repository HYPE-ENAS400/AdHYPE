//
//  GridViewNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/29/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class GridViewNavVC: CustomNavVC{
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var friendUnderlineView: UIView!
    @IBOutlet weak var userUnderlineView: UIView!
    @IBOutlet weak var selectionBar: UIView!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var messageBarLabel: UILabel!
    @IBOutlet weak var messageBar: UIView!
    
    
    @IBOutlet weak var gridViewNavVCContainerView: UIView!{
        didSet{
            super.containerView = gridViewNavVCContainerView
        }
    }
    
    var userGridVC: GridViewController?
    var gridViewFriendsVC: GridViewFriendsVC?
    var friendGridVC: GridViewController?
    var delegate: GridViewControllerDelegate!
    
    var adjustmentWidth: CGFloat!
    private var hiddenBarFrame: CGRect!
    private var visibleBarFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        friendButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        adjustmentWidth = CGRectGetWidth(selectionBar.frame)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hiddenBarFrame = messageBar.frame
        visibleBarFrame = hiddenBarFrame
        visibleBarFrame.origin.y += hiddenBarFrame.size.height
        

    }
    
    @IBAction func onFriendButtonClicked(sender: AnyObject) {
        guard !isViewControllerActiveVC(gridViewFriendsVC) else {
            return
        }
        
        if gridViewFriendsVC == nil{
            let gridStoryboard = UIStoryboard(name: "Grid View", bundle: nil)
            gridViewFriendsVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewFriendsVC") as? GridViewFriendsVC
            gridViewFriendsVC?.delegate = self
        }
        
        setActiveViewController(.toLeft, viewController: gridViewFriendsVC)
        userUnderlineView.hidden = true
        friendUnderlineView.hidden = false
    }
    
    @IBAction func onUserButtonClicked(sender: AnyObject) {
        guard !isViewControllerActiveVC(userGridVC) else {
            return
        }
        setActiveViewController(.toRight, viewController: userGridVC)
        gridViewFriendsVC = nil
        userUnderlineView.hidden = false
        friendUnderlineView.hidden = true

    }
    
    @IBAction func onBackButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.25, delay: 0 , options: .CurveLinear, animations: {
            self.friendLabel.center.x += self.adjustmentWidth
            self.friendButton.center.x += self.adjustmentWidth
            self.userButton.center.x += self.adjustmentWidth
            self.backButton.center.x += self.adjustmentWidth
            
            }, completion: { finished in
                self.backButton.hidden = true
                self.friendLabel.hidden = true
                self.friendUnderlineView.hidden = false
                self.friendLabel.center.x -= self.adjustmentWidth
                self.backButton.center.x -= self.adjustmentWidth
        })
        setActiveViewController(.toRight, viewController: gridViewFriendsVC)
        friendGridVC?.detachGridViewListeners()
        friendGridVC = nil
    }
    
    func resetGridViewsOnDissapear(){
        if isViewControllerActiveVC(friendGridVC){
            friendButton.center.x += self.adjustmentWidth
            userButton.center.x += self.adjustmentWidth
        }
        userUnderlineView.hidden = false
        friendUnderlineView.hidden = true
        friendLabel.hidden = true
        backButton.hidden = true
        
        setActiveViewController(nil, viewController: nil)
        gridViewFriendsVC?.detachGridFriendListeners()
        gridViewFriendsVC = nil
        friendGridVC?.detachGridViewListeners()
        friendGridVC = nil

        
    }
    
}

extension GridViewNavVC: DisplayMessageDelegate{
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
}

extension GridViewNavVC: GridViewFriendsVCDelegate{
    
    func showGridViewForUID(uid: String){
        let gridStoryboard = UIStoryboard(name: "Grid View", bundle: nil)
        friendGridVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
        friendGridVC?.isFriendGrid = true
        friendGridVC?.messageDelegate = self
        friendGridVC?.delegate = delegate
        friendGridVC?.userID = uid
        setActiveViewController(.toLeft, viewController: friendGridVC)
    }
    
    
    func onGridFriendClicked(id: String, username: String) {
        friendLabel.center.x += adjustmentWidth
        backButton.center.x += adjustmentWidth
        friendLabel.text = username
        userUnderlineView.hidden = true
        friendUnderlineView.hidden = true
        friendLabel.hidden = false
        backButton.hidden = false
        UIView.animateWithDuration(0.25, delay: 0 , options: .CurveLinear, animations: {
            self.friendLabel.center.x -= self.adjustmentWidth
            self.friendButton.center.x -= self.adjustmentWidth
            self.userButton.center.x -= self.adjustmentWidth
            self.backButton.center.x -= self.adjustmentWidth
            
            }, completion: { finished in
                print("finished animation")
        })
        showGridViewForUID(id)
    }
}