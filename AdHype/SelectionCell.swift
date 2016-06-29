//
//  SelectionCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/23/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell{
    
    @IBOutlet weak var selectionIndicatorView: UIView!
    @IBOutlet weak var userCell: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func initCell(isCellSelected: Bool){
        selectionIndicatorView.layer.cornerRadius = (selectionIndicatorView.layer.bounds.size.width/2)
        selectionIndicatorView.layer.shadowRadius = 2
        selectionIndicatorView.layer.shadowOffset = CGSizeZero
        selectionIndicatorView.layer.shadowOpacity = 0.8
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
