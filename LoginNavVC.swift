//
//  LoginNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/28/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class LoginNavVC: CustomNavVC{
    
    var loginStoryboard = UIStoryboard(name: "LoginViews", bundle:nil)
    var shouldInitFromSignup = false
    var needUserInfo = false
    
    @IBOutlet weak var loginNavVCViewContainer: UIView!{
        didSet{
            super.containerView = loginNavVCViewContainer
        }
    }
    
    var logInViewController: LoginViewController?
    var signUpUserInfoVC: SignUpUserInfoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if needUserInfo{
            shouldInitFromSignup = true
            signUpUserInfoVC = loginStoryboard.instantiateViewControllerWithIdentifier("signUpUserInfoView") as? SignUpUserInfoVC
            signUpUserInfoVC?.delegate = self
            setActiveViewController(nil, viewController: signUpUserInfoVC)
        } else {
            logInViewController = loginStoryboard.instantiateViewControllerWithIdentifier("logInView") as? LoginViewController
            logInViewController?.delegate = self
            setActiveViewController(nil, viewController: logInViewController)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromLogInSegue" {
            let navVC = segue.destinationViewController as! HypeNavViewController
            navVC.shouldInitFromSignUp = shouldInitFromSignup
        }
        if segue.identifier == "loginToHelperViewsSegue" {
            let nextVC = segue.destinationViewController as! HelperViewsNavVC
            nextVC.section = HelperViewSection.MainView
        }
    }
    
    @IBAction func unwindFromLoginHelpToMainSegue(segue: UIStoryboardSegue){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.setBool(true, forKey: Constants.HASSEENMAINKEY)
        self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
    }
    
    private func onUserAuthenticated(){
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        
        if !(keychainWrapper.hasValueForKey(Constants.HASSEENMAINKEY)){
            self.performSegueWithIdentifier("loginToHelperViewsSegue", sender: nil)
        } else {
            self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
        }
    }
    
    
}

extension LoginNavVC: SignUpUserInfoVCDelegate{
    func onUserInfoSubmitted() {
        onUserAuthenticated()
    }
}

extension LoginNavVC: LoginViewControllerDelegate{
    
    func onSignedUp() {
        if signUpUserInfoVC == nil{
            shouldInitFromSignup = true
            signUpUserInfoVC = loginStoryboard.instantiateViewControllerWithIdentifier("signUpUserInfoView") as? SignUpUserInfoVC
            signUpUserInfoVC?.delegate = self
        }
        setActiveViewController(.toLeft, viewController: signUpUserInfoVC)
    }
    func onLoggedIn(){
        shouldInitFromSignup = false
        onUserAuthenticated()
    }
}