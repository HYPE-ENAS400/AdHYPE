//
//  SocialNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class SocialNavVC: CustomNavVC {
    
    @IBOutlet weak var socialNavVCContainerView: UIView!{
        didSet{
            super.containerView = socialNavVCContainerView
        }
    }

    var ad: HypeAd!
    var userFriends: FriendStore!
    
    var adSocialViewController: AdSocialViewController?
    var friendsTableViewController: FriendsTableViewController?
    
    var didCancel = true
    var wasSwipeUp: Bool!

    
    override func loadView() {
        super.loadView()
        
        view.bringSubviewToFront(containerView)
        
        let storyboard = UIStoryboard(name: "Social View", bundle:nil)
        adSocialViewController = storyboard.instantiateViewControllerWithIdentifier("adSocialView") as? AdSocialViewController
        adSocialViewController!.ad = ad
        adSocialViewController!.wasSwipeUp = wasSwipeUp
        adSocialViewController!.delegate = self
        setActiveViewController(nil, viewController: adSocialViewController)
    }

    override func viewDidAppear(animated: Bool) {
        
        //socialToHelperViewsSegue
        super.viewDidAppear(animated)
        
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        if !keychainWrapper.hasValueForKey(Constants.HASSEENSOCIALKEY){
            self.performSegueWithIdentifier("socialToHelperViewsSegue", sender: nil)
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "socialToHelperViewsSegue" {
            let nextVC = segue.destinationViewController as! HelperViewsNavVC
            nextVC.section = HelperViewSection.SocialView
        }
    }
    
    @IBAction func unwindFromHelpToSocialSegue(segue: UIStoryboardSegue){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.setBool(true, forKey: Constants.HASSEENSOCIALKEY)
    }
}

extension SocialNavVC: AdSocialViewControllerDelegate{
    
    func onCloseClicked(){
        didCancel = true
        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
    func onSendClicked(caption: String?, canPublish: Bool){
        let storyboard = UIStoryboard(name: "Send to Friends View", bundle:nil)
        
        if friendsTableViewController == nil {
            friendsTableViewController = storyboard.instantiateViewControllerWithIdentifier("sendToFriendsView") as?FriendsTableViewController
            friendsTableViewController!.adMetaData = ad.getMetaData()
            friendsTableViewController!.delegate = self
            friendsTableViewController!.friendStore = userFriends
            friendsTableViewController!.canPublish = canPublish
            friendsTableViewController!.captionText = caption
        } else{
            friendsTableViewController!.canPublish = canPublish
            friendsTableViewController!.captionText = caption
            friendsTableViewController?.friendTableView.reloadData()
        }
        
        setActiveViewController(.toLeft, viewController: friendsTableViewController)
        
    }
    
}

extension SocialNavVC: FriendsTableViewControllerDelegate{
    func onBackButtonClicked(){
        setActiveViewController(.toRight, viewController: adSocialViewController)
    }
    func onSentToFriends(){
        didCancel = false
        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
}
