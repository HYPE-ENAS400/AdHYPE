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
    
    weak var delegate: GridViewControllerDelegate!
    weak var messageDelegate: DisplayMessageDelegate!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
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
                self.spinner.stopAnimating()
                if let interestIndex = self.interests.indexOf(primarytag){
                    self.adStore[primarytag]?.append(HypeAd(refURL: Constants.BASESTORAGEURL + name, metaData: newAdMetaData))
                    
                    guard self.collectionView?.numberOfItemsInSection(interestIndex) != self.adStore[primarytag]?.count else {
                    //This should never happen, since the new section category is appended before it is added to the collection view, yet it happens every time there are no existing sections and the grid view is brought back in to scope... makes no sense
                        self.collectionView?.reloadData()
                        return
                    }

                    let indexPath = NSIndexPath(forItem: (self.adStore[primarytag]?.count)! - 1, inSection: interestIndex)
                    self.collectionView?.insertItemsAtIndexPaths([indexPath])
                }
                else {

                    self.interests.append(primarytag)
                    self.adStore[primarytag] = [HypeAd(refURL: Constants.BASESTORAGEURL + name, metaData: newAdMetaData)]
                    self.interests.sortInPlace()
                    
                    guard self.collectionView?.numberOfSections() != self.interests.count else {
                        //This should never happen, since the new section category is appended before it is added to the collection view, yet it happens every time there are no existing sections and the grid view is brought back in to scope... makes no sense
                        self.collectionView?.reloadData()
                        return
                    }
                    let newIndex = self.interests.indexOf(primarytag)!
                    self.collectionView?.insertSections(NSIndexSet(index: newIndex))

                }
                
            }
        })
        detachInfo = FIRDetachInfo(ref: adsLikedRef, handle: handle)
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
//        print("NUMBER OF SECTIONS: \(interests.count)")
        return interests.count
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        

        let suppView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "gridSectionCell", forIndexPath: indexPath) as! GridSectionCell
        suppView.sectionLabel.text = interests[indexPath.section]

        
        return suppView
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("NUMBER OF ITEMS: \(adStore[interests[section]]!.count) IN SECTION: \(section)")
        return adStore[interests[section]]!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ImageGridCell
        cell.delegate = self
        let cellAd = adStore[interests[indexPath.section]]![indexPath.row]
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
        let pointInCollectionView: CGPoint = gesture.locationInView(collectionView)
        if let selectedIndexPath: NSIndexPath = collectionView?.indexPathForItemAtPoint(pointInCollectionView){
            if let cell = collectionView?.cellForItemAtIndexPath(selectedIndexPath) as? ImageGridCell{
                return cell
            }
        }
        return nil
    }
    
    @IBAction func didDoubleTapCollectionView(gesture: UITapGestureRecognizer){
        if let cell = getCellFromGesture(gesture){
            guard let urlString = cell.cellAd.getURL() else {
                return
            }
            if let url = NSURL(string: urlString){

                let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
                presentViewController(vc, animated: true, completion: nil)
                
            }
            guard let userID = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            let timeStamp = String(Int(NSDate().timeIntervalSince1970))
            let aggregateCardsRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(userID).child(Constants.AGGREGATECARDSCLICKED).child(cell.cellAd.getKey())
            if isFriendGrid{
                aggregateCardsRef.child(timeStamp).setValue("fromFriend")
            } else{
                aggregateCardsRef.child(timeStamp).setValue("fromGrid")
            }
            
            
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
                // decided wanted this action when single tapped
                delegate.onAdFromGridDoubleClicked(cell.cellAd)
            }
        }
    }
    
    //Necessary to have separate function, otherwise deinit isn't called
    //Parent VC's job to call
    func detachGridViewListeners(){
        if let info = detachInfo{
            info.ref.removeObserverWithHandle(info.handle)
        }
        
    }
    deinit {
        print("FUCKING GRID VIEW DEINIT")
    }

}

extension GridViewController: ImageGridCellDelegate{
    func onPressedDelete(ad: HypeAd){
        let pTag = ad.getPrimaryTag()
        guard let interestIndex = interests.indexOf(pTag) else {
            print("INTEREST FOR AD TO BE DELETED DOES NOT EXIST")
            return
        }
        
        guard let index = adStore[pTag]?.indexOf(ad) else {
            print("ERROR ACCESSING AD NAME TO DELETE")
            return
        }
        
        if !isFriendGrid{
            adsLikedRef.child(ad.getKey()).removeValue()
            

            adStore[pTag]?.removeAtIndex(index)
            
            if adStore[pTag]?.count == 0{
                interests.removeAtIndex(interestIndex)
                collectionView?.deleteSections(NSIndexSet(index: interestIndex))
            } else{
                collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: interestIndex)])
            }
            
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
                let timeStamp = String(Int(NSDate().timeIntervalSince1970))
                let aggregateCardsRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(userID).child(Constants.AGGREGATECARDSSAVED).child(ad.getKey())
                aggregateCardsRef.child(timeStamp).setValue(true)
            })
        }
        
    }

}

protocol GridViewControllerDelegate: class{
    func onAdFromGridDoubleClicked(ad: HypeAd)
}

