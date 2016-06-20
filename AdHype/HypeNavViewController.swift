//
//  HypeNavViewController.swift
//  Hype-2
//
//  Created by max payson on 4/13/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import pop
import Firebase

enum VCTransition {
    case ToSettings
    case ToGrid
    case GridToMain
    case SettingsToMain
}

class HypeNavViewController: UIViewController, MainViewControllerDelegate, GridViewControllerDelegate, SettingsViewControllerDelegate {
    
    @IBOutlet var gridButton: UIButton!
    @IBOutlet var hypeButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    var userName: String?
    var password: String?
    var userUID: String!{
        didSet{
//            mainViewController?.userUID = userUID
//            gridViewController?.userUID = userUID
//            settingsViewController?.uid = userUID
        }
    }
    
    var socialAd: HypeAd!
    
    var mainViewController: MainViewController?
    var settingsViewController: SettingsViewController?
    var gridViewController: GridViewController?
    var vcTransition: VCTransition?
    
    var onAdSocialVCClosedFunc: ((canceled: Bool)->Void)?
    
    var friendIDS: [String]?
    
    @IBOutlet var hypeBarView: UIView!
    
    @IBOutlet var containerView: UIView!
    
    override func viewDidAppear(animated: Bool) {
        
        //FOR SOME REASON THIS IS GETTING CALLED TWICE ON STARTUP?
        FIRAuth.auth()?.addAuthStateDidChangeListener{auth, user in
            if let authUser = user {
                self.hypeBarView.hidden = false
                
                //Case where there is not a pre-existing VC
                if self.activeViewController == nil{
                    self.gridViewController?.initGridView(authUser.uid)
                    self.mainViewController?.initMainView(authUser.uid)
                    self.activeViewController = self.mainViewController
                    self.settingsButton.alpha = 0.7
                    self.hypeButton.alpha = 1
                    self.gridButton.alpha = 0.7
                }
                
            } else {
                let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                
                if let uN = keychainWrapper.stringForKey(Constants.USERKEY), pW = keychainWrapper.stringForKey(Constants.PASSKEY){
                    FIRAuth.auth()?.signInWithEmail(uN, password: pW, completion:
                        { (error, authData) -> Void in
                            if error != nil{
                                print(error)
                                self.performSegueWithIdentifier("logInSegue", sender: nil)
                            }
                    })
                } else {
                    self.performSegueWithIdentifier("logInSegue", sender: nil)
                }
            }
        }
        
        super.viewDidAppear(animated)
        
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
            
            if let transition = vcTransition{
                let animation = CATransition()
                animation.type = kCATransitionPush
                
                switch transition{
                case .ToGrid:
                    animation.subtype = kCATransitionFromRight
                case .ToSettings:
                    animation.subtype = kCATransitionFromLeft
                case .SettingsToMain:
                    animation.subtype = kCATransitionFromRight
                case .GridToMain:
                    animation.subtype = kCATransitionFromLeft
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
    
    
    @IBAction func onSettingButtonClicked(sender: AnyObject){
        if(activeViewController != settingsViewController){
            vcTransition = VCTransition.ToSettings
            activeViewController = settingsViewController
            settingsButton.alpha = 1
            hypeButton.alpha = 0.7
            gridButton.alpha = 0.7
        }

    }
    
    @IBAction func onHypeButtonClicked(sender: AnyObject){
        if(activeViewController != mainViewController){
            if(activeViewController == gridViewController){
                vcTransition = VCTransition.GridToMain
            } else if (activeViewController == settingsViewController){
                vcTransition = VCTransition.SettingsToMain
            }
            activeViewController = mainViewController
            settingsButton.alpha = 0.7
            hypeButton.alpha = 1
            gridButton.alpha = 0.7
        }
    }
    
    @IBAction func onGridButtonClicked(sender: AnyObject){
        
        if(activeViewController != gridViewController){
            vcTransition = VCTransition.ToGrid
            activeViewController = gridViewController
            settingsButton.alpha = 0.7
            hypeButton.alpha = 0.7
            gridButton.alpha = 1
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showAdSocialViewSegue" {
            let newVC = segue.destinationViewController as! SocialNavVC
            newVC.ad = socialAd
            
        }
        if segue.identifier == "showUsersVCSegue" {
            if let ids = friendIDS{
                let newVC = segue.destinationViewController as! UserTableViewController
                newVC.existingFriendsIDS = ids
            }
        }
    }
    
    @IBAction func unwindFromLogInSegue(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func unwindFromAdSocialViewSegue(segue: UIStoryboardSegue){
        if(segue.sourceViewController .isKindOfClass(SocialNavVC)){
            let sVC = segue.sourceViewController as! SocialNavVC
            if let fun = onAdSocialVCClosedFunc{
                fun(canceled: sVC.didCancel)
            } else {
                //PROBABLY COULD HAVE DONE THIS FROM THE BEGINNING
                mainViewController?.kolodaView.revertAction()
            }
        }
        socialAd = nil
    }
    
    @IBAction func unwindFromUserTableViewSegue(segue: UIStoryboardSegue){
        friendIDS = nil
    }
    
    func onSwipeUp(ad: HypeAd, onClose: (canceled: Bool)->Void){
        socialAd = ad
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
        onAdSocialVCClosedFunc = onClose
    }
    
    func onAdDoubleClicked(ad: HypeAd) {
        socialAd = ad
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
    }
    func onAddFriendClicked(existingFriendIDS: [String]){
        friendIDS = existingFriendIDS
        self.performSegueWithIdentifier("showUsersVCSegue", sender: nil)
    }
    
}