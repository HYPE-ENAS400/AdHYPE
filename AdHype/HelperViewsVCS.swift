//
//  HelperViewsVCS.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/27/16.
//  Genevieve did some stuff too (woo) 6/30/16
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class RightSwipePageVC: UIViewController{
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    
    var initCardContainerFrame: CGRect!
    var initTouchIndicatorOuterViewFrame: CGRect!
    
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
    
//    override func viewDid(animated: Bool) {
//        super.viewDidAppear(animated)
//        animateTouchIndicatorAppearance()
//    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animateTouchIndicatorAppearance()
    }
    
    func animateTouchIndicatorAppearance(){
        UIView.animateWithDuration(0.1, delay: 1 , options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0.5
            self.touchIndicatorInnerView.alpha = 0.5
            
            }, completion: { finished in
               self.animateSwipeRight()
        })
    }
    func animateSwipeRight(){
        UIView.animateWithDuration(0.8, delay: 0 , options: .CurveEaseOut, animations: {
            self.touchIndicatorOuterView.center.x += 100
            self.cardContainerView.center.x += 100
            }, completion: { finished in
                self.touchIndicatorOuterView.alpha = 0
                self.touchIndicatorInnerView.alpha = 0
                self.touchIndicatorOuterView.center.x -= 100
                self.resetAndRestartAnimation()
        })
    }
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 0 , options: .CurveEaseOut, animations: {
            self.cardContainerView.center.x -= 100
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

class LeftSwipePageVC: UIViewController{
    
    @IBOutlet weak var cardContainerView: UIView!
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    
    var initCardContainerFrame: CGRect!
    var initTouchIndicatorOuterViewFrame: CGRect!
    
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
                self.animateSwipeRight()
        })
    }
    func animateSwipeRight(){
        UIView.animateWithDuration(0.8, delay: 0 , options: .CurveEaseOut, animations: {
            self.touchIndicatorOuterView.center.x -= 100
            self.cardContainerView.center.x -= 100
            }, completion: { finished in
                self.touchIndicatorOuterView.alpha = 0
                self.touchIndicatorInnerView.alpha = 0
                self.touchIndicatorOuterView.center.x += 100
                self.resetAndRestartAnimation()
        })
    }
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 0 , options: .CurveEaseOut, animations: {
            self.cardContainerView.center.x += 100
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

class UpSwipePageVC: UIViewController{
    
    @IBOutlet weak var cardContainerView: UIView!
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    
    var initCardContainerFrame: CGRect!
    var initTouchIndicatorOuterViewFrame: CGRect!
    
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
                self.animateSwipeRight()
        })
    }
    func animateSwipeRight(){
        UIView.animateWithDuration(0.8, delay: 0 , options: .CurveEaseOut, animations: {
            self.touchIndicatorOuterView.center.y -= 100
            self.cardContainerView.center.y -= 100
            }, completion: { finished in
                self.touchIndicatorOuterView.alpha = 0
                self.touchIndicatorInnerView.alpha = 0
                self.touchIndicatorOuterView.center.y += 100
                self.resetAndRestartAnimation()
        })
    }
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 0 , options: .CurveEaseOut, animations: {
            self.cardContainerView.center.y += 100
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

class CommentPageVC: UIViewController{
    
    @IBOutlet weak var addCaptionButton: UIButton!
    @IBOutlet weak var divider1View: UIView!
    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var caption1View: UIView!
    @IBOutlet weak var addCatptionButton: UIButton!
    @IBOutlet weak var CommentTouchOuterView: UIView!
    @IBOutlet weak var CommentTouchInnerView: UIView!
    @IBOutlet weak var myCaptionText: UILabel!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var votesView: UIView!
    @IBOutlet weak var plusView: UIView!
    @IBOutlet weak var myCommentBarView: UIView!
    @IBOutlet weak var sendTouchOuterView: UIView!
    @IBOutlet weak var sendTouchInnerView: UIView!
    
    var initTouchIndicatorOuterViewFrame: CGRect!
    var initCommentTouchOuterViewFrame : CGRect!
    var initSendTouchOuterViewFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //captionTextView.contentInset.top = 0
        addCaptionButton.layer.cornerRadius = (addCaptionButton.bounds.size.height/2)
        addCaptionButton.layer.shadowRadius = 4
        addCaptionButton.layer.shadowOpacity = 0.6
        addCaptionButton.layer.shadowOffset = CGSizeZero
        
        
        initTouchIndicatorOuterViewFrame = touchIndicatorOuterView.frame
        
        touchIndicatorOuterView.layer.cornerRadius = (touchIndicatorOuterView.layer.frame.size.width/2)
        touchIndicatorInnerView.layer.cornerRadius = (touchIndicatorInnerView.layer.frame.size.width/2)
        
        initCommentTouchOuterViewFrame = CommentTouchOuterView.frame
        
        CommentTouchOuterView.layer.cornerRadius = (CommentTouchOuterView.layer.frame.size.width/2)
        CommentTouchInnerView.layer.cornerRadius = (CommentTouchInnerView.layer.frame.size.width/2)
        
        initSendTouchOuterViewFrame = sendTouchInnerView.frame
        
        sendTouchOuterView.layer.cornerRadius = (sendTouchOuterView.layer.frame.size.width/2)
        sendTouchInnerView.layer.cornerRadius = (sendTouchInnerView.layer.frame.size.width/2)
        
        
        //self.touchIndicatorOuterView.center.y = self.caption1View.center.y
        //self.touchIndicatorOuterView.center.x = self.caption1View.center.x

 
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.myCaptionText.alpha = 0
        delay(2){
            self.caption1View.backgroundColor = UIColor.lightGrayColor();
            self.animateTouchIndicatorAppearance()}
    }
    
    func animateTouchIndicatorAppearance(){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0.5
            self.touchIndicatorInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.myCaptionText.alpha = 0
                self.animateTouchIndicatorDisappearance()
        })
    }
    func animateTouchIndicatorDisappearance(){
        UIView.animateWithDuration(0.5, delay: 0 , options: .CurveLinear, animations: {
            self.touchIndicatorOuterView.alpha = 0
            self.touchIndicatorInnerView.alpha = 0
            }, completion: { finished in
                self.animateColorReturn()
        })
    }
    
    func animateColorReturn(){
        UIView.animateWithDuration(0.25, delay: 0 , options: .CurveLinear, animations: {
            self.myCaptionText.alpha = 1
            self.myCaptionText.text = "I actually like the ads in here"
            self.myCaptionText.center.y -= 70
            self.myCommentBarView.alpha=0.6
            self.myCommentBarView.center.y -= 70
            self.caption1View.backgroundColor = UIColor.whiteColor();
            
            }, completion: { finished in
                //self.resetAndRestartAnimation()
                self.animateAddComment()
        })
    }
    
    func animateAddComment(){
        UIView.animateWithDuration(0.5, delay: 5, options: .CurveLinear, animations: {
            self.CommentTouchOuterView.alpha = 0.7
            self.CommentTouchInnerView.alpha = 0.7
            
            }, completion: { finished in
                self.myCaptionText.text = ""
                self.animateCommentIndicatorDisappearance()
        })
    }
    
    func animateCommentIndicatorDisappearance(){
        UIView.animateWithDuration(0.5, delay: 0 , options: .CurveEaseOut, animations: {
            self.CommentTouchOuterView.alpha = 0.2
            self.CommentTouchInnerView.alpha = 0.2
            }, completion: { finished in
                self.CommentTouchOuterView.alpha = 0
                self.CommentTouchInnerView.alpha = 0
                self.animateTypeComment()
        })
    }
    
    func appendletter(index: Int){
        var myTextArray: [String] = ["G", "E", "T"," ","H","Y","P","E","D"]
        if (index>myTextArray.count-1){
            self.sendButtonPressAppear()
            return
        }
        else{delay(0.5){
            self.myCaptionText.text = self.myCaptionText.text! + myTextArray[index]
            self.appendletter(index+1)
            }
        }
    }
    
    func animateTypeComment(){
        delay(1){self.appendletter(0)}
    }
    
    
    func sendButtonPressAppear(){
        UIView.animateWithDuration(0.5, delay: 2, options: .CurveLinear, animations: {
            self.sendTouchOuterView.alpha = 0.5
            self.sendTouchInnerView.alpha = 0.5
        
            }, completion: { finished in
                delay(5){
                    self.resetAndRestartAnimation()}
        })
    }

    
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 0 , options: .CurveEaseOut, animations: {
            }, completion: { finished in
                self.sendTouchOuterView.alpha = 0
                self.sendTouchInnerView.alpha = 0
                self.myCaptionText.text = ""
                self.myCommentBarView.alpha = 0
                delay(5){
                    self.caption1View.backgroundColor = UIColor.lightGrayColor();
                    self.animateTouchIndicatorAppearance()}
        })
    }
    
    func resetAnimationsOnClose(){
        touchIndicatorOuterView.layer.removeAllAnimations()
        touchIndicatorInnerView.layer.removeAllAnimations()
        touchIndicatorOuterView.frame = initTouchIndicatorOuterViewFrame
        CommentTouchOuterView.layer.removeAllAnimations()
        CommentTouchInnerView.layer.removeAllAnimations()
        CommentTouchOuterView.frame = initCommentTouchOuterViewFrame
        sendTouchOuterView.layer.removeAllAnimations()
        sendTouchInnerView.layer.removeAllAnimations()
        sendTouchOuterView.frame = initSendTouchOuterViewFrame
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimationsOnClose()
    }

    
    
}

