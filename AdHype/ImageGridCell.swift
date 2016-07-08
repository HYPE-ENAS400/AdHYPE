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
    var cellAd: HypeAd!
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

//            view.layer.shadowOpacity = 1
  //          view.layer.shadowOffset = CGSizeZero
    //        view.layer.shadowRadius = 2
            
            imageView.image = resizeImage(imageToDisplay, newScale: 0.4)
//            imageView.layer.masksToBounds = true
//            imageView.layer.cornerRadius = 3
            
//            let newScale: CGFloat = 0.4
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                let newWidth = imageToDisplay.size.width * newScale
//                let newHeight = imageToDisplay.size.width * newScale
//                UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
//                imageToDisplay.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
//                let newImage = UIGraphicsGetImageFromCurrentImageContext()
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.imageView.image = newImage
//                    self.imageView.layer.masksToBounds = true
//                    self.imageView.layer.cornerRadius = 3
//                    self.spinner.stopAnimating()
//                })
//            })

            
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


