import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var userNameTextEdit: UITextField!
    @IBOutlet var passwordTextEdit: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var errorLabel: UILabel!

    var userUID: String!
    var userName: String!
    var password: String!
    
    var ref:FIRDatabaseReference!
    
    override func viewDidAppear(animated: Bool){
        ref = FIRDatabase.database().reference()
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject){
        passwordTextEdit.resignFirstResponder()
        userNameTextEdit.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func logInClicked(sender: AnyObject){
        
        logInButton.userInteractionEnabled = false
        signUpButton.userInteractionEnabled = false
        
        userName = userNameTextEdit.text
        password = passwordTextEdit.text
        
        //TODO fix conditionals
        FIRAuth.auth()?.signInWithEmail(userNameTextEdit.text!, password: passwordTextEdit.text!, completion: { (user, error) -> Void in
            if let error = error{
                
                self.logInButton.userInteractionEnabled = true
                self.signUpButton.userInteractionEnabled = true
                let userInfo: NSDictionary = error.userInfo
                self.displayLoginError(String(userInfo.valueForKey("error_name")!))
                
            } else if let user = user{
                
                let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                keychainWrapper.setString(self.userName, forKey: Constants.USERKEY)
                keychainWrapper.setString(self.password, forKey: Constants.PASSKEY)
                
                self.userUID = user.uid
            
                print("Successfully logged in user account with uid: \(self.userUID)")
                self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
            }
        })
    
    }
    
    @IBAction func signUpClicked(sender: AnyObject){
        //TODO Invalidate button
        
        logInButton.userInteractionEnabled = false
        signUpButton.userInteractionEnabled = false
        
        userName = userNameTextEdit.text
        password = passwordTextEdit.text
        
        FIRAuth.auth()?.createUserWithEmail(userName, password: password,
            completion: { (user, error) -> Void in
            if let error = error{
                
                self.logInButton.userInteractionEnabled = true
                self.signUpButton.userInteractionEnabled = true
                let userInfo: NSDictionary = error.userInfo
                self.displayLoginError(String(userInfo.valueForKey("error_name")!))

                
            } else if let user = user{
                //TODO fix the optional?
                
                let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                keychainWrapper.setString(self.userName, forKey: Constants.USERKEY)
                keychainWrapper.setString(self.password, forKey: Constants.PASSKEY)

                self.userUID = user.uid
                
                self.ref.child("users").child(user.uid).setValue(["username": self.userName])
                
                print("Successfully created user account with uid: \(self.userUID)")
                self.performSegueWithIdentifier("unwindFromLogInSegue", sender: nil)
            }
        })
    }
    
    private func displayLoginError(errorName: String){
        errorLabel.hidden = false
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromLogInSegue" {
            let navViewController = segue.destinationViewController as! HypeNavViewController
            navViewController.userUID = userUID
            navViewController.userName = userName
            navViewController.password = password

        }
    }
//
}