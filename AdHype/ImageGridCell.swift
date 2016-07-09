//
//  ImageGridCell.swift
//  Hype-2
//
//  Created by max payson on 4/18/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit

class ImageGridCell: UICollectionViewCell{
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isDeleteActive = false
    weak var delegate: ImageGridCellDelegate!
    weak var cellAd: HypeAd!
    var isSaveButton: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(nil)
        cellAd = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(nil)
        cellAd = nil
    }
    
    func highlightCell(){
//        view.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1.0)
    }
    
    func downloadImageForAd(){
        cellAd.downloadImage({(result) -> Void in
            if case let .Success(ad) = result{                
                let image = ad.getImage()
                self.updateWithImage(image)
            }
        })
    }
    
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        }
        else {
            imageView.image = nil
            spinner.startAnimating()
        }
    }
    
    func changeDeleteButtonToSaveButton(){
        isSaveButton = true
        deleteButton.backgroundColor = UIColor.grayColor()
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleteButton.setTitle("SAVE!", forState: .Normal)
    }

    
    func showDeleteButton(){
        deleteButton.hidden = false
        isDeleteActive = true
        UIView.animateWithDuration(0.3, animations: {
            self.deleteButton.alpha = 0.8
        }
        )
        
    }
    func hideDeleteButton(){
        isDeleteActive = false
        UIView.animateWithDuration(0.3, animations: {
            self.deleteButton.alpha = 0
            }, completion: {finished in
                self.deleteButton.hidden = true
            }
        )
    }
    
    
    @IBAction func onPressedDeleteButton(sender: AnyObject) {
        if !isSaveButton{
            imageView.image = nil
            spinner.startAnimating()
        }
        deleteButton.hidden = true
        delegate.onPressedDelete(cellAd)
    }
    
}

protocol ImageGridCellDelegate: class {
    func onPressedDelete(ad: HypeAd)
}


