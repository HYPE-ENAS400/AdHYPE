//
//  FirstLoginVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/15/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class FirstLoginVC: UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delay(2){
            let offset = CGPoint(x: -160, y: 0)
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }
}
