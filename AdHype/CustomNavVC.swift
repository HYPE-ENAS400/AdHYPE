//
//  CustomNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/27/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

enum VCTransitionDirection{
    case toRight
    case toLeft
}

class CustomNavVC: UIViewController{
    
    var transitionDirection: VCTransitionDirection?
    var containerView: UIView!
    
    private var activeViewController: UIViewController?{
        didSet{
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    func setActiveViewController(direction: VCTransitionDirection?, viewController: UIViewController){
        transitionDirection = direction
        activeViewController = viewController
    }
    
    func createGeneralViewControllerForID(storyboard: String, vcID: String)->UIViewController{
        let storyboard = UIStoryboard(name: storyboard, bundle:nil)
        return storyboard.instantiateViewControllerWithIdentifier(vcID)
    }
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?){
        if let inActiveVC = inactiveViewController{
            inActiveVC.willMoveToParentViewController(nil)
            
            if let transition = transitionDirection{
                let animation = CATransition()
                
                
                animation.type = kCATransitionPush
                
                switch transition{
                case .toRight:
                    animation.subtype = kCATransitionFromLeft
                case .toLeft:
                    animation.subtype = kCATransitionFromRight
                }
                
                containerView.layer.addAnimation(animation, forKey: "test")
                
            }
            
            inActiveVC.view.removeFromSuperview()
            inActiveVC.removeFromParentViewController()
        }
        
    }
    
    
    private func updateActiveViewController(){
        
        if let activeVC = activeViewController {
            
            activeVC.view.frame = containerView.bounds
            addChildViewController(activeVC)
            containerView.addSubview(activeVC.view)
            activeVC.didMoveToParentViewController(self)
        }
    }
}
