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

class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    var adsLikedRef: FIRDatabaseReference!
    var interests = [String]()
    var adStore = [String: [HypeAd]]()
    var userID: String!
    var isFriendGrid: Bool = false
    var detachInfo: FIRDetachInfo?
    
    var delegate: GridViewControllerDelegate!
    var messageDelegate: DisplayMessageDelegate!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        collectionView!.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        initGridView(userID)
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
    }
    
    func initGridView(id: String){
        adsLikedRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(id).child(Constants.ADSLIKEDNODE)
        let query = adsLikedRef.queryOrderedByChild(Constants.ADPRIMARYTAGNODE)
        let handle = query.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: String]{
                let name = dict[Constants.ADNAMENODE]!
                let url = dict[Constants.ADURLNODE]!
                let key = snapshot.key
                let primarytag = dict[Constants.ADPRIMARYTAGNODE]!
                let newAdMetaData = HypeAdMetaData(name: name, key: key, url: url, primaryTag: primarytag, isFromFriend: false, captionFromFriend: nil)
                
                if self.interests.contains(primarytag){
                    self.adStore[primarytag]?.append(HypeAd(refURL: Constants.BASESTORAGEURL + name, metaData: newAdMetaData))
                    print("added \(name) to category \(primarytag)")
                }
                else{
                    self.interests.append(primarytag)
                    self.adStore[primarytag] = [HypeAd(refURL: Constants.BASESTORAGEURL + name, metaData: newAdMetaData)]
                    print("created category \(primarytag) to add \(name)")
                }
                self.collectionView?.reloadData()
            }
        })
        detachInfo = FIRDetachInfo(ref: adsLikedRef, handle: handle)
    }
    
    func clearGridView(){
        interests = [String]()
        adStore = [String: [HypeAd]]()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let numberOfColumns: CGFloat = 3.0
        let insets = collectionView.contentInset
        let w = CGRectGetWidth(collectionView.bounds) - (insets.right + insets.left)
        let itemWidth = (w - (numberOfColumns - 1)) / numberOfColumns
        return CGSizeMake(itemWidth, itemWidth*(6.0/5.0))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 40)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return interests.count
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        

        let suppView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "gridSectionCell", forIndexPath: indexPath) as! GridSectionCell
        suppView.sectionLabel.text = interests[indexPath.section]

        
        return suppView
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adStore[interests[section]]!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ImageGridCell
        cell.delegate = self
        let cellAd = adStore[interests[indexPath.section]]![indexPath.row]
        print("ADDING CELL FOR AD: \(cellAd.getAdName())")
        if isFriendGrid{
            cell.changeDeleteButtonToSaveButton()
        }
        cell.cellAd = cellAd
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! ImageGridCell).downloadImageForAd()
    }
    
    private func getCellFromGesture(gesture: UIGestureRecognizer) -> ImageGridCell? {
        let pointInCollectionView: CGPoint = gesture.locationInView(self.collectionView)
        if let selectedIndexPath: NSIndexPath = self.collectionView?.indexPathForItemAtPoint(pointInCollectionView){
            if let cell = self.collectionView!.cellForItemAtIndexPath(selectedIndexPath) as? ImageGridCell{
                return cell
            }
        }
        return nil
    }
    
    @IBAction func didDoubleTapCollectionView(gesture: UITapGestureRecognizer){
        if let cell = getCellFromGesture(gesture){
            delegate.onAdFromGridDoubleClicked(cell.cellAd)
        }
        
    }
    
    @IBAction func didLongTapCollectionView(gesture: UILongPressGestureRecognizer){
        if let cell = getCellFromGesture(gesture){
            cell.showDeleteButton()
        }
    }
    
    @IBAction func didTapCollectionView(gesture: UITapGestureRecognizer){
        if let cell = getCellFromGesture(gesture){
            if cell.isDeleteActive{
                cell.hideDeleteButton()
            } else{
                if let url = NSURL(string: cell.cellAd.getURL()){
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
                        presentViewController(vc, animated: true, completion: nil)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if isFriendGrid {
            if let info = detachInfo{
                info.ref.removeObserverWithHandle(info.handle)
            }
        }
    }

}

extension GridViewController: ImageGridCellDelegate{
    func onPressedDelete(ad: HypeAd){
        
        guard let interestIndex = interests.indexOf(ad.getPrimaryTag()) else {
            print("INTEREST FOR AD TO BE DELETED DOES NOT EXIST")
            return
        }
        
        guard let index = adStore[ad.getPrimaryTag()]?.indexOf(ad) else {
            print("ERROR ACCESSING AD NAME TO DELETE")
            return
        }
        
        if !isFriendGrid{
            adsLikedRef.child(ad.getKey()).removeValue()
            
            adStore[ad.getPrimaryTag()]?.removeAtIndex(index)
            
            collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: interestIndex)])
        } else{
            guard let userID = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            let userLikedAdsRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(userID).child(Constants.ADSLIKEDNODE)
            userLikedAdsRef.child(ad.getKey()).setValue(ad.getMetaDataDict(), withCompletionBlock: {(error, ref) -> Void in
                if let er = error{
                    print("ERROR: COULD NOT SAVE FRIEND AD: \(er.localizedDescription)")
                    return
                }
                self.messageDelegate.displayMessage("Ad saved to your board!", duration: 1.5)
            })
        }
        
    }
}

protocol GridViewControllerDelegate{
    func onAdFromGridDoubleClicked(ad: HypeAd)
}

