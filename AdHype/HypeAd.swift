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
    case Success((text: String, netVotes: Int, ref: String))
    case Failure
}

struct HypeAdMetaData{
    var name: String!
    var key: String!
    var isFromFriend: Bool = false
    var captionFromFriend: String?
    
    init(name: String, key: String, isFromFriend: Bool, captionFromFriend: String?){
        self.name = name
        self.key = key
        self.isFromFriend = isFromFriend
        self.captionFromFriend = captionFromFriend
    }
}

class HypeAd: Equatable{
    private var adStorRef: FIRStorageReference
    private var adPubCommentsRef: FIRDatabaseReference
    private var adImage: UIImage?
    private var downloaded: Bool
//    private var nodeKey: String?
    
    private var adName: String
    private var adIsFromFriend: Bool!
    private var adCaptionFromFriend: String?
    private var key: String!
    
    
    init(refURL: String, metaData: HypeAdMetaData){
        
        self.adCaptionFromFriend = metaData.captionFromFriend
        self.adIsFromFriend = metaData.isFromFriend
        self.adName = metaData.name.stringByReplacingOccurrencesOfString(Constants.DEFAULTFILEEXTENSION, withString: "")
        self.key = metaData.key
        
        adStorRef = FIRStorage.storage().referenceForURL(refURL)
        adPubCommentsRef = FIRDatabase.database().reference().child(Constants.PUBLICADCOMMENTS).child(self.key)
        downloaded = false
    }
    
    func downloadImage(completion: (DownloadResult) -> Void){
        adStorRef.dataWithMaxSize(1 * 1024 * 1024){ (data, error) -> Void in
            if (error != nil){
                self.downloaded = false
                print("Error Downloading: \(error?.localizedDescription)")
                completion(.Failure)
            } else {
                self.downloaded = true
                self.adImage = UIImage(data: data!)!
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
                        let votes = 0 - count
                        complete(result: .Success(text: caption, netVotes: votes, ref: snapshot.key))
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
        return adName
    }
    func setAdName(name: String){
        adName = name
    }
    func getAdNameWithExtension() -> String {
        return adName + Constants.DEFAULTFILEEXTENSION
    }
    func getAdPubCommentsRef() -> FIRDatabaseReference{
        return adPubCommentsRef
    }
    func isFromFriend() -> Bool{
        return adIsFromFriend
    }
    func getCaption() -> String?{
        return adCaptionFromFriend
    }
    func getKey() -> String{
        return key
    }
    
}

func == (lhs: HypeAd, rhs: HypeAd) -> Bool{
    return lhs.getAdName() == rhs.getAdName()
}