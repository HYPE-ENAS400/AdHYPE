//
//  LoginVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/15/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var outerScrollView: UIScrollView!
    @IBOutlet weak var innerScrollView: UIScrollView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var passwordTextEdit: CustomTextField!
    @IBOutlet weak var userNameTextEdit: CustomTextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: LoginViewControllerDelegate!
    var isSignUp: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextEdit.layer.borderColor = UIColor.whiteColor().CGColor
        userNameTextEdit.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        userNameTextEdit.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        userNameTextEdit.delegate = self
        
        passwordTextEdit.layer.borderColor = UIColor.whiteColor().CGColor
        passwordTextEdit.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        passwordTextEdit.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        passwordTextEdit.delegate = self
        
        signUpButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        
        logInButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
         selector: #selector(self.keyboardNotification(_:)),
         name: UIKeyboardWillChangeFrameNotification,
         object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            var yOffset: CGFloat
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height{
                yOffset = 0.0
            } else{
                if let height = endFrame?.size.height{
                    yOffset = height - 10
                } else {
                    yOffset = 0.0
                }
            }
            let offset = CGPoint(x: 0.0, y: yOffset)
            
            
            UIView.animateWithDuration(duration, delay: 0, options: animationCurve, animations: {
                self.outerScrollView.contentOffset = offset
                }, completion: nil)


        }
            
    }
    @IBAction func dismissKeyboard(sender: AnyObject){
        resignPossibleFirstResponders()
    }

    @IBAction func onGoClicked(sender: AnyObject) {
        spinner.startAnimating()
        goButton.enabled = false
        errorLabel.hidden = true
        
        if isSignUp!{
            signUserUp()
        } else{
            logUserIn()
        }
    }
    
    @IBAction func onLoginClicked(sender: AnyObject) {
        shiftScrollViewForTextEntry()
        isSignUp = false
    }
    
    @IBAction func onSignUpClicked(sender: AnyObject) {
        shiftScrollViewForTextEntry()
        isSignUp = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == userNameTextEdit{
            passwordTextEdit.becomeFirstResponder()
            return true
        } else{
            spinner.startAnimating()
            goButton.enabled = false
            errorLabel.hidden = true
            textField.resignFirstResponder()
            if isSignUp!{
                signUserUp()
            } else{
                logUserIn()
            }
            return true
        }
    }
    
    private func shiftScrollViewForTextEntry(){
        let width = UIScreen.mainScreen().bounds.size.width
        let point = CGPoint(x: width, y: 0)
        innerScrollView.setContentOffset(point, animated: true)
    }
    
    private func signUserUp(){

        guard let un = userNameTextEdit.text, pw = passwordTextEdit.text else{
            return
        }

        FIRAuth.auth()?.createUserWithEmail(un, password: pw,
            completion: { (user, error) -> Void in
                self.spinner.stopAnimating()
                if let error = error{

                    let userInfo: NSDictionary = error.userInfo
                    self.displayLoginError(String(userInfo.valueForKey("error_name")!))


                } else if let user = user{
                    //TODO fix the optional?

                    let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                    keychainWrapper.setString(un, forKey: Constants.USERKEY)
                    keychainWrapper.setString(pw, forKey: Constants.PASSKEY)

                    self.delegate.onSignedUp()
                    
                    print("Successfully created user account with uid: \(user.uid)")
                }
        })
    }
    
    private func logUserIn(){
        
        guard let un = userNameTextEdit.text, pw = passwordTextEdit.text else{
            return
        }

        //TODO fix conditionals
        FIRAuth.auth()?.signInWithEmail(un, password: pw, completion: { (user, error) -> Void in
            self.spinner.stopAnimating()
            if let error = error{

                let userInfo: NSDictionary = error.userInfo
                self.displayLoginError(String(userInfo.valueForKey("error_name")!))

            } else if let user = user{

                let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                keychainWrapper.setString(un, forKey: Constants.USERKEY)
                keychainWrapper.setString(pw, forKey: Constants.PASSKEY)
                
                self.delegate.onLoggedIn()
                
                print("Successfully logged in user account with uid: \(user.uid)")
            }
        })
    }
    
    private func displayLoginError(errorName: String){
        resignPossibleFirstResponders()
        backButton.hidden = false
        errorLabel.hidden = false
        self.goButton.enabled = true
        switch(errorName){
        case "ERROR_INVALID_EMAIL":
            errorLabel.text = "Please enter a valid e-mail"
        case "ERROR_EMAIL_ALREADY_IN_USE":
            errorLabel.text = "An account already exists with this e-mail"
        case "ERROR_WEAK_PASSWORD":
            errorLabel.text = "Please create a stronger password"
        case "ERROR_USER_NOT_FOUND":
            errorLabel.text = "We could not find the specified username"
        case "ERROR_USER_DISABLED":
            errorLabel.text = "This account has been disabled"
        case "ERROR_WRONG_PASSWORD":
            errorLabel.text = "Please try another password"
        default:
            errorLabel.text = "Error signing you in"
        }
    }
    
    @IBAction func onBackButtonClicked(sender: AnyObject) {
        let point = CGPoint(x: 0, y: 0)
        innerScrollView.setContentOffset(point, animated: true)
        backButton.hidden = true
        errorLabel.hidden = true
    }
    
    private func resignPossibleFirstResponders(){
        passwordTextEdit.resignFirstResponder()
        userNameTextEdit.resignFirstResponder()
    }
    
}

protocol LoginViewControllerDelegate: class{
    func onSignedUp()
    func onLoggedIn()
}
