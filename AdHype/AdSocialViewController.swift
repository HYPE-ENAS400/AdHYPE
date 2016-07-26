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
    
    private var captionPlaceholders = ["Make history, be the first to write a caption!"]
    
    private var adCaptions = [(text: String, netVotes: Int, totalVotes: Int?, ref: String)]()
    private var adCaptionDetachInfo: FIRDetachInfo?
    
    var ad: HypeAd!
    var canPublish = false
    var wasSwipeUp: Bool!
    
    weak var delegate: AdSocialViewControllerDelegate!
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
        addCaptionButton.layer.shadowRadius = 2
        addCaptionButton.layer.shadowOpacity = 1
        addCaptionButton.layer.shadowOffset = CGSizeZero
        
        tableView.rowHeight = 70
        
        tableView.dataSource = self
        tableView.delegate = self
        captionTextView.delegate = self
        
        adImageView.image = ad.getImage()
        
        let id = (FIRAuth.auth()?.currentUser?.uid)!
        adVoteHistoryRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(id).child(Constants.ADCAPTIONVOTEHISTORYNODE).child(ad.getKey())
        
        tableView.allowsSelection = false
        ad.fetchAdCaptions({(result: FetchCaptionResult) -> Void in
            if case let .Success(newVal) = result{
                self.adCaptions.append(newVal)
                self.tableView.allowsSelection = true
                self.tableView.reloadData()
            }
            }, getDetachInfo: {(detachInfo: FIRDetachInfo) -> Void in
                self.adCaptionDetachInfo = detachInfo
            }
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard captionVisibleFrame == nil else {
            return
        }
        
        captionVisibleFrame = captionTextView.frame
        captionHiddenFrame = captionVisibleFrame
        captionHiddenFrame.origin.y += 70
        if captionTextView.hidden{
            captionTextView.frame = captionHiddenFrame
        } else {
            captionTextView.frame = captionVisibleFrame
        }
        
    }
    
    //NOTE, THIS PREVENTS NEW CAPTIONS FROM BEING LOADED AFTER TRYING TO SEND TO FRIENDS, CHANGE?
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detachInfo = adCaptionDetachInfo{
            detachInfo.ref.removeObserverWithHandle(detachInfo.handle)
        }
    }
    
    @IBAction func onCaptionTextViewSwipeDown(sender: AnyObject) {
        isCaptionVisible = false
        captionTextView.resignFirstResponder()
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
            adCaptions[index].totalVotes? += 1
        }
        
        let commentRef = ad.getAdPubCommentsRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref)
        let netRef = commentRef.child(Constants.ADCOMMENTVOTENODE)
        let newVal = 0 - adCaptions[index].netVotes
        netRef.setValue(newVal)
        if let totalVotes = adCaptions[index].totalVotes{
            let totalRef = commentRef.child(Constants.ADCOMMENTTOTALVOTES)
            totalRef.setValue(totalVotes)
        }

        
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
            adCaptions[index].totalVotes? += 1
        }
        
        let commentRef = ad.getAdPubCommentsRef().child(Constants.ADCOMMENTSNODE).child(adCaptions[index].ref)
        let netRef = commentRef.child(Constants.ADCOMMENTVOTENODE)
        let newVal = 0 - adCaptions[index].netVotes
        netRef.setValue(newVal)
        if let totalVotes = adCaptions[index].totalVotes{
            let totalRef = commentRef.child(Constants.ADCOMMENTTOTALVOTES)
            totalRef.setValue(totalVotes)
        }
        
        
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
        if adCaptions.count > 0 {
            return adCaptions.count
        } else{
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AdCaptionCell", forIndexPath: indexPath) as! AdCaptionCell
        
        guard adCaptions.count > 0 else{
            cell.adCaptionLabel.text = captionPlaceholders[0]
            cell.adVoteLabel.text = "--"
            cell.disableVoting()
            return cell
        }
        
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
        cell.enableVoting()
        cell.adCaptionLabel.text = adCaptions[indexPath.row].text
        cell.adVoteLabel.text = String(adCaptions[indexPath.row].netVotes)
        
        return cell
    }

}

protocol AdSocialViewControllerDelegate: class{
    func onCloseClicked()
    func onSendClicked(caption: String?, canPublish: Bool)
}


