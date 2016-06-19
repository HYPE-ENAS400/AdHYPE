//
//  AdSocialViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/16/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase

class AdSocialViewController: UIViewController {
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var addCaptionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adImageView: UIImageView!
    
    private var captionVisibleFrame: CGRect!
    private var captionHiddenFrame: CGRect!
    
    private var adCaptions = [(text: String, netVotes: Int, ref: String)]()
//    private var adCaptions = [String]()
    
    var ad: HypeAd!
    var canPublish = false
    
    var didCancel: Bool = false
    
    var isCaptionVisible: Bool = false {
        
        didSet{
            
            guard oldValue != isCaptionVisible else{
                return
            }
            if isCaptionVisible{
                self.captionTextView.hidden = false
                UIView.animateWithDuration(0.2, delay: 0.0 , options: .CurveEaseOut, animations: {
                    self.captionTextView.frame = self.captionVisibleFrame
                    self.captionTextView.alpha = 0.8
                    
                    }, completion: { finished in
                        print("Animate captionTextView display")
        
                })
            } else {
                UIView.animateWithDuration(0.2, delay: 0.0 , options: .CurveEaseOut, animations: {
                    self.captionTextView.frame = self.captionHiddenFrame
                    self.captionTextView.alpha = 0
                    
                    }, completion: { finished in
                        self.captionTextView.hidden = true
                        print("Animate captionTextView hide")
                })
            }
        }
    }
    
    var isAddButtonVisible: Bool = true {
        didSet{
            guard oldValue != isAddButtonVisible else{
                return
            }
            if isAddButtonVisible {
                UIView.animateWithDuration(0.3, animations: {
                    self.addCaptionButton.alpha = 1
                })
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    self.addCaptionButton.alpha = 0
                })
            }
        }
    }
    
    override func viewDidLoad() {
        captionTextView.contentInset.top = 0
        addCaptionButton.layer.cornerRadius = (addCaptionButton.bounds.size.height/2)
        addCaptionButton.layer.shadowRadius = 4
        addCaptionButton.layer.shadowOpacity = 0.6
        addCaptionButton.layer.shadowOffset = CGSizeZero
        
        tableView.rowHeight = 70
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        
        tableView.dataSource = self
        tableView.delegate = self
        captionTextView.delegate = self
        
        captionVisibleFrame = self.captionTextView.frame
        captionHiddenFrame = captionVisibleFrame
        captionHiddenFrame.origin.y += 70
        
//        for _ in 1..<15 {
//            adCaptions.append("blah blah blah blah blah blah blah blah blah blah")
//        }
        
        adImageView.image = ad.getImage()
        
        ad.fetchAdCaptions({(result: FetchCaptionResult) -> Void in
            if case let .Success(newVal) = result{
                self.adCaptions.append(newVal)
                self.tableView.reloadData()
            }
        })
    }

    
    @IBAction func onCaptionTextViewSwipeDown(sender: AnyObject) {
        isCaptionVisible = false
    }
    
    @IBAction func onAddCaptionButtonClicked(sender: AnyObject) {
        isCaptionVisible = true
        captionTextView.editable = true
        captionTextView.becomeFirstResponder()
        captionTextView.text = ""
    }

    @IBAction func dismissKeyboardOnImageTap(sender: AnyObject) {
//        isAddButtonVisible = true
        captionTextView.resignFirstResponder()
    }

    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        didCancel = true
        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "onSendToFriendsSegue" {
            let newVC = segue.destinationViewController as! FriendsTableViewController
            newVC.adName = ad.getAdName()
            if isCaptionVisible {
                newVC.captionText = captionTextView.text
                newVC.canPublish = captionTextView.editable
            }
        }
    }

    @IBAction func onClickSendButton(sender: AnyObject) {
        
        self.performSegueWithIdentifier("onSendToFriendsSegue", sender: nil)
        
//        if captionTextView.editable == true{
//            //create a new comment
//            let commentRef = ad.getAdDatRef().child(Constants.ADCOMMENTSNODE).childByAutoId()
//            commentRef.child(Constants.ADCOMMENTTEXTNODE).setValue(captionTextView.text)
//            commentRef.child(Constants.ADCOMMENTVOTENODE).setValue(0)
//        }
//        
//        didCancel = false
//        self.performSegueWithIdentifier("unwindFromAdSocialViewSegue", sender: nil)
    }
    
    @IBAction func unwindFromSendToFriendsSegueClose(segue: UIStoryboardSegue){
        
    }
    
    // NOTE If cells are deleted or added, then the indexpath of the cell will not match the sender tag
    // cells should never be added or deleted, however
    
    
    @IBAction func onUpVoteClicked(sender: AnyObject) {
        let index = sender.tag
        print("upVote clicked for index \(index)")
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AdCaptionCell
        
        cell.upButtonClicked()
        adCaptions[index].netVotes += 1
        
        let ref = ad.getAdDatRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref).child(Constants.ADCOMMENTVOTENODE)
        ref.setValue(adCaptions[index].netVotes)
    }
    
    // NOTE If cells are deleted or added, then the indexpath of the cell will not match the sender tag
    // cells should never be added or deleted, however
    @IBAction func onDownVoteClicked(sender: AnyObject) {
        let index = sender.tag
        print("upVote clicked for index \(index)")
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AdCaptionCell
        
        cell.downButtonClicked()
        adCaptions[index].netVotes -= 1
        
        let ref = ad.getAdDatRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref).child(Constants.ADCOMMENTVOTENODE)
        ref.setValue(adCaptions[index].netVotes)

    }
    
    
    
}

extension AdSocialViewController: UITextViewDelegate{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
//            isAddButtonVisible = true
            captionTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        isAddButtonVisible = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        isAddButtonVisible = true
    }
    
}

extension AdSocialViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        captionTextView.text = adCaptions[indexPath.row]
        captionTextView.text = adCaptions[indexPath.row].text
        isCaptionVisible = true
        captionTextView.editable = false
    }
}

extension AdSocialViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adCaptions.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AdCaptionCell", forIndexPath: indexPath) as! AdCaptionCell
        
        cell.adUpVoteButton.tag = indexPath.row
        cell.adDownVoteButton.tag = indexPath.row
        
        
        cell.adCaptionLabel.text = adCaptions[indexPath.row].text
//        cell.adCaptionLabel.text = adCaptions[indexPath.row]
        cell.adVoteLabel.text = String(adCaptions[indexPath.row].netVotes)
        
        return cell
    }

}


