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

class HypeAd: Equatable{
    private var adStorRef: FIRStorageReference
    private var adDatRef: FIRDatabaseReference
    private var adImage: UIImage?
    private var downloaded: Bool
    private var nodeKey: String?
    private var adName: String
    
//    private var adCaptions = [(text: String, netVotes: Int, ref: String)]()
    
    init(refURL: String, name: String){
        self.adName = name.stringByReplacingOccurrencesOfString(Constants.DEFAULTFILEEXTENSION, withString: "")
//        print("NEW ADD CREATED TITLED: \(title)\n")
        adStorRef = FIRStorage.storage().referenceForURL(refURL)
        adDatRef = FIRDatabase.database().reference().child(Constants.ADSNODE).child(self.adName)
        downloaded = false
    }
    
    init(refURL: String, name: String, nodeKey: String){
        self.adName = name.stringByReplacingOccurrencesOfString(Constants.DEFAULTFILEEXTENSION, withString: "")
        self.nodeKey = nodeKey
        let storage = FIRStorage.storage()
        adStorRef = storage.referenceForURL(refURL)
        adDatRef = FIRDatabase.database().reference().child(Constants.ADSNODE).child(self.adName)
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
    
    func fetchAdCaptions(complete: (result: FetchCaptionResult) -> Void){
        let commentsRef = adDatRef.child(Constants.ADCOMMENTSNODE)
        let queryResults = commentsRef.queryOrderedByChild(Constants.ADCOMMENTVOTENODE)
        queryResults.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let val = snapshot.value as? NSDictionary{
                if let caption = val.valueForKey(Constants.ADCOMMENTTEXTNODE) as? String{
                    if let count = val.valueForKey(Constants.ADCOMMENTVOTENODE) as? Int {
                        complete(result: .Success(text: caption, netVotes: count, ref: snapshot.key))
                    }
                }
            }
            complete(result: .Failure)
        })
        
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
    func getAdDatRef() -> FIRDatabaseReference{
        return adDatRef
    }
    
}

func == (lhs: HypeAd, rhs: HypeAd) -> Bool{
    return lhs.getAdName() == rhs.getAdName()
}