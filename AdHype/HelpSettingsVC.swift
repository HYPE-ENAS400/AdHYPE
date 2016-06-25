//
//  HelpSettingsVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/22/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class HelpSettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate{
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var commentTypePicker: UIPickerView!
    
    var pickerData: [String]!
    var selectedRow: Int = 0
    
    var messageDelegate: DisplayMessageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitFeedbackButton.layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUS)
        submitFeedbackButton.layer.shadowOffset = CGSizeZero
        submitFeedbackButton.layer.shadowColor = UIColor.grayColor().CGColor
        submitFeedbackButton.layer.shadowRadius = 3
        submitFeedbackButton.layer.shadowOpacity = 1.0
        
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
    
    @IBAction func onSubmitFeedbackButtonClicked(sender: AnyObject) {
        messageDelegate.displayMessage("Thank you!", duration: 1.5)
        let ref = FIRDatabase.database().reference().child("feedback")
        ref.child(pickerData[selectedRow]).childByAutoId().setValue(feedbackTextView.text)
        feedbackTextView.text = ""
        
    }
}
