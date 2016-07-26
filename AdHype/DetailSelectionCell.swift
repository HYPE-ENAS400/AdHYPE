//
//  DetailSelectionCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/26/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class DetailSelectionCell: UITableViewCell{
    
    @IBOutlet weak var selectionIndicatorView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    var isViewAdjusted = false
    
    func initCell(isCellSelected: Bool){
        if !isViewAdjusted{
            selectionIndicatorView.layer.cornerRadius = (selectionIndicatorView.layer.bounds.size.width/2)
            selectionIndicatorView.layer.shadowRadius = 1
            selectionIndicatorView.layer.shadowOffset = CGSizeZero
            selectionIndicatorView.layer.shadowOpacity = 0.8
            isViewAdjusted = true
        }
        
        if isCellSelected{
            cellSelected()
        } else {
            cellDeselected()
        }
    }
    
    func cellSelected(){
        selectionIndicatorView.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1.0)
    }
    func cellDeselected(){
        selectionIndicatorView.backgroundColor = UIColor.whiteColor()
    }
    

    
}
