//
//  AdBrowserTableViewCell.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/26/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

class AdBrowserTableViewCell: UITableViewCell{
    
    @IBOutlet weak var adCollectionView: UICollectionView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        adCollectionView.delegate = dataSourceDelegate
        adCollectionView.dataSource = dataSourceDelegate
        adCollectionView.tag = row
        adCollectionView.setContentOffset(adCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        adCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            adCollectionView.contentOffset.x = newValue
        }
        
        get {
            return adCollectionView.contentOffset.x
        }
    }
    
}