class SendPublishPageVC: UIViewController{
    
    @IBOutlet weak var publishView: UIView!
    @IBOutlet weak var publishButton: UIView!
    @IBOutlet weak var gButtonView: UIView!
    @IBOutlet weak var mButton: UIView!
    @IBOutlet weak var yButton: UIView!
    @IBOutlet weak var mTouchOuterView: UIView!
    @IBOutlet weak var mTouchInnerView: UIView!
    @IBOutlet weak var publishTouchOuterView: UIView!
    @IBOutlet weak var publishTouchInnerView: UIView!
    @IBOutlet weak var sendTouchOuterView: UIView!
    @IBOutlet weak var sendTouchInnerView: UIView!
    
    
    var initPublishTouchOuterViewFrame: CGRect!
    var initMTouchOuterViewFrame : CGRect!
    var initSendTouchOuterViewFrame : CGRect!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        publishButton.layer.cornerRadius = (publishButton.bounds.size.height/2)
        publishButton.layer.shadowRadius = 4
        publishButton.layer.shadowOpacity = 0.6
        publishButton.layer.shadowOffset = CGSizeZero
        
        gButtonView.layer.cornerRadius = (gButtonView.bounds.size.height/2)
        gButtonView.layer.shadowRadius = 4
        gButtonView.layer.shadowOpacity = 0.6
        gButtonView.layer.shadowOffset = CGSizeZero
        
