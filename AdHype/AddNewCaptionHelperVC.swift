//
//  AddNewCaptionHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/3/16.
//  Copyright © 2016 Enas400. All rights reserved.
//


import UIKit

class AddNewCaptionHelperVC: UIViewController{
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    var touchIndicator: TouchIndicatorClass?
    var captionTextArray = ["G", "E", "T"," ","H","Y","P","E","D"]
    
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
        touchIndicator = TouchIndicatorClass(outerView: touchIndicatorOuterView, innerView: touchIndicatorInnerView, restartDelay: 3, delegate: self)
        touchIndicator?.startTouchIndicatorAnimations()
    }
    
    func appendLettersToCaptionLabel(index: Int){
        guard index < captionTextArray.count else {
            return
        }
        delay(0.2){
            self.captionLabel.text = self.captionLabel.text! + self.captionTextArray[index]
            self.appendLettersToCaptionLabel(index + 1)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        touchIndicator?.endTouchIndicatorAnimations()
        touchIndicator?.delegate = nil
        touchIndicator = nil
        super.viewWillDisappear(animated)
    }

}
extension AddNewCaptionHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation() {
        captionLabel.text = " "
        UIView.animateWithDuration(0.2, animations: {
            self.captionLabel.alpha = 0
        })
    }
    
    func onTouchIndicatorAppeared(){

    }
    func onTouchIndicatorTappedDown() -> TouchType{
        captionLabel.center.y += 50
        plusButton.highlighted = true
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.captionLabel.center.y -= 50
            self.captionLabel.alpha = 0.8
            }, completion: { finished in
                
        })
        return TouchType.Tap
    }
    func onTouchIndicatorTappedUp(){
        plusButton.highlighted = false
        delay(0.5){self.appendLettersToCaptionLabel(0)}
    }
    func onTouchIndicatorDissapeared(){

    }
}


