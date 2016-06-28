//
//  AdBrowserViewController.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/25/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

class AdBrowserViewController: UIViewController{
    
    @IBOutlet weak var adTableView: UITableView!
    
    var adLikedRef: FIRDatabaseReference!
    var interests = [String]()
    var adStore = [String: [HypeAd]]()
    
    var delegate: AdBrowserViewControllerDelegate!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adTableView.dataSource = self
        adTableView.delegate = self
        
        adLikedRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(getUserUID()).child(Constants.ADSLIKEDNODE)
        let query = adLikedRef.queryOrderedByChild(Constants.ADPRIMARYTAGNODE)
        query.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
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
                self.adTableView.reloadData()
            }
        })
        
    }
    
    
    func getUserUID() -> String{
        return (FIRAuth.auth()?.currentUser?.uid)!
    }
}

extension AdBrowserViewController: UIGestureRecognizerDelegate{
    
    func getCellForGestureRecognizer(gestureRecognizer: UIGestureRecognizer) -> ImageGridCell?{
        guard let tag = gestureRecognizer.view?.tag else {
            return nil
        }
        let tableCell = adTableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 0)) as! AdBrowserTableViewCell
        let p = gestureRecognizer.locationInView(tableCell.adCollectionView)
        if let indexPath: NSIndexPath = (tableCell.adCollectionView.indexPathForItemAtPoint(p)){
            if let cell = tableCell.adCollectionView.cellForItemAtIndexPath(indexPath) as? ImageGridCell{
                return cell
            }
        }
        return nil
        
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizerState.Began){
            return
        }
        
        if let cell = getCellForGestureRecognizer(gestureRecognizer){
            cell.showDeleteButton()
        }
    }
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        if let cell = getCellForGestureRecognizer(gestureRecognizer){
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
    func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer){
        if let cell = getCellForGestureRecognizer(gestureRecognizer){
            delegate.onAdFromBrowserDoubleClicked(cell.cellAd)
        }
    }
}

extension AdBrowserViewController: ImageGridCellDelegate{
    func onPressedDelete(ad: HypeAd){
        
        guard let interestIndex = interests.indexOf(ad.getPrimaryTag()) else {
            print("INTEREST FOR AD TO BE DELETED DOES NOT EXIST")
            return
        }
        
        guard let index = adStore[ad.getPrimaryTag()]?.indexOf(ad) else {
            print("ERROR ACCESSING AD NAME TO DELETE")
            return
        }
        
        //
        adLikedRef.child(Constants.ADSLIKEDNODE).child(ad.getKey()).removeValue()
        
        adStore[ad.getPrimaryTag()]?.removeAtIndex(index)
        
        let tableCell = adTableView.cellForRowAtIndexPath(NSIndexPath(forRow: interestIndex, inSection: 0)) as! AdBrowserTableViewCell
        
        tableCell.adCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
        
    }
}

extension AdBrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ads =  adStore[interests[collectionView.tag]]{
            return ads.count
        }
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ImageGridCell
        cell.delegate = self
        cell.cellAd = adStore[interests[collectionView.tag]]![indexPath.row]
        return cell
    }
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (cell as! ImageGridCell).downloadImageForAd()
    }
    
}

extension AdBrowserViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tvCell = cell as? AdBrowserTableViewCell else{
            return
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(AdBrowserViewController.handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        
        let dtgr = UITapGestureRecognizer(target: self, action: #selector(AdBrowserViewController.handleDoubleTap))
        dtgr.numberOfTapsRequired = 2
        dtgr.delegate = self
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(AdBrowserViewController.handleTap))
        tgr.numberOfTapsRequired = 1
        tgr.delegate = self
        tgr.requireGestureRecognizerToFail(dtgr)
        
        tvCell.adCollectionView.addGestureRecognizer(lpgr)
        tvCell.adCollectionView.addGestureRecognizer(tgr)
        tvCell.adCollectionView.addGestureRecognizer(dtgr)
        
        tvCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("adBrowserTVCell", forIndexPath: indexPath) as! AdBrowserTableViewCell
        cell.categoryLabel.text = interests[indexPath.row]
        return cell
    }
}

protocol AdBrowserViewControllerDelegate{
    func onAdFromBrowserDoubleClicked(ad: HypeAd)
}