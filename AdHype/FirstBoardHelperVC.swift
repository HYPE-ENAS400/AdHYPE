//
//  FirstBoardHelperVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/4/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class FirstBoardHelperVC: UIViewController{
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    
    @IBOutlet weak var ad1ContainerView: UIView!
    @IBOutlet weak var ad1ImageView: UIImageView!
    
    @IBOutlet weak var ad2ContainerView: UIView!
    @IBOutlet weak var ad2ImageView: UIImageView!
    
    @IBOutlet weak var ad3ContainerView: UIView!
    @IBOutlet weak var ad3DeleteButton: UIButton!
    @IBOutlet weak var ad3ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 5
        shadowView.layer.shadowOffset = CGSizeZero
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = true
        shadowView.layer.masksToBounds = false
        
        ad1ContainerView.layer.cornerRadius = 2
        ad1ImageView.layer.cornerRadius = 2
        ad1ContainerView.layer.shadowRadius = 1
        ad1ContainerView.layer.shadowOffset = CGSizeZero
        ad1ContainerView.layer.shadowOpacity = 1
        
        ad2ContainerView.layer.cornerRadius = 2
        ad2ImageView.layer.cornerRadius = 2
        ad2ContainerView.layer.shadowRadius = 1
        ad2ContainerView.layer.shadowOffset = CGSizeZero
        ad2ContainerView.layer.shadowOpacity = 1
        
        ad3ContainerView.layer.cornerRadius = 2
        ad3ImageView.layer.cornerRadius = 2
        ad3DeleteButton.layer.cornerRadius = 2
        ad3ContainerView.layer.shadowRadius = 1
        ad3ContainerView.layer.shadowOffset = CGSizeZero
        ad3ContainerView.layer.shadowOpacity = 1
        
        userButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        friendButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
    }

}
