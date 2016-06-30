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
    
    @IBOutlet weak var gridViewNavVCContainerView: UIView!{
        didSet{
            super.containerView = gridViewNavVCContainerView
        }
    }
    
    
    var gridStoryboard: UIStoryboard!
    var userGridVC: GridViewController?
    var gridViewFriendsVC: GridViewFriendsVC?
    var adjustmentWidth: CGFloat!
    
    
    var delegate: GridViewNavVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        gridStoryboard = UIStoryboard(name: "Grid View", bundle: nil)
        userGridVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
        userGridVC?.userID = userID
        setActiveViewController(nil, viewController: userGridVC)
        
        adjustmentWidth = CGRectGetWidth(selectionBar.frame)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        friendLabel.center.x += adjustmentWidth
        backButton.center.x += adjustmentWidth
    }
    
    @IBAction func onFriendButtonClicked(sender: AnyObject) {
        gridViewFriendsVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewFriendsVC") as? GridViewFriendsVC
        gridViewFriendsVC?.delegate = self
        setActiveViewController(.toLeft, viewController: gridViewFriendsVC)
        userUnderlineView.hidden = true
        friendUnderlineView.hidden = false
    }
    
    @IBAction func onUserButtonClicked(sender: AnyObject) {
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
        
        
        
        let newVC = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
        newVC?.userID = id
        setActiveViewController(.toLeft, viewController: newVC)
    }
}

protocol GridViewNavVCDelegate{
    func onAdFromGridDoubleClicked(ad: HypeAd)
}