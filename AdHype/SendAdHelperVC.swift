//
//  SendAdHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/3/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class SendAdHelperVC: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var publishIndicatorView: UIView!
    @IBOutlet weak var gIndicatorView: UIView!
    @IBOutlet weak var mIndicatorView: UIView!
    @IBOutlet weak var yIndicatorView: UIView!
    @IBOutlet weak var publishTableCell: UIView!
    @IBOutlet weak var mTableCell: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var publishTableCellHighlightView: UIView!
    @IBOutlet weak var mTableCellHighlightView: UIView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    var touchIndicator: TouchIndicatorClass?
    
    var totalRepeatCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishIndicatorView.layer.cornerRadius = (publishIndicatorView.layer.bounds.size.width/2)
        publishIndicatorView.layer.shadowRadius = 2
        publishIndicatorView.layer.shadowOffset = CGSizeZero
        publishIndicatorView.layer.shadowOpacity = 0.8
        
        gIndicatorView.layer.cornerRadius = (gIndicatorView.layer.bounds.size.width/2)
        gIndicatorView.layer.shadowRadius = 2
        gIndicatorView.layer.shadowOffset = CGSizeZero
        gIndicatorView.layer.shadowOpacity = 0.8
        
        mIndicatorView.layer.cornerRadius = (mIndicatorView.layer.bounds.size.width/2)
        mIndicatorView.layer.shadowRadius = 2
        mIndicatorView.layer.shadowOffset = CGSizeZero
        mIndicatorView.layer.shadowOpacity = 0.8
        
        yIndicatorView.layer.cornerRadius = (yIndicatorView.layer.bounds.size.width/2)
        yIndicatorView.layer.shadowRadius = 2
        yIndicatorView.layer.shadowOffset = CGSizeZero
        yIndicatorView.layer.shadowOpacity = 0.8
        
        containerView.layer.cornerRadius = 5
        shadowView.layer.shadowOffset = CGSizeZero
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = true
        shadowView.layer.masksToBounds = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startTouchAnimations()
    }
    
    func startTouchAnimations(){
        touchIndicator = TouchIndicatorClass(outerView: touchIndicatorOuterView, innerView: touchIndicatorInnerView, restartDelay: 2, delegate: self)
        touchIndicator?.startTouchIndicatorAnimations()
    }
}

extension SendAdHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation(){
        totalRepeatCount += 1
    }
    func onTouchIndicatorAppeared(){}
    func onTouchIndicatorTappedDown() -> TouchType{
        switch totalRepeatCount % 3{
        case 1:
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.publishTableCellHighlightView.alpha = 0.3
                self.publishIndicatorView.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)
                }, completion: { finished in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.publishTableCellHighlightView.alpha = 0
                    })
                    
            })
        case 2:
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                self.mTableCellHighlightView.alpha = 0.3
                self.mIndicatorView.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)
                }, completion: { finished in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.mTableCellHighlightView.alpha = 0
                    })
                    
            })
        case 0:
            sendButton.highlighted = true
        default:
            break
        }
        
        return TouchType.Tap
    }
    func onTouchIndicatorTappedUp(){
        if (totalRepeatCount % 3) == 0{
            sendButton.highlighted = false
        }
        
    }
    func onTouchIndicatorDissapeared(){
        var newCenter: CGPoint?
        switch totalRepeatCount % 3{
        case 1:
            newCenter = CGPointMake(self.mTableCell.center.x, self.mTableCell.center.y)
            setNewInstructionText("and which friends to send it to...")
        case 2:
            newCenter = CGPointMake(self.sendButton.center.x, self.sendButton.center.y)
            setNewInstructionText("then press the airplane to send")

        case 0:
            self.publishIndicatorView.backgroundColor = UIColor.whiteColor()
            self.mIndicatorView.backgroundColor = UIColor.whiteColor()
            newCenter = CGPointMake(self.publishTableCell.center.x, self.publishTableCell.center.y)
            setNewInstructionText("Select if you would like to publish your caption...")
        default:
            newCenter = nil
        }
        if let center = newCenter{
            self.touchIndicatorOuterView.center = center
        }
    }
    
    func setNewInstructionText(text: String){
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveLinear, animations: {
            self.instructionsLabel.alpha = 0
            }, completion: { finished in
                
                UIView.animateWithDuration(0.1, animations: {
                    self.instructionsLabel.text = text
                    self.instructionsLabel.alpha = 1
                })
                
        })
    }
}
