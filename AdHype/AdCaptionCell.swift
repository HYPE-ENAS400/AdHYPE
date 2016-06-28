//
//  AdCaptionCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/17/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class AdCaptionCell: UITableViewCell{
    
    @IBOutlet weak var adCaptionLabel: UILabel!
    @IBOutlet weak var adDownVoteButton: UIButton!
    @IBOutlet weak var adUpVoteButton: UIButton!
    @IBOutlet weak var adVoteLabel: UILabel!
    
    var hasVoted: Bool = false
    
    func changeButtonsForUpClicked(){
        hasVoted = true
        adUpVoteButton.setImage(UIImage(named: "REDup_button"), forState: UIControlState.Normal)
        adDownVoteButton.setImage(UIImage(named: "GREYdown_button"), forState: UIControlState.Normal)
        adUpVoteButton.enabled = false
        adDownVoteButton.enabled = true
    }
    
    func upButtonClicked() {
        
        var votes: Int = Int(adVoteLabel.text!)!
        if hasVoted{
            votes += 2
        } else{
            votes += 1
        }
        adVoteLabel.text = String(votes)

        changeButtonsForUpClicked()
    }
    
    func changeButtonsForDownClicked(){
        hasVoted = true
        adDownVoteButton.setImage(UIImage(named: "REDdown_button"), forState: UIControlState.Normal)
        adUpVoteButton.setImage(UIImage(named: "GREYup_button"), forState: UIControlState.Normal)
        adDownVoteButton.enabled = false
        adUpVoteButton.enabled = true
        
    }
    
    func downButtonClicked(){
        
        var votes: Int = Int(adVoteLabel.text!)!
        if hasVoted{
            votes -= 2
        } else {
            votes -= 1
        }
        adVoteLabel.text = String(votes)
        
        changeButtonsForDownClicked()
    }
    
    
//    @IBAction func onUpButtonClicked(sender: AnyObject) {
//        adUpVoteButton.setImage(UIImage(named: "REDup_button"), forState: UIControlState.Normal)
//        adDownVoteButton.setImage(UIImage(named: "GREYdown_button"), forState: UIControlState.Normal)
//        adUpVoteButton.enabled = false
//        adDownVoteButton.enabled = true
//    }
//    
//    
//    @IBAction func onDownButtonClicked(sender: AnyObject) {
//        adDownVoteButton.setImage(UIImage(named: "REDdown_button"), forState: UIControlState.Normal)
//        adUpVoteButton.setImage(UIImage(named: "GREYup_button"), forState: UIControlState.Normal)
//        adDownVoteButton.enabled = false
//        adUpVoteButton.enabled = true
//    }
    
    
}

