//
//  customSegue.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class customSegue: UIStoryboardSegue{
    override func perform() {
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        secondVCView.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        secondVCView.frame = CGRectMake(screenWidth, 0.0, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, -screenWidth, 0.0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, -screenWidth, 0.0)
            
        }) { (Finished) -> Void in
            
            let destVC = self.destinationViewController as! FriendsTableViewController
            
            self.sourceViewController.presentViewController(destVC, animated: false, completion: nil)
        }
        
        
    }
}