        mButton.layer.cornerRadius = (publishButton.bounds.size.height/2)
        mButton.layer.shadowRadius = 4
        mButton.layer.shadowOpacity = 0.6
        mButton.layer.shadowOffset = CGSizeZero
        
        yButton.layer.cornerRadius = (publishButton.bounds.size.height/2)
        yButton.layer.shadowRadius = 4
        yButton.layer.shadowOpacity = 0.6
        yButton.layer.shadowOffset = CGSizeZero
        
        initPublishTouchOuterViewFrame = publishTouchOuterView.frame
        
        publishTouchOuterView.layer.cornerRadius = (publishTouchOuterView.layer.frame.size.width/2)
        publishTouchInnerView.layer.cornerRadius = (publishTouchInnerView.layer.frame.size.width/2)
        
        initMTouchOuterViewFrame = mTouchOuterView.frame
        
        mTouchOuterView.layer.cornerRadius = (mTouchOuterView.layer.frame.size.width/2)
        mTouchInnerView.layer.cornerRadius = (mTouchInnerView.layer.frame.size.width/2)
        
        initSendTouchOuterViewFrame = sendTouchOuterView.frame
        
        sendTouchOuterView.layer.cornerRadius = (sendTouchOuterView.layer.frame.size.width/2)
        sendTouchInnerView.layer.cornerRadius = (sendTouchInnerView.layer.frame.size.width/2)
        
