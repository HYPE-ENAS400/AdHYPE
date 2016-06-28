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

enum NavVCTransition {
    case ToSettings
    case ToGrid
    case GridToMain
    case SettingsToMain
}

enum LogInState {
    case loggedOut
    case loggedIn
    case signedUp
}

class HypeNavViewController: UIViewController, MainViewControllerDelegate, LoginViewControllerDelegate {
    
    @IBOutlet var gridButton: UIButton!
    @IBOutlet var hypeButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var hypeBarView: UIView!
    @IBOutlet var containerView: UIView!
    
    var mainViewController: MainViewController?
    var settingsViewController: SettingsNavVC?
    
//    var gridViewController: GridViewController?
    var gridViewController: AdBrowserViewController?
    
    var vcTransition: NavVCTransition?
    
    var onAdSocialVCClosedFunc: ((canceled: Bool)->Void)?
    var friendIDS: [String]?
    var socialAd: HypeAd!
    
    var userInterests = SelectionDataSource<Bool>()
    
    var wasSwipeUp: Bool!
    
    private var logInState = LogInState.loggedOut
    
    override func viewDidLoad() {
        
        //FOR SOME REASON THIS IS GETTING CALLED TWICE ON STARTUP?
        FIRAuth.auth()?.addAuthStateDidChangeListener{auth, user in
            if let authUser = user {
                self.hypeBarView.hidden = false
                self.settingsButton.alpha = 0.7
                self.hypeButton.alpha = 1
                self.gridButton.alpha = 0.7
                
                if self.logInState == .signedUp{
                    self.activeViewController = self.mainViewController
                    self.createUserNodes(authUser.uid)
                    self.logInState == .loggedIn
                } else if self.logInState == .loggedOut{
                    self.activeViewController = self.mainViewController
                    self.initializeHype(authUser.uid)
                    self.logInState = .loggedIn
                }
                
            } else {
                
                if self.logInState != .loggedOut{
                    self.logInState = .loggedOut
                    self.resetViewControllers()
                }

                
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
        
        super.viewDidLoad()
        
    }
    
    func initializeHype(uid: String){
        // get user interests
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            //once user interests and nextNode are loaded, can start getting Ads
            var nodesLoaded = 0{
                didSet{
                    if nodesLoaded == 2{
                        self.mainViewController?.queryAdMetaData()
                    }
                }
            }
            
            //do this to maintain desired order
            let userInterestKeys = ["Discovery", "Animals", "Apparel", "Apps & Games", "Babies & Kids", "Cars", "Celebrities", "Entertainment", "Fitness & Health", "Food & Cooking", "Lifestyle & Home", "News", "Outdoors", "Sports", "Tech", "Travel"]
            
            for key in userInterestKeys{
                self.userInterests.putPair((key, true))
            }
            let userRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(uid)
            
            let interestsRef = userRef.child(Constants.USERINTERESTSNODE)
            interestsRef.observeSingleEventOfType(.Value, withBlock: {(snapshot)->Void in
                
                if let ar = snapshot.value as? [String : Bool]{
                    for (interest, liked) in ar{
                        self.userInterests.setValueForKey(interest, value: liked)
                    }
                    self.mainViewController?.userInterests = self.userInterests
                    nodesLoaded += 1
                } else{
                    print("COULD NOT GET USER INTERESTS")
                }
                
            })
            
            let nextAdRef = userRef.child(Constants.USERNEXTADKEY)
            nextAdRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
                if let key = snapshot.value as? String{
                    self.mainViewController?.nextQueueKey = key
                    nodesLoaded += 1
                } else{
                    print("COULD NOT GET NEXT AD QUEUE KEY")
                }
            })
            
        }
    }
    
    
    func onSignUpClicked(){
        logInState = .signedUp
    }
    
    private func createUserNodes(uid: String){
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            //once both interests and nextAdNode are set, initialize hype ads
            var nodesSet = 0{
                didSet{
                    if nodesSet == 2{
                        self.initializeHype(uid)
                    }
                }
            }
            let baseRef = FIRDatabase.database().reference()
            let userRef = baseRef.child(Constants.USERSNODE).child(uid)
            userRef.child(Constants.CONTENTCOUNTNODE).setValue(0)
            userRef.child(Constants.ADVIEWEDCOUNTNODE).setValue(0)
            
            let defaultInterestDict = ["Discovery" : true, "Animals": true, "Apparel": true, "Apps & Games": true, "Babies & Kids": true, "Cars": true, "Celebrities": true, "Entertainment": true, "Fitness & Health": true, "Food & Cooking": true, "Lifestyle & Home": true, "News": true, "Outdoors": true, "Sports": true, "Tech": true, "Travel": true]
            userRef.child(Constants.USERINTERESTSNODE).setValue(defaultInterestDict, withCompletionBlock: {(error, ref)-> Void in
                if let er = error{
                    print("ERROR setting user preferences: \(er.localizedDescription)")
                } else{
                    nodesSet += 1
                }
            })
            
            let firstAdQuery = baseRef.child(Constants.ADSNODE).queryOrderedByKey().queryLimitedToFirst(1)
            firstAdQuery.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) -> Void in
                userRef.child(Constants.USERNEXTADKEY).setValue(snapshot.key, withCompletionBlock: { (error, reference) -> Void in
                    if let er = error{
                        print("ERROR setting first AdKey: \(er.localizedDescription)")
                    } else{
                        nodesSet += 1
                    }
                })
            })
        }
    }
    
    private func resetViewControllers(){
//        gridViewController?.clearGridView()
        mainViewController?.resetMainView()
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
        guard activeViewController != settingsViewController else{
            return
        }
        
        let storyboard = UIStoryboard(name: "Settings Nav View", bundle:nil)
        settingsViewController = storyboard.instantiateViewControllerWithIdentifier("settingsNavVC") as? SettingsNavVC
        settingsViewController?.userInterests = userInterests
        hypeBarView.layer.shadowOpacity = 0.0
        vcTransition = NavVCTransition.ToSettings
        settingsButton.alpha = 1
        hypeButton.alpha = 0.7
        gridButton.alpha = 0.7
        activeViewController = settingsViewController

    }
    
    @IBAction func onHypeButtonClicked(sender: AnyObject){
        if(activeViewController != mainViewController){
            hypeBarView.layer.shadowOpacity = 1.0
            if(activeViewController == gridViewController){
                vcTransition = NavVCTransition.GridToMain
            } else if (activeViewController == settingsViewController){
                vcTransition = NavVCTransition.SettingsToMain
            }
            activeViewController = mainViewController
            settingsViewController = nil
            settingsButton.alpha = 0.7
            hypeButton.alpha = 1
            gridButton.alpha = 0.7
        }
    }
    
    @IBAction func onGridButtonClicked(sender: AnyObject){
        
        if(activeViewController != gridViewController){
            settingsViewController = nil
            hypeBarView.layer.shadowOpacity = 1.0
            vcTransition = NavVCTransition.ToGrid
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
            newVC.wasSwipeUp = wasSwipeUp
            
        }
        if segue.identifier == "logInSegue" {
            let newVC = segue.destinationViewController as! LoginViewController
            newVC.delegate = self
        }
    }
    
    @IBAction func unwindFromLogInSegue(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func unwindFromAdSocialViewSegue(segue: UIStoryboardSegue){
        if !wasSwipeUp {
            return
        }
        
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
    
    func onSwipeUp(ad: HypeAd, onClose: (canceled: Bool)->Void){
        socialAd = ad
        wasSwipeUp = true
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
        onAdSocialVCClosedFunc = onClose
    }
    
}
extension HypeNavViewController: AdBrowserViewControllerDelegate{
    func onAdFromBrowserDoubleClicked(ad: HypeAd) {
        socialAd = ad
        wasSwipeUp = false
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
    }
}