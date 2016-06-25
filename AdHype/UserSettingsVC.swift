//
//  UserSettingsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsVC: UIViewController{
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userIconOuterView: UIView!
    @IBOutlet weak var interestsTableView: SelectionTableView!
    
    var messageDelegate: DisplayMessageDelegate!
    
    var interestsDataSource: SelectionDataSource<Bool>!
    var interestsRef: FIRDatabaseReference!
    var oldUserName: String?
    
    let disallowedCharacters = [".", "$", "#", "[", "]", "/", " "]
    
    override func viewDidLoad() {
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("COULD NOT GET USER OPENING SETTINGS")
            return
        }
        
        initializeButtonLayer(logOutButton)
        
        usernameTextField.delegate = self
        interestsTableView.selectionDelegate = self
        for i in 0..<interestsDataSource.getCount(){
            if interestsDataSource.getValueAtIndex(i){
                interestsTableView.addPreselectedIndex(i)
            }
        }
        
        userIconOuterView.layer.cornerRadius = (userIconOuterView.bounds.size.height/2)
        
        interestsRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(user.uid).child(Constants.USERINTERESTSNODE)
        
        if let name = user.displayName{
            usernameTextField.text = name
            oldUserName = name
        }
    }
    
    func initializeButtonLayer(button: UIButton){
        button.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSizeZero
        button.layer.shadowColor = UIColor.grayColor().CGColor
    }
    
    func updateUsername(name: String) {
        oldUserName = name
        
        if let user = FIRAuth.auth()?.currentUser{
            let changeRequest = user.profileChangeRequest()
            
            changeRequest.displayName = name
            changeRequest.commitChangesWithCompletion({error in
                if let error = error{
                    print("COULD NOT CHANGE USERNAME: \(error.localizedDescription)")
                } else {
                    print("successfully changed username")
                }
            })
            let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE).child(name)
            ref.setValue(user.uid)
        }
    }
    
//    @IBAction func onSaveClicked(sender: AnyObject) {
//        messageDelegate.displayMessage("Saved!", duration: 1.5)
//    }
    
    @IBAction func onSignOutClicked(sender: AnyObject) {
        let keychainWrapper = KeychainWrapper.standardKeychainAccess()
        keychainWrapper.removeObjectForKey(Constants.PASSKEY)
        keychainWrapper.removeObjectForKey(Constants.USERKEY)
        
        try! FIRAuth.auth()!.signOut()
    }
}

extension UserSettingsVC: SelectionTableViewDelegate{
    func cellAtIndexSelected(index: Int) {
        interestsRef.child(interestsDataSource.getKeyAtIndex(index)).setValue(true)
        interestsDataSource.setValueAtIndex(index, value: true)
    }
    func cellAtIndexDeselected(index: Int) {
        interestsRef.child(interestsDataSource.getKeyAtIndex(index)).setValue(false)
        interestsDataSource.setValueAtIndex(index, value: false)
    }
    func getNumberOfCells() -> Int {
        return interestsDataSource.getCount()
    }
    func getCellTextAtIndex(index: Int) -> String? {
        return interestsDataSource.getKeyAtIndex(index)
    }
    func getCellColorAtIndex(index: Int) -> UIColor? {
        return nil
    }
}

extension UserSettingsVC: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("closing first responder")
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let newName = textField.text?.lowercaseString
        if newName == oldUserName {
            return
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.USERNAMESNODE).child(newName!)
        ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if snapshot.exists(){
                print("CHECK USERNAME IS RETURNING: \(newName)")
                self.usernameTextField.text = self.oldUserName
                self.messageDelegate.displayMessage("username must be unique", duration: 1.5)
            } else{
                self.updateUsername(newName!)
            }
        })
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (disallowedCharacters.contains(string)) {
            return false
        }
        return true
    }
}
