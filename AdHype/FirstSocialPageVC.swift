//
//  FirstSocialPageVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/4/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

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
