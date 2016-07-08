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

enum CurrentViewType{
    case Main
    case Settings
    case Grid
}

class HypeNavViewController: CustomNavVC {
    
    @IBOutlet var gridButton: UIButton!
    @IBOutlet var hypeButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var hypeBarView: UIView!
    @IBOutlet weak var hypeNavViewContainerView: UIView!{
        didSet{
            super.containerView = hypeNavViewContainerView
        }
    }

    var mainViewController: MainViewController?
    var settingsViewController: SettingsNavVC?
    var gridViewController: GridViewNavVC?
    var userGridViewController: GridViewController?
    
    var onAdSocialVCClosedFunc: ((canceled: Bool)->Void)?
    var friendIDS: [String]?
    var socialAd: HypeAd!
    
    var userInterests = SelectionDataSource<Bool>()
    
    var wasSwipeUp: Bool!
    var needUserInfo: Bool = false
    private var shouldInitOnAuthStateChange = true
    var shouldInitFromSignUp = false
    var helperSection: HelperViewSection!
    
    override func viewDidLoad() {
        
        //FOR SOME REASON THIS IS GETTING CALLED TWICE ON STARTUP?
        FIRAuth.auth()?.addAuthStateDidChangeListener{auth, user in
            if let authUser = user {
                
                if self.shouldInitOnAuthStateChange{
                    self.shouldInitOnAuthStateChange = false
                    guard user?.displayName != nil else{
                        self.needUserInfo = true
                        self.performSegueWithIdentifier("logInSegue", sender: nil)
                        return
                    }
                    self.hypeBarView.hidden = false
                    self.changeNavBarViewForCurrentView(.Main)
                    self.setActiveViewController(nil, viewController: self.mainViewController)
                    self.initializeHype(authUser.uid)
                }
                
            } else {
                self.resetHype()
                self.shouldInitOnAuthStateChange = false
                
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
    
    func resetHype(){
        userInterests.clear()
        friendIDS?.removeAll()
        socialAd = nil
        mainViewController?.resetMainView()
        gridViewController?.clearUserGridView()
        settingsViewController = nil
        
    }
    
    private func initializeHype(uid: String){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        
        guard keychainWrapper.hasValueForKey(Constants.HASSEENMAINKEY) else {
            showHelperViews(HelperViewSection.MainView)
            return
        }
        
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
            let userInterestKeys = ["Discovery", "Animals", "Apparel", "Apps & Games", "Babies & Kids", "Cars", "Celebrities", "Entertainment", "Fitness & Health", "Food & Cooking", "Lifestyle & Home", "Nerd", "News", "Outdoors", "Sports", "Tech", "Travel"]
            
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
            
            let defaultInterestDict = ["Discovery" : true, "Animals": true, "Apparel": true, "Apps & Games": true, "Babies & Kids": true, "Cars": true, "Celebrities": true, "Entertainment": true, "Fitness & Health": true, "Food & Cooking": true, "Lifestyle & Home": true, "Nerd": true, "News": true, "Outdoors": true, "Sports": true, "Tech": true, "Travel": true]
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
    
    private func changeNavBarViewForCurrentView(currentView: CurrentViewType){
        switch currentView{
        case .Main:
            hypeBarView.layer.shadowOpacity = 1.0
            settingsButton.alpha = 0.7
            hypeButton.alpha = 1
            gridButton.alpha = 0.7
        case .Settings:
            hypeBarView.layer.shadowOpacity = 0.6
            settingsButton.alpha = 1
            hypeButton.alpha = 0.7
            gridButton.alpha = 0.7
        case .Grid:
            hypeBarView.layer.shadowOpacity = 0.6
            settingsButton.alpha = 0.7
            hypeButton.alpha = 0.7
            gridButton.alpha = 1
        }
    }
    
    override func onInactiveVCReplaced(inactiveVC: UIViewController) {
        if inactiveVC.isKindOfClass(SettingsNavVC){
            settingsViewController?.clearLoadedVCS()
        } else if inactiveVC.isKindOfClass(GridViewNavVC){
            gridViewController?.clearLoadedVCsWhenSettingsOrHypeClicked()
        }
    }
    
    private func setSettingsViewControllers(){
        var storyboard = UIStoryboard(name: "UserSettingsView", bundle: nil)
        let userSettingsVC = storyboard.instantiateViewControllerWithIdentifier("userSettingsView") as? UserSettingsVC
        userSettingsVC?.messageDelegate = settingsViewController
        userSettingsVC?.interestsDataSource = userInterests
        settingsViewController?.userSettingsVC = userSettingsVC
        
        storyboard = UIStoryboard(name: "FriendsSettingsView", bundle: nil)
        let friendsSettingsVC = storyboard.instantiateViewControllerWithIdentifier("friendsSettingsView") as? FriendsSettingsVC
        friendsSettingsVC?.delegate = settingsViewController
        friendsSettingsVC?.messageDelegate = settingsViewController
        settingsViewController?.friendsSettingsVC = friendsSettingsVC
        
        storyboard = UIStoryboard(name: "HelpSettingsView", bundle: nil)
        let helpSettingsVC = storyboard.instantiateViewControllerWithIdentifier("helpSettingsView") as? HelpSettingsVC
        helpSettingsVC?.messageDelegate = settingsViewController
        helpSettingsVC?.delegate = self
    }
    
    private func setRootGridViewController(){
        
        if userGridViewController == nil{
            let gridStoryboard = UIStoryboard(name: "Grid View", bundle: nil)
            userGridViewController = gridStoryboard.instantiateViewControllerWithIdentifier("gridViewController") as? GridViewController
            userGridViewController?.userID = getUserUID()
            userGridViewController?.messageDelegate = gridViewController
            userGridViewController?.delegate = self
        }
        gridViewController?.userGridVC = userGridViewController

    }
    
    
    @IBAction func onSettingButtonClicked(sender: AnyObject){
        guard !isViewControllerActiveVC(settingsViewController) else{
            return
        }
        changeNavBarViewForCurrentView(.Settings)
        setSettingsViewControllers()
        setActiveViewController(.toRight, viewController: settingsViewController)

    }
    
    @IBAction func onHypeButtonClicked(sender: AnyObject){
        guard !isViewControllerActiveVC(mainViewController) else {
            return
        }
        changeNavBarViewForCurrentView(.Main)
        
        if isViewControllerActiveVC(gridViewController){
            setActiveViewController(.toRight, viewController: mainViewController)
        } else {
            setActiveViewController(.toLeft, viewController: mainViewController)
        }
    }
    
    @IBAction func onGridButtonClicked(sender: AnyObject){
        guard !isViewControllerActiveVC(gridViewController) else {
            return
        }
        
        changeNavBarViewForCurrentView(.Grid)
        setRootGridViewController()
        setActiveViewController(.toLeft, viewController: gridViewController)
        
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        if !(keychainWrapper.hasValueForKey(Constants.HASSEENGRIDKEY)) {
            showHelperViews(HelperViewSection.GridView)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showAdSocialViewSegue" {
            let newVC = segue.destinationViewController as! SocialNavVC
            newVC.ad = socialAd
            newVC.wasSwipeUp = wasSwipeUp
            
        } else if segue.identifier == "logInSegue" {
            let newVC = segue.destinationViewController as! LoginNavVC
            newVC.needUserInfo = needUserInfo
        } else if segue.identifier == "showHelperViewsSegue" {
            let newVC = segue.destinationViewController as! HelperViewsNavVC
            newVC.section = helperSection
        }
    }
    
    func showViewToChangeUserInfo(){
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
    }
    func showHelperViews(section: HelperViewSection){
        helperSection = section
        self.performSegueWithIdentifier("showHelperViewsSegue", sender: nil)
    }
    
    @IBAction func unwindFromLogInSegue(segue: UIStoryboardSegue){
        self.hypeBarView.hidden = false
        self.settingsButton.alpha = 0.7
        self.hypeButton.alpha = 1
        self.gridButton.alpha = 0.7
        needUserInfo = false
        if shouldInitFromSignUp{
            print("USER UID: \((FIRAuth.auth()?.currentUser?.uid)!)")
            self.setActiveViewController(nil, viewController: self.mainViewController)
            createUserNodes((FIRAuth.auth()?.currentUser?.uid)!)
        } else {
            self.setActiveViewController(nil, viewController: self.mainViewController)
            self.initializeHype((FIRAuth.auth()?.currentUser?.uid)!)
        }
    }
    
    @IBAction func unwindFromAdSocialViewSegue(segue: UIStoryboardSegue){
        
        if(segue.sourceViewController.isKindOfClass(SocialNavVC)){
            if !wasSwipeUp {
                return
            }
            
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
    
    @IBAction func unwindFromHelperViewsSegue(segue: UIStoryboardSegue){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        
        switch helperSection!{
        case .GridView:
            keychainWrapper.setBool(true, forKey: Constants.HASSEENGRIDKEY)
        case .MainView:
            keychainWrapper.setBool(true, forKey: Constants.HASSEENMAINKEY)
            let uid = (FIRAuth.auth()?.currentUser?.uid)!
            initializeHype(uid)
        default:
            return
        }
    }
    
    private func getUserUID() -> String{
        return (FIRAuth.auth()?.currentUser?.uid)!
    }
    
}

extension HypeNavViewController: HelpSettingsDelegate{
    func onOpenHelperViews() {
        showHelperViews(HelperViewSection.AllViews)
    }
}
extension HypeNavViewController: MainViewControllerDelegate{
    func onSwipeUp(ad: HypeAd, onClose: (canceled: Bool)->Void){
        
        socialAd = ad
        wasSwipeUp = true
        onAdSocialVCClosedFunc = onClose
        
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
        
    }
}

extension HypeNavViewController: GridViewControllerDelegate{
    func onAdFromGridDoubleClicked(ad: HypeAd) {
        
        socialAd = ad
        wasSwipeUp = false
        
        self.performSegueWithIdentifier("showAdSocialViewSegue", sender: nil)
    }
}