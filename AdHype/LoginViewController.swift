import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var userNameTextEdit: UITextField!
    @IBOutlet var passwordTextEdit: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    var userName: String!
    var password: String!
    
    var ref:FIRDatabaseReference!
    
    var delegate: LoginViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextEdit.layer.borderColor = UIColor.whiteColor().CGColor
        userNameTextEdit.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        userNameTextEdit.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        
        
        passwordTextEdit.layer.borderColor = UIColor.whiteColor().CGColor
        passwordTextEdit.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        passwordTextEdit.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        
        signUpButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        signUpButton.layer.shadowRadius = 4
        signUpButton.layer.shadowOpacity = 0.8
        signUpButton.layer.shadowOffset = CGSizeZero
        
        logInButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        logInButton.layer.shadowRadius = 4
        logInButton.layer.shadowOpacity = 0.8
        logInButton.layer.shadowOffset = CGSizeZero
        
        
    }
    
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

                let userInfo: NSDictionary = error.userInfo
                self.displayLoginError(String(userInfo.valueForKey("error_name")!))
                
            } else if let user = user{
                
                let keychainWrapper = KeychainWrapper.standardKeychainAccess()
                keychainWrapper.setString(self.userName, forKey: Constants.USERKEY)
                keychainWrapper.setString(self.password, forKey: Constants.PASSKEY)
                
                self.delegate.onLoggedIn()
                
                print("Successfully logged in user account with uid: \(user.uid)")
            }
        })
    
    }
    
    @IBAction func signUpClicked(sender: AnyObject){
            
        logInButton.userInteractionEnabled = false
        signUpButton.userInteractionEnabled = false
        
        userName = userNameTextEdit.text
        password = passwordTextEdit.text
        
        delegate.onSignedUp(userName, password: password)
        
    
    }
    
    func displayLoginError(errorName: String){
        
        self.logInButton.userInteractionEnabled = true
        self.signUpButton.userInteractionEnabled = true
        
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
}


protocol LoginViewControllerDelegate{
    func onSignedUp(userName: String, password: String)
    func onLoggedIn()
}