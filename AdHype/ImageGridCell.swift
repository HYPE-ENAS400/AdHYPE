//
//  ImageGridCell.swift
//  Hype-2
//
//  Created by max payson on 4/18/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit

class ImageGridCell: UICollectionViewCell{
    
    @IBOutlet var view: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(nil)
    }
    
    func setRandomView(){
//        let newView = UIView(frame: self.frame)
        let colorArray = [UIColor.blueColor(), UIColor.redColor(), UIColor.greenColor()]
        let index = arc4random_uniform(3)
        self.backgroundColor = colorArray[Int(index)]
//        newView.backgroundColor = colorArray[Int(index)]
//        self.addSubview(newView)
    }
    
    func highlightCell(){
        view.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1.0)
    }
    
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()

//            let superFrame = self.frame
//            let newContainerView = UIView(frame: superFrame)
//            newContainerView.layer.cornerRadius = 20
            
            view.layer.cornerRadius = 5
            view.backgroundColor = UIColor.whiteColor()
            view.layer.shadowOpacity = 0.7
            view.layer.shadowOffset = CGSizeZero
            view.layer.shadowRadius = 2
            
            let childFrame = CGRectInset(view.bounds, 2, 2)
            let newChildView = UIImageView(frame: childFrame)
            newChildView.image = resizeImage(imageToDisplay, newScale: 0.4)
            newChildView.layer.masksToBounds = true
            newChildView.layer.cornerRadius = 5
            
            view.addSubview(newChildView)
            
//            self.addSubview(newContainerView)
            
        }
        else {
            spinner.startAnimating()
            
        }
    }
}
