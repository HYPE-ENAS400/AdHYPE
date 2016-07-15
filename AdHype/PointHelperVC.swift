//
//  PointHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/14/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class PointHelperVC: UIViewController{
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var shadowContainerView: UIView!
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var touchIndicatorOuterView: UIView!
    @IBOutlet weak var touchIndicatorInnerView: UIView!
    @IBOutlet weak var progressBar: KYCircularProgress!
    @IBOutlet weak var countLabel: UILabel!
    var contentCount = 17
    var adCount = 2
    
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.lineWidth = 4.0
        progressBar.guideLineWidth = 4.0
        progressBar.progressGuideColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        progressBar.showProgressGuide = true
        progressBar.colors = [UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)]
        progressBar.progress = 0.25
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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PointHelperVC.animateProgressIndicator), userInfo: nil, repeats: true)
        timer.fire()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func animateProgressIndicator(){
        adCount += 1
        let progress = adCount % Constants.ADSPERCONTENT
        progressBar.progress = Double(progress + 1)/Double(Constants.ADSPERCONTENT)
        if(progress) == Constants.ADSPERCONTENT - 1 {
            contentCount += 1
            countLabel.text = String(contentCount)
            
        }
    
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
}
