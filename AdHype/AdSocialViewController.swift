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
    private var adCaptionDetachInfo: FIRDetachInfo?
    
    var ad: HypeAd!
    var canPublish = false
    var wasSwipeUp: Bool!
    
    var delegate: AdSocialViewControllerDelegate!
    var adVoteHistoryRef: FIRDatabaseReference!
    
    var isCaptionVisible: Bool = false {
        
        didSet{
            
            guard oldValue != isCaptionVisible else{
                return
            }
            if isCaptionVisible{
                self.captionTextView.hidden = false
                UIView.animateWithDuration(0.3, delay: 0.0 , options: .CurveEaseOut, animations: {
                    self.captionTextView.frame = self.captionVisibleFrame
                    self.captionTextView.alpha = 0.8
                    
                    }, completion: { finished in
                        print("Animate captionTextView display")
        
                })
            } else {
                UIView.animateWithDuration(0.3, delay: 0.0 , options: .CurveEaseOut, animations: {
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
        super.viewDidLoad()
        captionTextView.contentInset.top = 0
        addCaptionButton.layer.cornerRadius = (addCaptionButton.bounds.size.height/2)
        addCaptionButton.layer.shadowRadius = 4
        addCaptionButton.layer.shadowOpacity = 0.6
        addCaptionButton.layer.shadowOffset = CGSizeZero
        
        tableView.rowHeight = 70
//        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.contentInset = insets
        
        tableView.dataSource = self
        tableView.delegate = self
        captionTextView.delegate = self
        
        adImageView.image = ad.getImage()
        let id = (FIRAuth.auth()?.currentUser?.uid)!
        adVoteHistoryRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(id).child(Constants.ADCAPTIONVOTEHISTORYNODE).child(ad.getKey())
        
        ad.fetchAdCaptions({(result: FetchCaptionResult) -> Void in
            if case let .Success(newVal) = result{
                self.adCaptions.append(newVal)
                self.tableView.reloadData()
            }
            }, getDetachInfo: {(detachInfo: FIRDetachInfo) -> Void in
                self.adCaptionDetachInfo = detachInfo
            }
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        captionVisibleFrame = captionTextView.frame
        captionHiddenFrame = captionVisibleFrame
        captionHiddenFrame.origin.y += 70
        if captionTextView.hidden{
            captionTextView.frame = captionHiddenFrame
        } else {
            captionTextView.frame = captionVisibleFrame
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detachInfo = adCaptionDetachInfo{
            detachInfo.ref.removeObserverWithHandle(detachInfo.handle)
        }
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
        captionTextView.resignFirstResponder()
    }

    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        delegate.onCloseClicked()
    }
    

    @IBAction func onClickSendButton(sender: AnyObject) {
        
        if isCaptionVisible && captionTextView.text != ""{
            delegate.onSendClicked(captionTextView.text, canPublish: captionTextView.editable)
        } else {
            delegate.onSendClicked(nil, canPublish: false)
        }
        
    }
    

    
    // NOTE If cells are deleted or added, then the indexpath of the cell will not match the sender tag
    // cells should never be added or deleted, however
    @IBAction func onUpVoteClicked(sender: AnyObject) {
        let index = sender.tag
        print("upVote clicked for index \(index)")
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AdCaptionCell
        
        if cell.hasVoted{
            adCaptions[index].netVotes += 2
        } else{
            adCaptions[index].netVotes += 1
        }
        
        let ref = ad.getAdPubCommentsRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref).child(Constants.ADCOMMENTVOTENODE)
        let newVal = 0 - adCaptions[index].netVotes
        ref.setValue(newVal)
        
        adVoteHistoryRef.child(adCaptions[index].ref).setValue(true)

        cell.upButtonClicked()
    }
    
    // NOTE If cells are deleted or added, then the indexpath of the cell will not match the sender tag
    // cells should never be added or deleted, however
    @IBAction func onDownVoteClicked(sender: AnyObject) {
        let index = sender.tag
        print("upVote clicked for index \(index)")
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AdCaptionCell
        
        if cell.hasVoted{
            adCaptions[index].netVotes -= 2
        } else{
            adCaptions[index].netVotes -= 1
        }
        
        let ref = ad.getAdPubCommentsRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref).child(Constants.ADCOMMENTVOTENODE)
        let newVal = 0 - adCaptions[index].netVotes
        ref.setValue(newVal)
        
        
        adVoteHistoryRef.child(adCaptions[index].ref).setValue(false)

        cell.downButtonClicked()

    }
    
    
    
}

extension AdSocialViewController: UITextViewDelegate{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
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
        
        let ref = adVoteHistoryRef.child(adCaptions[indexPath.row].ref)
        ref.observeSingleEventOfType(.Value, withBlock: {(snapshot)->Void in
            if let vote = snapshot.value as? Bool {
                if vote{
                    cell.changeButtonsForUpClicked()
                }else{
                    cell.changeButtonsForDownClicked()
                }
            }
        })
        
        cell.adUpVoteButton.tag = indexPath.row
        cell.adDownVoteButton.tag = indexPath.row
        
        cell.adCaptionLabel.text = adCaptions[indexPath.row].text
        cell.adVoteLabel.text = String(adCaptions[indexPath.row].netVotes)
        
        return cell
    }

}

protocol AdSocialViewControllerDelegate{
    func onCloseClicked()
    func onSendClicked(caption: String?, canPublish: Bool)
}


