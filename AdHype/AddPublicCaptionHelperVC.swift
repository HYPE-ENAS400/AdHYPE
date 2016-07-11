//
//  TestVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/2/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class AddPublicCaptionHelperVC: UIViewController{
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var firstCaptionView: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var firstCaptionHighlightView: UIView!
    
    
    var touchIndicator: TouchIndicatorClass?
    var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 5
        shadowView.layer.shadowOffset = CGSizeZero
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = true
        shadowView.layer.masksToBounds = false
        plusButton.layer.cornerRadius = (plusButton.bounds.size.width/2)
        
        
    }
    
    // changing positions of the views so that animation loops properly
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        captionLabel.center.y += 50
        touchIndicatorOuterView.center.y -= 30
        startTouchAnimations()
    }
    
    func startTouchAnimations(){
        touchIndicator = TouchIndicatorClass(outerView: touchIndicatorOuterView, innerView: touchIndicatorInnerView, restartDelay: 1, delegate: self)
        touchIndicator?.startTouchIndicatorAnimations()
    }
    override func viewWillDisappear(animated: Bool) {
        touchIndicator?.endTouchIndicatorAnimations()
        touchIndicator?.delegate = nil
        touchIndicator = nil
        super.viewWillDisappear(animated)
    }

}

extension AddPublicCaptionHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation() {
        totalCount += 1
        if totalCount % 2 == 1{
            touchIndicatorOuterView.center.y += 30
        } else{
            touchIndicatorOuterView.center.y -= 80
        }
    }
    
    func onTouchIndicatorAppeared() {
//        instructionLabel.text = "tap a published comment to add it to the photo"
        
    }
    func onTouchIndicatorTappedDown() -> TouchType {
        if totalCount % 2 == 1{
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.firstCaptionHighlightView.alpha = 0.3
                
                }, completion: { finished in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.firstCaptionHighlightView.alpha = 0
                    })
            })
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.captionLabel.center.y -= 50
                self.captionLabel.alpha = 0.8
                }, completion: { finished in
                    
            })
            return TouchType.Tap
        } else {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.captionLabel.center.y += 50
                self.touchIndicatorOuterView.center.y += 50
                self.captionLabel.alpha = 0
                }, completion: { finished in
                    
            })
            return TouchType.LongPress(duration: 0.3)
        }
    }
    func onTouchIndicatorTappedUp() {

    }
    func onTouchIndicatorDissapeared() {
        if totalCount % 2 == 1{
            setNewInstructionText("and swipe down on the caption to remove it")
        } else {
            setNewInstructionText("Tap on a published caption to add it to the photo...")
        }
        
//        
//        UIView.animateWithDuration(0.2, animations: {
//            self.captionLabel.alpha = 0
//        })
        
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