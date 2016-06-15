//
//  UsersTableViewController.swift
//  Hype-2
//
//  Created by max payson on 4/19/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import Firebase

enum AnimationDirection{
    case Up
    case Down
    case Right
    case Left
}

enum GestureDirectionAction{
    case Hide
    case ChangeValue(String)
    case Show
}

class UsersTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var captionLabel: UITextView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    var userDictionary: [String: String]!
    var userNames: [String] = []
    var ownUID: String!
    var keyForFriend: String!
//    var ref: Firebase!
    var ad: HypeAd!
    var captions: [String] = []
    var currentCaptionIndex = 0 {
        didSet{
            if(currentCaptionIndex > oldValue){
                animateView(captionLabel, direction: .Right, action: .ChangeValue(captions[currentCaptionIndex]), duration: 0.4)
            } else {
                animateView(captionLabel, direction: .Left, action: .ChangeValue(captions[currentCaptionIndex]), duration: 0.4)
            }
            
            
        }
    }
    
    
    
    func animateView(view: UITextView, direction: AnimationDirection, action: GestureDirectionAction, duration: CFTimeInterval){
        let animation = CATransition()
        animation.type = kCATransitionPush
        switch direction {
        case .Up:
            animation.subtype = kCATransitionFromTop
        case .Down:
            animation.subtype = kCATransitionFromBottom
        case .Right:
            animation.subtype = kCATransitionFromRight
        case .Left:
            animation.subtype = kCATransitionFromLeft
        }
        animation.duration = duration
        
        view.layer.addAnimation(animation, forKey: "not sure what this does")
        switch action {
        case .Hide:
            view.hidden = true
        case .Show:
            view.hidden = false
        case .ChangeValue(let newText):
            view.hidden = false
            view.text = newText
        }
        
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            captionLabel.resignFirstResponder()
            
            if captionLabel.text == "" {
                removeEditing()
            } else {
                showAddButton()
            }
            
//            appendCaptions()
            return false
        }
        return true
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject){
        captionLabel.resignFirstResponder()
        
        if captionLabel.text == "" && captionLabel.editable == true{
            removeEditing()
        } else if captionLabel.editable == true{
            showAddButton()
        }

    }
    
    func removeEditing(){
        hideAddButton()
        
        captionLabel.editable = false
        
        if(captions.count > 0){
            animateView(captionLabel, direction: .Down, action: .ChangeValue(captions[currentCaptionIndex]), duration: 0.2)
        } else {
            animateView(captionLabel, direction: .Down, action: .Hide, duration: 0.2)
        }
    }
    
    func showAddButton(){
        editButton.hidden = true
        editButton.alpha = 0
        UIView.animateWithDuration(0.4, delay: 0.0 , options: .CurveEaseOut, animations: {
            self.addButton.hidden = false
            self.addButton.alpha = 0.8
            
            
            }, completion: { finished in
                
                print("Switch Buttons")
        })
    }
    
    func hideAddButton(){
        addButton.hidden = true
        addButton.alpha = 0
        UIView.animateWithDuration(0.4, delay: 0.0 , options: .CurveEaseOut, animations: {
            self.editButton.hidden = false
            self.editButton.alpha = 0.8
            
            
            }, completion: { finished in
                
                print("Switch Buttons")
        })
    }
    
    func appendCaptions(){
        if let text = captionLabel.text{
            captions.append(text)
            currentCaptionIndex = captions.count - 1
//            let fbRef = Firebase(url: "https://enas400hype.firebaseio.com/")
//            let newString = ad.getKey().stringByReplacingOccurrencesOfString(".jpg", withString: "")
//            fbRef.childByAppendingPath("ADS").childByAppendingPath(newString).childByAutoId().setValue(text)
        }
    }
    
    @IBAction func onAddButtonClicked(sender: AnyObject){
        appendCaptions()
        hideAddButton()
        captionLabel.editable = false
    }
    
    @IBAction func onEditButtonClicked(sender: AnyObject){
        
        if captionLabel.hidden == true && captions.count > 0{
            captionLabel.hidden=false
            UIView.animateWithDuration(0.2, delay: 0.0 , options: .CurveEaseOut, animations: {
                
                self.captionLabel.hidden = false
                
                var newBounds = self.editButton.frame
                newBounds.origin.y -= 90
                self.editButton.frame = newBounds
                
                var newLabelBounds = self.captionLabel.frame
                newLabelBounds.origin.y -= 70
                self.captionLabel.frame = newLabelBounds
                self.captionLabel.alpha = 0.7
                self.captionLabel.text = ""
                
                }, completion: { finished in
                    print("Moved edit button")
            })
        } else {
            animateView(captionLabel, direction: .Up, action: .ChangeValue(""), duration: 0.2)
        }
        
        
        captionLabel.editable = true
        captionLabel.becomeFirstResponder()

    }

    @IBAction func onSwipeRight(sender: UISwipeGestureRecognizer) {
        print("SWIPED RIGHT")
        if captionLabel.editable == false {
            let newIndex = currentCaptionIndex - 1
            if newIndex >= 0{
                currentCaptionIndex = newIndex
            }
        }
    }
    
    @IBAction func onSwipeLeft(sender: UISwipeGestureRecognizer){
        print("SWIPED LEFT")
        if captionLabel.editable == false {
            let newIndex = currentCaptionIndex + 1
            if newIndex < captions.count{
                currentCaptionIndex = newIndex
            }
        }
    }
    
    @IBAction func onSwipeDown(sender: UISwipeGestureRecognizer){
        print("SWIPED DOWN")
        captionLabel.editable = false
        hideAddButton()
//        animateView(captionLabel, direction: .Down, action: .Hide, duration: 0.2)
        UIView.animateWithDuration(0.2, delay: 0.0 , options: .CurveEaseOut, animations: {
            var newBounds = self.editButton.frame
            newBounds.origin.y += 90
            self.editButton.frame = newBounds
            
            var newLabelBounds = self.captionLabel.frame
            newLabelBounds.origin.y += 70
            self.captionLabel.frame = newLabelBounds
            self.captionLabel.alpha = 0.0
            

            }, completion: { finished in
                self.captionLabel.hidden = true
                print("Moved edit button")
        })
        
    }
    
    @IBAction func onImageSwipeUp(sender: UISwipeGestureRecognizer){
        if captionLabel.hidden == true && captions.count > 0{
            animateView(captionLabel, direction: .Up, action: .ChangeValue(captions[currentCaptionIndex]), duration: 0.2)
            UIView.animateWithDuration(0.2, delay: 0.0 , options: .CurveEaseOut, animations: {
                self.captionLabel.hidden = false
                var newBounds = self.editButton.frame
                newBounds.origin.y -= 90
                self.editButton.frame = newBounds
                
                var newLabelBounds = self.captionLabel.frame
                newLabelBounds.origin.y -= 70
                self.captionLabel.frame = newLabelBounds
                self.captionLabel.alpha = 0.7
                
                }, completion: { finished in
                    print("Moved edit button")
            })
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionLabel.textContainer.maximumNumberOfLines = 1
//        captionLabel.textContainer.lineBreakMode = NSLineBreakByTruncatingTail

//        imageView.image = ad.getImage()
//        keyForFriend = ad.getKey()
        
        captionLabel.editable = false
        captionLabel.delegate = self
 
        tableView.dataSource = self
        tableView.delegate = self
        
//        captions = ad.getCaptions()
        
        if(captions.count > 0){
            captionLabel.text = captions[currentCaptionIndex]
        } else {
            
            self.editButton.frame.origin.y -= 90

            captionLabel.hidden = true
        }
        
        userDictionary = [String:String]()
        
//        ref = Firebase(url: "https://enas400hype.firebaseio.com/").childByAppendingPath("users")
        
//        ref.queryOrderedByChild("username").observeEventType(.ChildAdded, withBlock: { snapshot in
//            if snapshot.key != self.ownUID{
//                if let name = snapshot.value["username"] as? String {
//                    self.userDictionary[name] = snapshot.key
//                    self.userNames.append(name)
//                    self.tableView.reloadData()
//            }
//            }
//        })
    }
    
//    override func viewWillAppear(animated: Bool) {
//        if !(captions.count > 0){
//            
//        }
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = userNames[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let uid = userDictionary[userNames[indexPath.row]]
        let key = keyForFriend.stringByReplacingOccurrencesOfString(".jpg", withString: "")
//        if captionLabel.hidden == false {
//            ref.childByAppendingPath(uid).childByAppendingPath("adsFromFriends").childByAppendingPath(key).setValue(captionLabel.text)
//        }
//        else {
//            ref.childByAppendingPath(uid).childByAppendingPath("adsFromFriends").childByAppendingPath(key).setValue(-1)
//        }
        self.performSegueWithIdentifier("unwindFromSwipeUpSegue", sender: nil)
        print(uid)
    }
    
    @IBAction func onCancelButtonClicked(sender: AnyObject){
        self.performSegueWithIdentifier("unwindFromSwipeUpSegue", sender: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}
