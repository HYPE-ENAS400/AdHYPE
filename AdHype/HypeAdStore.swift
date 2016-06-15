//
//  HypeAdStore.swift
//  Hype-2
//
//  Created by max payson on 4/19/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit

class HypeAdStore {
//    private var adArray: [HypeAd]!
//    private var prefix: String!
//    private var marker: String?
//    private var didLoadAllContents: Bool!
//    private var delegate: HypeAdStoreDelegate
//    
//    private var maxIndexLoaded = -1{
//        didSet{
//            if maxIndexLoaded != -1 && oldValue > maxIndexLoaded {
//                maxIndexLoaded = oldValue
//            }
//        }
//    }
//    
//    private var manager: AWSContentManager!
//    
//    init(delegate: HypeAdStoreDelegate, awsManager:AWSContentManager){
//        self.delegate = delegate
//        self.manager = awsManager
//        print(manager.maxCacheSize)
//        adArray = [HypeAd]()
//    }
//    
//    func initializeCardsFromAWS(){
//        didLoadAllContents = false
//        loadMoreContents()
//    }
//    
//    func getNumAvailCards() -> Int{
//        if let ads = adArray {
//            return ads.count
//        } else {
//            return 0
//        }
//    }
//    
//    func getContentAtIndex(index: Int) -> HypeAd?{
//        return adArray[index]
//    }
//    
//    func getContentImageAtCardIndex(index: Int) -> UIImage?{
//        return adArray[index].getImage()
////        return UIImage(data: adArray[index].getContent().cachedData)
//    }
//    
//    func getIsFromFriendAtCardIndex(index: Int) -> Bool{
//        return adArray[index].getIsFromFriend()
//    }
//    
//    func pushImageKeyAtCardIndex(index: Int, fbRef: Firebase){
//        fbRef.childByAutoId().setValue(adArray[index].getContent().key)
//    }
//    
//    func getContentKeyAtIndex(index: Int) -> String?{
//        return adArray[index].getContent().key
//    }
//    
//    func addContentByKey(key: String, shouldDownload: Bool) -> Int{
//        return addContentToAdArray(manager.contentWithKey(key), isFromFriend: true, shouldDownload: shouldDownload)
//    }
//    
//    func setFromFriendCaptionByKey(index: Int, caption: String){
//        adArray[index].setFromFriendCaption(caption)
//    }
//    
//    func getFromFriendCaptionByKey(index: Int) -> String?{
//        return adArray[index].getFromFriendCaption()
//    }
//    
//    private func addContentToAdArray(content: AWSContent, isFromFriend: Bool, shouldDownload: Bool) -> Int{
//        
//        let hypeAd = HypeAd(content: content, isFromFriend: isFromFriend)
//        
//        if !adArray.contains(hypeAd) {
//            if (adArray?.append(hypeAd) == nil){
//                adArray = [hypeAd]
//            }
//            let adIndex = adArray.count - 1
//            if(shouldDownload){
//                hypeAd.downloadContent({(result: DownloadResult) -> Void in
//                    if result != .Error {
//                        self.delegate.newCardImageLoaded(adIndex)
//                        self.maxIndexLoaded = adIndex
//                    }
//                })
//            }
//            return adIndex
//        }
//        return adArray.indexOf(hypeAd)!
//    }
//    
//    func downloadContentAtCardIndex(index: Int){
//        adArray[index].downloadContent({(result: DownloadResult)-> Void in
//            self.delegate.newCardImageLoaded(index)
//            self.maxIndexLoaded = index
//        })
//    }
//    
//    func resetCardsToReload(){
//        maxIndexLoaded = -1
//    }
//    
//    func downloadMoreCards(numberNewCards: Int){
//        let minIndex = maxIndexLoaded + 1
//        let maxIndex = min(minIndex + numberNewCards, getNumAvailCards())
//        for i in minIndex..<maxIndex{
//            downloadContentAtCardIndex(i)
//        }
//        
//    }
//    
//    private func loadMoreContents(){
//        manager.listAvailableContentsWithPrefix(prefix, marker: marker, completionHandler: {[weak self](contents: [AWSContent]?, nextMarker: String?, error: NSError?) -> Void in
//            guard let strongSelf = self else { return }
//            if let error = error {
//                print("Failed to load the list of contents. \(error)")
//            }
//            if let contents = contents where contents.count > 0 {
//                print("total number of cards: \(contents.count)")
//                for c in contents{
//                    strongSelf.addContentToAdArray(c, isFromFriend: false, shouldDownload: true)
//                }
//                
//                if let nextMarker = nextMarker where !nextMarker.isEmpty{
//                    strongSelf.didLoadAllContents = false
//                } else {
//                    strongSelf.didLoadAllContents = true
//                }
//                
//            }
//            })
//    }
//    
//    func clearCacheAtCardIndex(index: Int){
//        adArray[index].deleteDownload()
//    }
    
}

protocol HypeAdStoreDelegate{
    func newCardImageLoaded(cardIndex: Int)
}
