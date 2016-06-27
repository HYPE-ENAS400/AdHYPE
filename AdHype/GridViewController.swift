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

class GridViewController: UICollectionViewController{
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    var userRef: FIRDatabaseReference!
    
    var adNames = [String]()
    var adKeys = [String]()
    
    var delegate: GridViewControllerDelegate!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        collectionView!.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        initGridView((FIRAuth.auth()?.currentUser?.uid)!)
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
    }
    
    func initGridView(userUID: String){
        userRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(userUID)
        
        let adQueueRef = userRef.child(Constants.ADSLIKEDNODE)
        adQueueRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dict = snapshot.value as? [String: String]{
                self.adNames.append(dict[Constants.ADNAMENODE]!)
                self.adKeys.append(snapshot.key)
                self.collectionView?.reloadData()
            }
            
        })
    }
    
    func clearGridView(){
        adNames = [String]()
        adKeys = [String]()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adNames.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ImageGridCell
        cell.delegate = self
        let adTitle = adNames[indexPath.row]
        let adKey = adKeys[indexPath.row]
        let newAdMetaData = HypeAdMetaData(name: adTitle, key: adKey, url: "http://wwww.githyped.com", primaryTag: "hype",isFromFriend: false, captionFromFriend: nil)
        
        cell.cellAd = HypeAd(refURL: Constants.BASESTORAGEURL + adTitle, metaData: newAdMetaData)
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! ImageGridCell).downloadImageForAd()
    }
    
    func getCellFromLocation(location: CGPoint) -> ImageGridCell {
        let selectedIndexPath: NSIndexPath = self.collectionView!.indexPathForItemAtPoint(location)!
        let cell = self.collectionView!.cellForItemAtIndexPath(selectedIndexPath) as! ImageGridCell
        return cell
    }
    
    @IBAction func didDoubleTapCollectionView(gesture: UITapGestureRecognizer){
        let pointInCollectionView: CGPoint = gesture.locationInView(self.collectionView)
        let selectedIndexPath: NSIndexPath = self.collectionView!.indexPathForItemAtPoint(pointInCollectionView)!
        let cell = collectionView?.cellForItemAtIndexPath(selectedIndexPath) as! ImageGridCell
        delegate.onAdDoubleClicked(cell.cellAd)
    }
    
    @IBAction func didLongTapCollectionView(gesture: UILongPressGestureRecognizer){
        let pointInCollectionView: CGPoint = gesture.locationInView(self.collectionView)
        let cell = getCellFromLocation(pointInCollectionView)
        cell.showDeleteButton()
    }
    
    @IBAction func didTapCollectionView(gesture: UITapGestureRecognizer){
        let pointInCollectionView: CGPoint = gesture.locationInView(self.collectionView)
        let cell = getCellFromLocation(pointInCollectionView)
        if cell.isDeleteActive {
            cell.hideDeleteButton()
        }
    }

}

extension GridViewController: ImageGridCellDelegate{
    func onPressedDelete(ad: HypeAd){
        
        guard let adNameIndex = adNames.indexOf(ad.getAdNameWithExtension()) else {
            print("ERROR ACCESSING AD NAME TO DELETE")
            return
        }
//
        userRef.child(Constants.ADSLIKEDNODE).child(adKeys[adNameIndex]).removeValue()
        
        adNames.removeAtIndex(adNameIndex)
        adKeys.removeAtIndex(adNameIndex)
        
        collectionView!.deleteItemsAtIndexPaths([NSIndexPath(forRow:adNameIndex, inSection: 0)])
        
    }
}

protocol GridViewControllerDelegate{
    func onAdDoubleClicked(ad: HypeAd)
}

