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
    
    @IBOutlet weak var loginNavVCViewContainer: UIView!{
        didSet{
            super.containerView = loginNavVCViewContainer
        }
    }
    
    var logInViewController: LoginViewController?
    var signUpUserInfoVC: SignUpUserInfoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInViewController = loginStoryboard.instantiateViewControllerWithIdentifier("logInView") as? LoginViewController
        logInViewController?.delegate = self
        setActiveViewController(nil, viewController: logInViewController)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromLogInSegue" {
            let navVC = segue.destinationViewController as! HypeNavViewController
            navVC.shouldInitFromSignUp = shouldInitFromSignup
        }
    }
}

extension LoginNavVC: SignUpUserInfoVCDelegate{
    func onUserSignUpFailed(errorInfo: String) {
        setActiveViewController(.toRight, viewController: logInViewController)
        logInViewController?.displayLoginError(errorInfo)
    }
    func onUserInfoSubmitted() {
        self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
    }
}

extension LoginNavVC: LoginViewControllerDelegate{
    //NEED ANOTHER FUNCTION THAT TELLS NAVVC THAT WAS LOGGED IN, MAYBE CHANGE ORDER OF WHEN INITIALIZE THINGS GET CALLED?
    
    func onSignedUp(userName: String, password: String) {
        shouldInitFromSignup = true
        signUpUserInfoVC = loginStoryboard.instantiateViewControllerWithIdentifier("signUpUserInfoView") as? SignUpUserInfoVC
        signUpUserInfoVC?.delegate = self
        signUpUserInfoVC?.userName = userName
        signUpUserInfoVC?.password = password
        setActiveViewController(.toLeft, viewController: signUpUserInfoVC)
    }
    func onLoggedIn(){
        shouldInitFromSignup = false
        self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
    }
}