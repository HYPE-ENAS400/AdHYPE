//
//  CustomImageFlowLayout.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/15/16.
//  Copyright © 2016 Enas400. All rights reserved.
//
// Adapted from: http://zappdesigntemplates.com/create-3-column-grid-view-with-uicollectionview/

import Foundation
import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout{
    
    var numberOfColumns: CGFloat = 3.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }

    
    override init(){
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1.0
        minimumLineSpacing = 1.0
        scrollDirection = .Vertical
    }
    
    override var itemSize: CGSize{
        set {
            
        }
        get {
            
            let itemWidth = (contentWidth - (numberOfColumns - 1)) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }
    
}