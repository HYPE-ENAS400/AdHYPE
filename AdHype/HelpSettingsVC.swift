//
//  HelpSettingsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

class HelpSettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate{
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var commentTypePicker: UIPickerView!
    
    var pickerData: [String]!
    var selectedRow: Int = 0
    
    weak var messageDelegate: DisplayMessageDelegate!
    weak var delegate: HelpSettingsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeAppButtonLayer(submitFeedbackButton.layer)
        initializeAppButtonLayer(helpButton.layer)
        initializeAppButtonLayer(privacyPolicyButton.layer)
        
        pickerData = ["bug--minor", "bug--critical", "user interface", "general feedback"]
        commentTypePicker.dataSource = self
        commentTypePicker.delegate = self
        
        feedbackTextView.delegate = self
    
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerData[row]
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.darkGrayColor()])
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            //            isAddButtonVisible = true
            feedbackTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    override func viewDidDisappear(animated: Bool) {
        feedbackTextView.text = ""
    }
    
    func getUserName() -> String{
        return (FIRAuth.auth()?.currentUser?.displayName)!
    }
    @IBAction func helpButtonClicked(sender: AnyObject) {
        delegate.onOpenHelperViews()
    }
    
    @IBAction func onSubmitFeedbackButtonClicked(sender: AnyObject) {
        messageDelegate.displayMessage("Thank you!", duration: 1.5)
        let ref = FIRDatabase.database().reference().child("feedback")
        ref.child(pickerData[selectedRow]).childByAutoId().setValue(feedbackTextView.text + "from: \(getUserName())")
        feedbackTextView.text = ""
        
    }
    @IBAction func onPrivacyPolicyButtonClicked(sender: AnyObject) {
        

        guard let url = NSURL(string: "https://www.iubenda.com/privacy-policy/7874766") else {
            return
        }
        let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
        presentViewController(vc, animated: true, completion: nil)

    }

    @IBAction func onTapFeedbackView(sender: AnyObject) {
        feedbackTextView.resignFirstResponder()
    }

}

protocol HelpSettingsDelegate: class{
    func onOpenHelperViews()
}
