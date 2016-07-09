//
//  SwipeCardHelperView.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/30/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

enum SwipeDirection{
    case Up
    case Left
    case Right
}

class SwipeCardHelperView: UIViewController{
    weak var cardContainerView: UIView!
    weak var cardImageView: UIImageView!
    
    weak var touchIndicatorInnerView: UIView!
    weak var touchIndicatorOuterView: UIView!
    
    private var initCardContainerFrame: CGRect!
    private var initTouchIndicatorOuterViewFrame: CGRect!
    private var touchIndicator: TouchIndicatorClass?
    
    var swipeDirection = SwipeDirection.Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardContainerView.layer.cornerRadius = 20
        cardContainerView.layer.shadowOpacity = 0.6
        cardContainerView.layer.shadowOffset = CGSizeZero
        cardContainerView.layer.shadowRadius = 5
        
        initCardContainerFrame = cardContainerView.frame
        initTouchIndicatorOuterViewFrame = touchIndicatorOuterView.frame
        
        touchIndicatorOuterView.layer.cornerRadius = (touchIndicatorOuterView.layer.frame.size.width/2)
        touchIndicatorInnerView.layer.cornerRadius = (touchIndicatorInnerView.layer.frame.size.width/2)
        
        cardImageView.layer.cornerRadius = 20
        cardImageView.layer.masksToBounds = true
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
extension SwipeCardHelperView: TouchIndicatorDelegate{
    func onRestartingAnimation(){}
    func onTouchIndicatorAppeared(){}
    func onTouchIndicatorTappedDown() -> TouchType{
        let animationTime = 1.0
        UIView.animateWithDuration(animationTime, animations: {
            switch self.swipeDirection{
            case .Up:
                self.cardContainerView.center.y -= 80
            case .Left:
                self.cardContainerView.center.x -= 80
            case .Right:
                self.cardContainerView.center.x += 80
            }
        
        })
        return TouchType.LongPress(duration: animationTime)
    }
    func onTouchIndicatorTappedUp(){
        
    }
    func onTouchIndicatorDissapeared(){
        UIView.animateWithDuration(0.1, animations: {
            switch self.swipeDirection{
            case .Up:
                self.cardContainerView.center.y += 80
            case .Left:
                self.cardContainerView.center.x += 80
            case .Right:
                self.cardContainerView.center.x -= 80
            }
            
        })
    }
}