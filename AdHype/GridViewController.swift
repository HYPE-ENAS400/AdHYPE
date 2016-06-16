//
//  GridViewController.swift
//  Hype-2
//
//  Created by max payson on 4/18/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import SafariServices
import Firebase

//class GridViewController: UICollectionViewController, HypeAdStoreDelegate{
class GridViewController: UICollectionViewController{
    
    var ads = [HypeAd]()
    var adNames = [String]()
    var userRef: FIRDatabaseReference!
    var nextAdIndex = 0
    
   
    
//    var collectionViewLayout: CustomImageFlowLayout!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        collectionView!.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
//        collectionViewLayout = CustomImageFlowLayout()
//        collectionView.collectionViewLayout = collectionViewLayout
        self.collectionView?.reloadData()
    }
    
    @IBAction func didDoubleTapCollectionView(gesture: UITapGestureRecognizer){
        let pointInCollectionView: CGPoint = gesture.locationInView(self.collectionView)
        let selectedIndexPath: NSIndexPath = self.collectionView!.indexPathForItemAtPoint(pointInCollectionView)!
        print("DOUBLE TAPPED CELL: \(adNames[selectedIndexPath.row])")
        //TODO open up info about the ad
//        print("DOUBLE TAPPED CELL: \(self.collectionView!.cellForItemAtIndexPath(selectedIndexPath))")
    }
    
    func initGridView(userUID: String){
        userRef = FIRDatabase.database().reference().child("users").child(userUID)
        
        let adQueueRef = userRef.child("cardsLiked")
        adQueueRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            self.adNames.append(snapshot.value as! String)
//            self.appendAd(self.adNames.count - 1)
            self.collectionView?.reloadData()
        })
    }
    
    func appendAd(index: Int){

        let newAd = HypeAd(refURL: Constants.BASESTORAGEURL + "\(adNames[index])", title: adNames[index])
        newAd.downloadImage({(result) -> Void in
            if case let .Success(ad) = result{
                self.ads.append(ad)
                self.newCardImageLoaded(self.ads.count - 1, cellIndex: index)
            }
        })
        nextAdIndex += 1

    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        //todo add url
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adNames.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ImageGridCell
        return cell
        
        
//        let index = indexPath.row
//        
//        //TODO SOMETIMES THIS YIELDS BAD ACCESS
//        let image = ads[index].getImage()
//        cell.updateWithImage(image)
//        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        appendAd(indexPath.row)
    }
    
    func newCardImageLoaded(cardIndex: Int, cellIndex: Int){
        let photoIndexPath = NSIndexPath(forRow: cellIndex, inSection: 0)
        if let cell = self.collectionView?.cellForItemAtIndexPath(photoIndexPath) as? ImageGridCell {
            let image = ads[cardIndex].getImage()
            cell.updateWithImage(image)
        }
    }
    
    
    
}
