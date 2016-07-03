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
        animateTouchIndicatorAppearance()
    }
    
    func animateTouchIndicatorAppearance(){
        UIView.animateWithDuration(0.1, delay: 1 , options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0.5
            self.touchIndicatorInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.animateSwipe()
        })
    }
    
    func animateSwipe(){
        UIView.animateWithDuration(1, delay: 0 , options: .CurveEaseOut, animations: {
            
            
            switch self.swipeDirection{
            case SwipeDirection.Up:
                self.touchIndicatorOuterView.center.y -= 100
                self.cardContainerView.center.y -= 100
            case SwipeDirection.Right:
                self.touchIndicatorOuterView.center.x += 100
                self.cardContainerView.center.x += 100
            case SwipeDirection.Left:
                self.touchIndicatorOuterView.center.x -= 100
                self.cardContainerView.center.x -= 100
            }
            
            }, completion: { finished in
                
                self.touchIndicatorOuterView.alpha = 0
                self.touchIndicatorInnerView.alpha = 0
                
                switch self.swipeDirection{
                case .Up:
                    self.touchIndicatorOuterView.center.y += 100
                case .Right:
                    self.touchIndicatorOuterView.center.x -= 100
                case .Left:
                    self.touchIndicatorOuterView.center.x += 100
                }
                self.resetAndRestartAnimation()
        })
    }
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 0 , options: .CurveEaseOut, animations: {
            switch self.swipeDirection{
            case .Up:
                self.cardContainerView.center.y += 100
            case .Left:
                self.cardContainerView.center.x += 100
            case .Right:
                self.cardContainerView.center.x -= 100
            }
            
            }, completion: { finished in
                self.animateTouchIndicatorAppearance()
        })
    }
    func resetAnimationsOnClose(){
        touchIndicatorOuterView.layer.removeAllAnimations()
        touchIndicatorInnerView.layer.removeAllAnimations()
        cardContainerView.layer.removeAllAnimations()
        cardContainerView.frame = initCardContainerFrame
        touchIndicatorOuterView.frame = initTouchIndicatorOuterViewFrame
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimationsOnClose()
    }
}