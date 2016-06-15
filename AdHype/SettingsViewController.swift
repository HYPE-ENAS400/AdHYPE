//
//  SettingsViewController.swift
//  Hype-2
//
//  Created by max payson on 4/13/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController{
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var numSwipesLabel: UILabel!
    @IBOutlet var conversionLabel: UILabel!
    @IBOutlet var hypePointsLabel: UILabel!
    
    var userName: String?
    var uid: String?
    
    override func viewDidLoad() {
//        let ref = Firebase(url: "https://enas400hype.firebaseio.com/").childByAppendingPath("users").childByAppendingPath(uid)
        
        conversionLabel.text = "\(Constants.INVADSPERCONTENT) SITES/SWIPE"
        
//        ref.observeEventType(.Value, withBlock: { (snapshot) in
//            let contentCount = snapshot.value["contentCount"] as? Int
//            if let t = contentCount{
//                self.hypePointsLabel.text = "\(t) SITES"
//            }
//            let totalAds = snapshot.value["adViewedCount"] as? Int
//            if let t = totalAds{
//                self.numSwipesLabel.text = "\(t) SWIPES"
//            }
//
//            
//        })
    }
    
    override func viewDidAppear(animated: Bool) {
        userNameLabel.text = userName
    }
    
    @IBAction func onSignOutClicked(sender: AnyObject){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.removeObjectForKey(Constants.PASSKEY)
        keychainWrapper.removeObjectForKey(Constants.USERKEY)
        
        try! FIRAuth.auth()!.signOut()
        
    }

}


