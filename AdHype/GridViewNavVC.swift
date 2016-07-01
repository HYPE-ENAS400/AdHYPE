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
    
    
    var gridStoryboard: UIStoryboard!
    
    var userGridVC: GridViewController?
    var gridViewFriendsVC: GridViewFriendsVC?
    var friendGridVC: GridViewController?
    
    var adjustmentWidth: CGFloat!
    private var hiddenBarFrame: CGRect!
    private var visibleBarFrame: CGRect!
    
    var delegate: GridViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        userButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        friendButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        gridStoryboard = UIStoryboard(name: "Grid View", bundle: nil)
        userGridVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
        userGridVC?.userID = userID
        userGridVC?.messageDelegate = self
        userGridVC?.delegate = delegate
        setActiveViewController(nil, viewController: userGridVC)
        
        adjustmentWidth = CGRectGetWidth(selectionBar.frame)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hiddenBarFrame = messageBar.frame
        visibleBarFrame = hiddenBarFrame
        visibleBarFrame.origin.y += hiddenBarFrame.size.height
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        friendLabel.center.x += adjustmentWidth
        backButton.center.x += adjustmentWidth
    }
    
    @IBAction func onFriendButtonClicked(sender: AnyObject) {
        guard !isViewControllerActiveVC(gridViewFriendsVC) else {
            return
        }
        
        gridViewFriendsVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewFriendsVC") as? GridViewFriendsVC
        gridViewFriendsVC?.delegate = self
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
        })
        setActiveViewController(.toRight, viewController: gridViewFriendsVC)
        friendGridVC = nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if !isViewControllerActiveVC(friendGridVC){
            friendLabel.center.x -= adjustmentWidth
            backButton.center.x -= adjustmentWidth
        } else {
            friendButton.center.x += self.adjustmentWidth
            userButton.center.x += self.adjustmentWidth
        }
        userUnderlineView.hidden = false
        friendUnderlineView.hidden = true
        setActiveViewController(nil, viewController: userGridVC)
        gridViewFriendsVC = nil
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
    func onGridFriendClicked(id: String, username: String) {
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
        
        
        
        friendGridVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
        friendGridVC?.userID = id
        friendGridVC?.isFriendGrid = true
        friendGridVC?.messageDelegate = self
        friendGridVC?.delegate = delegate
        setActiveViewController(.toLeft, viewController: friendGridVC)
    }
}