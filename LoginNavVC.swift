//
//  LoginNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/28/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class LoginNavVC: CustomNavVC{
    
    @IBOutlet weak var loginNavVCViewContainer: UIView!{
        didSet{
            super.containerView = loginNavVCViewContainer
        }
    }
    
    var logInViewController: LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "LoginViews", bundle:nil)
        logInViewController = storyboard.instantiateViewControllerWithIdentifier("logInView") as? LoginViewController
        logInViewController?.delegate = self
        setActiveViewController(nil, viewController: logInViewController)
    }
}

extension LoginNavVC: LoginViewControllerDelegate{
    //NEED ANOTHER FUNCTION THAT TELLS NAVVC THAT WAS LOGGED IN, MAYBE CHANGE ORDER OF WHEN INITIALIZE THINGS GET CALLED?
    
    func onSignedUp() {
        
    }
    func onLoggedIn(){
        self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
    }
}