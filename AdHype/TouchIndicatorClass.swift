//
//  HelperViewsBaseVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/3/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class TouchIndicatorClass{
    private weak var touchIndicatorOuterView: UIView!
    private weak var touchIndicatorInnerView: UIView!
    var delegate: TouchIndicatorDelegate!
    var restartAnimationDelay: Double
    
    required init(outerView: UIView, innerView: UIView, restartDelay: Double, delegate: TouchIndicatorDelegate){
        self.touchIndicatorOuterView = outerView
        self.touchIndicatorInnerView = innerView
        self.delegate = delegate
        self.restartAnimationDelay = restartDelay
        createCircleFromView(self.touchIndicatorInnerView)
        createCircleFromView(self.touchIndicatorOuterView)
        
    }
    
    private func createCircleFromView(view: UIView){
        view.layer.cornerRadius = (view.layer.bounds.width/2)
    }
    
    func startTouchIndicatorAnimations(){
        delay(0.2){self.animateTouchIndicatorAppearance()}
    }
    
    func endTouchIndicatorAnimations(){
        touchIndicatorInnerView.layer.removeAllAnimations()
        touchIndicatorOuterView.layer.removeAllAnimations()
        touchIndicatorOuterView.transform = CGAffineTransformIdentity
        touchIndicatorInnerView.transform = CGAffineTransformIdentity
        touchIndicatorInnerView.alpha = 0
        touchIndicatorOuterView.alpha = 0
    }
    
    private func animateTouchIndicatorAppearance(){
        delegate.onRestartingAnimation()
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0.5
            self.touchIndicatorInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.delegate.onTouchIndicatorAppeared()
                self.animateTouchIndicatorTapDown()
        })
    }
    private func animateTouchIndicatorTapDown(){
        UIView.animateWithDuration(0.2, delay: 0.5, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.transform = CGAffineTransformMakeScale(0.85, 0.85)
            
            }, completion: { finished in
                let delayTime = self.delegate.onTouchIndicatorTappedDown()
                if let dt = delayTime{
                    delay(dt){self.animateTouchIndicatorTapUp()}
                } else{
                    self.animateTouchIndicatorTapUp()
                }
        })
    }
    private func animateTouchIndicatorTapUp(){
        UIView.animateWithDuration(0.2, delay: 0.3, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.transform = CGAffineTransformIdentity
            
            }, completion: { finished in
                self.delegate.onTouchIndicatorTappedUp()
                self.animateTouchIndicatorDissapearnce()
        })
    }
    private func animateTouchIndicatorDissapearnce(){
        UIView.animateWithDuration(0.1, delay: 0.5, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0
            self.touchIndicatorInnerView.alpha = 0
            
            }, completion: { finished in
                self.delegate.onTouchIndicatorDissapeared()

                delay(self.restartAnimationDelay){self.animateTouchIndicatorAppearance()}
        })
    }
    
}
//onTouchIndicatorTappedDown returns double for delays > standard tap press delays
protocol TouchIndicatorDelegate{
    func onRestartingAnimation()
    func onTouchIndicatorAppeared()
    func onTouchIndicatorTappedDown() -> Double?
    func onTouchIndicatorTappedUp()
    func onTouchIndicatorDissapeared()
}
