//
//  FriendBoardHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/4/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class FriendBoardHelperVC: UIViewController{
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    
    @IBOutlet weak var friendButtonUnderlineView: UIView!
    @IBOutlet weak var userButtonUnderlineView: UIView!
    
    @IBOutlet weak var ad1ContainerView: UIView!
    @IBOutlet weak var ad1ImageView: UIImageView!
    
    @IBOutlet weak var ad2ContainerView: UIView!
    @IBOutlet weak var ad2ImageView: UIImageView!
    
    @IBOutlet weak var ad3ContainerView: UIView!
    @IBOutlet weak var ad3DeleteButton: UIButton!
    @IBOutlet weak var ad3ImageView: UIImageView!

    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    var touchIndicator: TouchIndicatorClass?
    var totalResetCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 5
        shadowView.layer.shadowOffset = CGSizeZero
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = true
        shadowView.layer.masksToBounds = false
        
        ad1ContainerView.layer.cornerRadius = 2
        ad1ImageView.layer.cornerRadius = 2
        ad1ContainerView.layer.shadowRadius = 1
        ad1ContainerView.layer.shadowOffset = CGSizeZero
        ad1ContainerView.layer.shadowOpacity = 1
        
        ad2ContainerView.layer.cornerRadius = 2
        ad2ImageView.layer.cornerRadius = 2
        ad2ContainerView.layer.shadowRadius = 1
        ad2ContainerView.layer.shadowOffset = CGSizeZero
        ad2ContainerView.layer.shadowOpacity = 1
        
        ad3ContainerView.layer.cornerRadius = 2
        ad3ImageView.layer.cornerRadius = 2
        ad3DeleteButton.layer.cornerRadius = 2
        ad3ContainerView.layer.shadowRadius = 1
        ad3ContainerView.layer.shadowOffset = CGSizeZero
        ad3ContainerView.layer.shadowOpacity = 1
        ad3DeleteButton.backgroundColor = UIColor.grayColor()
        ad3DeleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        ad3DeleteButton.setTitle("SAVE!", forState: .Normal)
        
        
        userButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        friendButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startTouchAnimations()
    }
    
    func startTouchAnimations(){
        touchIndicator = TouchIndicatorClass(outerView: touchIndicatorOuterView, innerView: touchIndicatorInnerView, restartDelay: 0.5, delegate: self)
        touchIndicator?.startTouchIndicatorAnimations()
    }
    override func viewWillDisappear(animated: Bool) {
        touchIndicator?.endTouchIndicatorAnimations()
        touchIndicator?.delegate = nil
        touchIndicator = nil
        super.viewWillDisappear(animated)
    }
    
}

extension FriendBoardHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation(){
        totalResetCount += 1
        switch totalResetCount % 2{
        case 1:
            friendButtonUnderlineView.hidden = true
            userButtonUnderlineView.hidden = false
            ad3ContainerView.hidden = true
            UIView.animateWithDuration(0.1, animations: {
                self.ad3DeleteButton.alpha = 0
            })
            
        case 0:
            return
        default:
            return
        }
    }
    func onTouchIndicatorAppeared(){}
    func onTouchIndicatorTappedDown() -> TouchType{
        switch totalResetCount % 2{
        case 1:
            friendButton.highlighted = true
            return TouchType.Tap
        case 0:
            return TouchType.LongPress(duration: 1)
        default:
            return TouchType.Tap
        }
    
    }
    func onTouchIndicatorTappedUp(){
        switch totalResetCount % 2{
        case 1:
            friendButton.highlighted = false
            friendButtonUnderlineView.hidden = false
            userButtonUnderlineView.hidden = true
            ad3ContainerView.hidden = false
        case 0:
            UIView.animateWithDuration(0.3, animations: {
                self.ad3DeleteButton.alpha = 0.7
            })
        default:
            return
        }

    }
    func onTouchIndicatorDissapeared(){
        switch totalResetCount % 2{
        case 1:
            touchIndicatorOuterView.center.x += 15
            touchIndicatorOuterView.center.y += 40
            setNewInstructionText("Here you can save friends' content with a long press")
        case 0:
            touchIndicatorOuterView.center.x -= 15
            touchIndicatorOuterView.center.y -= 40
            setNewInstructionText("Tap the friend icon to see your friends' boards...")
        default:
            return
        }
    
    }
    
    func setNewInstructionText(text: String){
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveLinear, animations: {
            self.instructionLabel.alpha = 0
            }, completion: { finished in
                
                UIView.animateWithDuration(0.1, animations: {
                    self.instructionLabel.text = text
                    self.instructionLabel.alpha = 1
                })
                
        })
    }
}
