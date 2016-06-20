//
//  SocialNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

enum SocialNavVCTransitionDirection{
    case toRight
    case toLeft
}


class SocialNavVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var ad: HypeAd!
    
    var adSocialViewController: AdSocialViewController! = nil
    var friendsTableViewController: FriendsTableViewController! = nil
    
    var didCancel = true
    
    var transitionDirection: SocialNavVCTransitionDirection!

    
    override func loadView() {
        super.loadView()
        
        view.bringSubviewToFront(containerView)
        
        let storyboard = UIStoryboard(name: "Social View", bundle:nil)
        adSocialViewController = storyboard.instantiateViewControllerWithIdentifier("adSocialView") as! AdSocialViewController
        adSocialViewController.ad = ad
        adSocialViewController.delegate = self
        activeViewController = adSocialViewController
    }
    
    private var activeViewController: UIViewController?{
        didSet{
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?){
        if let inActiveVC = inactiveViewController{
            inActiveVC.willMoveToParentViewController(nil)
            
            if let transition = transitionDirection{
                let animation = CATransition()
                
                
                animation.type = kCATransitionPush
                
                switch transition{
                case .toRight:
                    animation.subtype = kCATransitionFromLeft
                case .toLeft:
                    animation.subtype = kCATransitionFromRight
                }
                
                containerView.layer.addAnimation(animation, forKey: "test")
                
            }
            
            inActiveVC.view.removeFromSuperview()
            inActiveVC.removeFromParentViewController()
        }
        
    }
    
    private func updateActiveViewController(){
        
        if let activeVC = activeViewController {
            
            activeVC.view.frame = containerView.bounds
            addChildViewController(activeVC)
            containerView.addSubview(activeVC.view)
            activeVC.didMoveToParentViewController(self)
        }
    }
    
}

extension SocialNavVC: AdSocialViewControllerDelegate{
    
    func onCloseClicked(){
        didCancel = true
        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
    func onSendClicked(adName: String, caption: String?, canPublish: Bool){
        let storyboard = UIStoryboard(name: "Send to Friends View", bundle:nil)
        friendsTableViewController = storyboard.instantiateViewControllerWithIdentifier("sendToFriendsView") as! FriendsTableViewController
        friendsTableViewController.adName = adName
        friendsTableViewController.canPublish = canPublish
        friendsTableViewController.captionText = caption
        friendsTableViewController.delegate = self
        transitionDirection = .toLeft
        activeViewController = friendsTableViewController
        
    }
    
}

extension SocialNavVC: FriendsTableViewControllerDelegate{
    func onBackButtonClicked(){
        transitionDirection = .toRight
        activeViewController = adSocialViewController
        friendsTableViewController = nil
    }
    func onSentToFriends(){
        didCancel = false
        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
}
