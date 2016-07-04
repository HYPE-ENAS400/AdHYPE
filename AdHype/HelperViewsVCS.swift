//
//  HelperViewsVCS.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/27/16.
//  Genevieve did some stuff too (woo) 6/30/16
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class RightSwipePageVC: SwipeCardHelperView{
    
    
    @IBOutlet weak var progressBar: KYCircularProgress!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet override weak var cardContainerView: UIView!{
        didSet{
            super.cardContainerView = cardContainerView
        }
    }
    
    @IBOutlet override weak var cardImageView: UIImageView!{
        didSet{
            super.cardImageView = cardImageView
        }
    }
    @IBOutlet override weak var touchIndicatorOuterView: UIView!{
        didSet{
            super.touchIndicatorOuterView = touchIndicatorOuterView
        }
    }
    
    @IBOutlet override weak var touchIndicatorInnerView: UIView!{
        didSet{
            super.touchIndicatorInnerView = touchIndicatorInnerView
        }
    }
    
    
    override func viewDidLoad() {
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
        super.swipeDirection = .Right
        super.viewDidLoad()
    }
    
    
}

class LeftSwipePageVC: SwipeCardHelperView{
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var progressBar: KYCircularProgress!
    
    @IBOutlet override weak var cardContainerView: UIView!{
        didSet{
            super.cardContainerView = cardContainerView
        }
    }
    @IBOutlet override weak var cardImageView: UIImageView!{
        didSet{
            super.cardImageView = cardImageView
        }
    }
    @IBOutlet override weak var touchIndicatorOuterView: UIView!{
        didSet{
            super.touchIndicatorOuterView = touchIndicatorOuterView
        }
    }
    @IBOutlet override weak var touchIndicatorInnerView: UIView!{
        didSet{
            super.touchIndicatorInnerView = touchIndicatorInnerView
        }
    }
    override func viewDidLoad() {
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
        super.swipeDirection = .Left
        super.viewDidLoad()
    }
}

class UpSwipePageVC: SwipeCardHelperView{
    
    @IBOutlet weak var progressBar: KYCircularProgress!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet override weak var cardContainerView: UIView!{
        didSet{
            super.cardContainerView = cardContainerView
        }
    }
    
    @IBOutlet override weak var cardImageView: UIImageView!{
        didSet{
            super.cardImageView = cardImageView
        }
    }
    
    @IBOutlet override weak var touchIndicatorOuterView: UIView!{
        didSet{
            super.touchIndicatorOuterView = touchIndicatorOuterView
        }
    }
    @IBOutlet override weak var touchIndicatorInnerView: UIView!{
        didSet{
            super.touchIndicatorInnerView = touchIndicatorInnerView
        }
    }
    
    override func viewDidLoad() {
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
        super.swipeDirection = .Up
        super.viewDidLoad()
    }
    
    
}

class FirstSocialPageVC: UIViewController{
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    
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
}
    