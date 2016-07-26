//
//  HypeAd.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/15/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import Foundation
import Firebase

enum DownloadResult {
    case Success(HypeAd)
    case Failure
}

enum FetchCaptionResult{
    case Success((text: String, netVotes: Int, totalVotes: Int?, ref: String))
    case Failure
}

struct HypeAdMetaData{
    var name: String!
    var key: String!
    var isFromFriend: Bool = false
    var captionFromFriend: String?
    var url: String?
    var primaryTag: String!
    
    init(name: String, key: String, url: String, primaryTag: String, isFromFriend: Bool, captionFromFriend: String?){
        self.name = name
        self.key = key
        self.isFromFriend = isFromFriend
        self.captionFromFriend = captionFromFriend
        self.url = url
        self.primaryTag = primaryTag
    }
}

class HypeAd: Equatable{
    private var adStorRef: FIRStorageReference
    private var adPubCommentsRef: FIRDatabaseReference
    private var adImage: UIImage?
    private var downloaded: Bool
//    private var nodeKey: String?
    
//    private var adName: String
//    private var adIsFromFriend: Bool!
//    private var adCaptionFromFriend: String?
//    private var key: String!
    private var adMetaData: HypeAdMetaData
//    
    
    init(refURL: String, metaData: HypeAdMetaData){
        self.adMetaData = metaData
        
        adStorRef = FIRStorage.storage().referenceForURL(refURL)
        adPubCommentsRef = FIRDatabase.database().reference().child(Constants.PUBLICADCOMMENTS).child(self.adMetaData.key)
        downloaded = false
    }
    
    func downloadImage(completion: (DownloadResult) -> Void){
        
        guard !downloaded else{
            completion(.Success(self))
             return
        }
        //FOR SOME REASON THIS IS RETURNING A COMPLETION CALL BACK MORE THAN ONCE?!?!?
        adStorRef.dataWithMaxSize(1 * 1024 * 1024){ (data, error) -> Void in
            if (error != nil){
                self.downloaded = false
                print("Error Downloading: \(error?.localizedDescription)")
                completion(.Failure)
            } else {
                guard !self.downloaded else{
                    completion(.Failure)
                    return
                }
                self.adImage = UIImage(data: data!)!
                self.downloaded = true
                completion(.Success(self))

            }
        }
    }

    
    func fetchAdCaptions(complete: (result: FetchCaptionResult) -> Void, getDetachInfo: (detatchInfo: FIRDetachInfo) -> Void){
        let commentsRef = adPubCommentsRef.child(Constants.ADCOMMENTSNODE)
        let queryResults = commentsRef.queryOrderedByChild(Constants.ADCOMMENTVOTENODE)
        let queryHandle = queryResults.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let val = snapshot.value as? NSDictionary{
                if let caption = val.valueForKey(Constants.ADCOMMENTTEXTNODE) as? String{
                    if let count = val.valueForKey(Constants.ADCOMMENTVOTENODE) as? Int {
                        let totalVotes = val.valueForKey(Constants.ADCOMMENTTOTALVOTES) as? Int
                        let votes = 0 - count
                        complete(result: .Success(text: caption, netVotes: votes, totalVotes: totalVotes, ref: snapshot.key))
                    }
                }
            }
            complete(result: .Failure)
        })
        getDetachInfo(detatchInfo: FIRDetachInfo(ref: commentsRef, handle: queryHandle))
        
    }
    
    func getImage() -> UIImage?{
        return adImage
    }
    func getAdName() -> String{
        return adMetaData.name
    }
    func setAdName(name: String){
        adMetaData.name = name
    }
    func getAdNameWithExtension() -> String {
        return adMetaData.name
    }
    func getAdPubCommentsRef() -> FIRDatabaseReference{
        return adPubCommentsRef
    }
    func isFromFriend() -> Bool{
        return adMetaData.isFromFriend
    }
    func getCaption() -> String?{
        return adMetaData.captionFromFriend
    }
    func getKey() -> String{
        return adMetaData.key
    }
    func getURL() -> String?{
        return adMetaData.url
    }
    func getMetaData() -> HypeAdMetaData{
        return adMetaData
    }
    func getPrimaryTag() -> String{
        return adMetaData.primaryTag
    }
    func getMetaDataDict() -> [String: String]{
        var dict = [String: String]()
        dict = [Constants.ADNAMENODE: adMetaData.name, Constants.ADPRIMARYTAGNODE: adMetaData.primaryTag, Constants.ADISFROMFRIEND: String(adMetaData.isFromFriend)]
        if let caption = adMetaData.captionFromFriend{
            dict[Constants.ADCAPTIONNODE] = caption
        }
        if let url = adMetaData.url{
            dict[Constants.ADURLNODE] = url
        }
        return dict
    }

}

func == (lhs: HypeAd, rhs: HypeAd) -> Bool{
    return lhs.getKey() == rhs.getKey()
}