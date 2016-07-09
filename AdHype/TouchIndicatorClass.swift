//
//  HelperViewsBaseVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/3/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

enum TouchType{
    case Tap
    case DoubleTap
    case LongPress(duration: Double)
}

class TouchIndicatorClass{
    private weak var touchIndicatorOuterView: UIView!
    private weak var touchIndicatorInnerView: UIView!
    weak var delegate: TouchIndicatorDelegate?
    var restartAnimationDelay: Double
    var ended = false
    
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
        ended = true
    }
    
    private func animateTouchIndicatorAppearance(){
        guard !ended else {
            return
        }
        delegate?.onRestartingAnimation()
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0.5
            self.touchIndicatorInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.delegate?.onTouchIndicatorAppeared()
                self.animateTouchIndicatorTapDown()
        })
    }
    private func animateTouchIndicatorTapDown(){
        guard !ended else {
            return
        }
        UIView.animateWithDuration(0.2, delay: 0.5, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.transform = CGAffineTransformMakeScale(0.85, 0.85)
            
            }, completion: { finished in
                let touchType = self.delegate?.onTouchIndicatorTappedDown()
                guard let tt = touchType else{
                    return
                }
                switch tt{
                case .Tap:
                    self.animateTouchIndicatorTapUp()
                case .DoubleTap:
                    self.animateTouchIndicatorCompleteDoubleTap()
                case .LongPress(let dt):
                    delay(dt){self.animateTouchIndicatorTapUp()}
                }
        })
    }
    private func animateTouchIndicatorCompleteDoubleTap(){
        guard !ended else {
            return
        }
        UIView.animateWithDuration(0.2, animations: {
            self.touchIndicatorOuterView.transform = CGAffineTransformIdentity
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {
                    self.touchIndicatorOuterView.transform = CGAffineTransformMakeScale(0.85, 0.85)
                    }, completion: {finished in
                        self.animateTouchIndicatorTapUp()
                })
        })
    }
    
    private func animateTouchIndicatorTapUp(){
        guard !ended else {
            return
        }
        UIView.animateWithDuration(0.2, delay: 0.3, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.transform = CGAffineTransformIdentity
            
            }, completion: { finished in
                self.delegate?.onTouchIndicatorTappedUp()
                self.animateTouchIndicatorDissapearnce()
        })
    }
    private func animateTouchIndicatorDissapearnce(){
        guard !ended else {
            return
        }
        UIView.animateWithDuration(0.1, delay: 0.5, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0
            self.touchIndicatorInnerView.alpha = 0
            
            }, completion: { finished in
                self.delegate?.onTouchIndicatorDissapeared()

                delay(self.restartAnimationDelay){self.animateTouchIndicatorAppearance()}
        })
    }
    
}
//onTouchIndicatorTappedDown returns double for delays > standard tap press delays
protocol TouchIndicatorDelegate: class{
    func onRestartingAnimation()
    func onTouchIndicatorAppeared()
    func onTouchIndicatorTappedDown() -> TouchType
    func onTouchIndicatorTappedUp()
    func onTouchIndicatorDissapeared()
}
