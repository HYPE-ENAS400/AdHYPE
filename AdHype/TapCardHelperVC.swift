//
//  TapCardHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/6/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class TapCardHelperVC: UIViewController{
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var shadowContainerView: UIView!
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var progressBar: KYCircularProgress!
    
    var touchIndicator: TouchIndicatorClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.lineWidth = 4.0
        progressBar.guideLineWidth = 4.0
        progressBar.progressGuideColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        progressBar.showProgressGuide = true
        progressBar.colors = [UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)]
        progressBar.progress = 0.75
        superContainerView.layer.cornerRadius = 5
        shadowContainerView.layer.shadowOffset = CGSizeZero
        shadowContainerView.layer.shadowOpacity = 1
        shadowContainerView.layer.shadowRadius = 8
        superContainerView.layer.masksToBounds = true
        shadowContainerView.layer.masksToBounds = false
        
        cardContainerView.layer.cornerRadius = 20
        cardContainerView.layer.shadowOpacity = 0.6
        cardContainerView.layer.shadowOffset = CGSizeZero
        cardContainerView.layer.shadowRadius = 5
        
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

extension TapCardHelperVC: TouchIndicatorDelegate{
    func onRestartingAnimation(){}
    func onTouchIndicatorAppeared(){}
    func onTouchIndicatorTappedDown() -> TouchType{return TouchType.Tap}
    func onTouchIndicatorTappedUp(){}
    func onTouchIndicatorDissapeared(){}
}
