//
//  ClickSendHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/3/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class ClickSendHelperVC: UIViewController{
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    
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

extension ClickSendHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation(){}
    func onTouchIndicatorAppeared(){}
    func onTouchIndicatorTappedDown() -> TouchType{
        sendButton.highlighted = true
        return TouchType.Tap
    }
    func onTouchIndicatorTappedUp(){
        sendButton.highlighted = false
    }
    func onTouchIndicatorDissapeared(){}
}
