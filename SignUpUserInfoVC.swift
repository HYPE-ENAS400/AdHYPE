//
//  SignUpUserInfoVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/29/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class SignUpUserInfoVC: UIViewController{

    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var fullNameTextField: CustomTextField!
    @IBOutlet weak var ageTextField: CustomTextField!
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    
    var delegate: SignUpUserInfoVCDelegate!
    var username: String?
    
    let disallowedCharacters = [".", "$", "#", "[", "]", "/", " "]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.layer.borderColor = UIColor.whiteColor().CGColor
        usernameTextField.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        usernameTextField.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        usernameTextField.delegate = self
        
        fullNameTextField.layer.borderColor = UIColor.whiteColor().CGColor
        fullNameTextField.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        fullNameTextField.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        fullNameTextField.delegate = self
        
        ageTextField.layer.borderColor = UIColor.whiteColor().CGColor
        ageTextField.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        ageTextField.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        
        genderSegmentControl.layer.borderWidth = CGFloat(Constants.DEFAULTBORDERWIDTH)
        genderSegmentControl.layer.borderColor = UIColor.whiteColor().CGColor
        genderSegmentControl.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        genderSegmentControl.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        submitButton.layer.shadowRadius = 4
        submitButton.layer.shadowOpacity = 0.8
        submitButton.layer.shadowOffset = CGSizeZero

    }
    
    @IBAction func onTap(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        fullNameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }
    
    func setDatabaseValues(user: FIRUser){
        let baseRef = FIRDatabase.database().reference()
        
        let userRef = baseRef.child(Constants.USERSNODE).child(user.uid)
        var dict2 = [String: String]()
        if let age = ageTextField.text{
            dict2[Constants.USERAGE] = age
        }
        let genderIndex = genderSegmentControl.selectedSegmentIndex
        if genderIndex == 0{
            dict2[Constants.USERGENDER] = "M"
        } else if genderIndex == 1 {
            dict2[Constants.USERGENDER] = "F"
        }
        userRef.setValue(dict2)
        
        let unRef = baseRef.child(Constants.USERNAMESNODE).child(user.displayName!)
        var dict = [Constants.USERUID: user.uid]
        if let fullName = fullNameTextField.text{
            dict[Constants.USERFULLNAME] = fullName
        }
        unRef.setValue(dict, withCompletionBlock: {(error, reference)-> Void in
            if let er = error{
                print("COULD NOT SET USERNAME: \(er.localizedDescription)")
                self.submitButton.enabled = true
                return
            } else{
                self.delegate.onUserInfoSubmitted()
            }
        })
    }
    
    @IBAction func onSubmitButtonClicked(sender: AnyObject) {
        guard let un = username else {
            return
        }
        
        if let user = FIRAuth.auth()?.currentUser{
            submitButton.enabled = false
            
            let changeRequest = user.profileChangeRequest()
            
            changeRequest.displayName = un
            changeRequest.commitChangesWithCompletion({error in
                if let error = error{
                    print("COULD NOT CHANGE USERNAME: \(error.localizedDescription)")
                    self.submitButton.enabled = true
                } else {
                    print("successfully changed username")
                    self.setDatabaseValues(user)
                }
            })
            

        
        }
        
    }
    
    func getUserUID() -> String {
        return (FIRAuth.auth()?.currentUser?.uid)!
    }
}

extension SignUpUserInfoVC: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard textField == usernameTextField else{
            return
        }
        guard let newName = textField.text?.lowercaseString else {
            return
        }
        guard newName != "" else{
            return
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE).child(newName)
        ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if snapshot.exists(){
                print("CHECK USERNAME IS RETURNING: \(newName)")
                self.usernameTextField.text = ""
                self.usernameErrorLabel.hidden = false
                self.submitButton.enabled = false
            } else{
                self.usernameErrorLabel.hidden = true
                self.submitButton.enabled = true
                self.username = newName
            }
        })

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard textField == usernameTextField else {
            return true
        }
        if (disallowedCharacters.contains(string)) {
            return false
        }
        return true
    }
}

protocol SignUpUserInfoVCDelegate{
    func onUserInfoSubmitted()
}
