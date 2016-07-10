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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
    }
    
    func onTouchIndicatorAppeared() {
//        instructionLabel.text = "tap a published comment to add it to the photo"
        
    }
    func onTouchIndicatorTappedDown() -> TouchType {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.firstCaptionHighlightView.alpha = 0.3
            
            }, completion: { finished in
                
                UIView.animateWithDuration(0.3, animations: {
                    self.firstCaptionHighlightView.alpha = 0
                })
        })
        captionLabel.center.y += 50
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.captionLabel.center.y -= 50
            self.captionLabel.alpha = 0.8
            }, completion: { finished in
                
        })
        return TouchType.Tap
    }
    func onTouchIndicatorTappedUp() {
        
    }
    func onTouchIndicatorDissapeared() {
        UIView.animateWithDuration(0.2, animations: {
            self.captionLabel.alpha = 0
        })
        
    }
}