        //self.publishTouchOuterView.alpha = 1
        //self.mTouchOuterView.alpha = 1
        //self.sendTouchOuterView.alpha = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.animatePublishTouchAppearance()
    }
    
    func animatePublishTouchAppearance(){
        UIView.animateWithDuration(0.5, delay: 2, options: .CurveLinear, animations: {
            self.publishTouchOuterView.alpha = 0.5
            self.publishTouchInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.publishButton.backgroundColor = UIColor(red: 1, green: 56/255, blue: 73/255, alpha: 1);
                self.animatePublishTouchDisappearance()
        })
    }
    func animatePublishTouchDisappearance(){
        UIView.animateWithDuration(0.5, delay: 0 , options: .CurveLinear, animations: {
            self.publishTouchOuterView.alpha = 0
            self.publishTouchInnerView.alpha = 0
            }, completion: { finished in
                    self.animateMTouchAppearance()
        })
    }
    
    func animateMTouchAppearance(){
        UIView.animateWithDuration(0.5, delay: 1, options: .CurveLinear, animations: {
            self.mTouchOuterView.alpha = 0.5
            self.mTouchInnerView.alpha = 0.5
            
            }, completion: { finished in
                self.mButton.backgroundColor = UIColor(red: 1, green: 56/255, blue: 73/255, alpha: 1);
                self.animateMTouchDisppearance()
        })
    }
    func animateMTouchDisppearance(){
        UIView.animateWithDuration(0.5, delay: 0 , options: .CurveLinear, animations: {
            self.mTouchOuterView.alpha = 0
            self.mTouchInnerView.alpha = 0
            }, completion: { finished in
                self.animateSendTouchAppearance()
        })
    }
    
    func animateSendTouchAppearance(){
        UIView.animateWithDuration(0.3, delay: 2, options: .CurveLinear, animations: {
            self.sendTouchOuterView.alpha = 0.5
            self.sendTouchInnerView.alpha = 0.5
            
            }, completion: { finished in
                delay(2){
                    self.resetAndRestartAnimation()}
        })
    }
    
    func resetAndRestartAnimation(){
        UIView.animateWithDuration(0.1, delay: 3 , options: .CurveEaseOut, animations: {
            }, completion: { finished in
                self.sendTouchOuterView.alpha = 0
                self.sendTouchInnerView.alpha = 0
                self.publishButton.backgroundColor = UIColor.whiteColor();
                self.mButton.backgroundColor = UIColor.whiteColor();
                self.animatePublishTouchAppearance()
        })
    }
    
    func resetAnimationsOnClose(){
        publishTouchOuterView.layer.removeAllAnimations()
        publishTouchInnerView.layer.removeAllAnimations()
        publishTouchOuterView.frame = initSendTouchOuterViewFrame
        mTouchOuterView.layer.removeAllAnimations()
        mTouchInnerView.layer.removeAllAnimations()
        mTouchOuterView.frame = initMTouchOuterViewFrame
        sendTouchOuterView.layer.removeAllAnimations()
        sendTouchInnerView.layer.removeAllAnimations()
        sendTouchOuterView.frame = initSendTouchOuterViewFrame
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimationsOnClose()
    }

    
}
