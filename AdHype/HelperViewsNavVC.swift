//
//  HelperViewsNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/27/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class HelperViewsNavVC: CustomNavVC{
    
    @IBOutlet weak var helperNavVCContainerView: UIView!{
        didSet{
            super.containerView = helperNavVCContainerView
        }
    }
    
    var pageVCIDs = ["rightSwipePageVC", "leftSwipePageVC"]
    
    var curVCIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVC = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs.first!)
        setSwipeGestureRecognizersOnView(firstVC.view)
        setActiveViewController(nil, viewController: firstVC)
        
    }
    func setSwipeGestureRecognizersOnView(view: UIView){
        let rsgr = UISwipeGestureRecognizer(target: self, action: #selector(HelperViewsNavVC.handleSwipeRight))
        rsgr.direction = .Right
        rsgr.delegate = self
        view.addGestureRecognizer(rsgr)
        
        let lsgr = UISwipeGestureRecognizer(target: self, action: #selector(HelperViewsNavVC.handleSwipeLeft))
        lsgr.direction = .Left
        lsgr.delegate = self
        view.addGestureRecognizer(lsgr)
    }
}

extension HelperViewsNavVC: UIGestureRecognizerDelegate{
    func handleSwipeRight(gestureRecognizer: UISwipeGestureRecognizer){
        let nextIndex = curVCIndex - 1
        guard nextIndex >= 0 else {
            return
        }
        let vc = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs[nextIndex])
        setSwipeGestureRecognizersOnView(vc.view)
        setActiveViewController(.toRight, viewController: vc)
        curVCIndex = nextIndex
    }

    func handleSwipeLeft(gestureRecognizer: UISwipeGestureRecognizer){
        let nextIndex = curVCIndex + 1
        guard nextIndex < pageVCIDs.count else {
            return
        }
        
        let vc = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs[nextIndex])
        setSwipeGestureRecognizersOnView(vc.view)
        setActiveViewController(.toLeft, viewController: vc)
        curVCIndex = nextIndex
    }
}