//
//  HypeAd.swift
//  Hype-2
//
//  Created by max payson on 4/19/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

import UIKit
import Firebase

enum DownloadResult {
    case Downloaded
    case Error
    case AlreadyDownloaded
}

//class HypeAd: Equatable{
class HypeAd {

    let storage = FIRStorage.storage()
    
//    private var content: AWSContent!
//    private var isDownloaded: Bool = false
//    private var isFromFriend: Bool!
//    private var captions: [String] = []
//    private var fromFriendCaption: String?
//    
//    init(content: AWSContent, isFromFriend: Bool){
//        self.content = content
//        self.isFromFriend = isFromFriend
//        downloadCaptions()
////        captions = ["Test1", "Test2", "Test3"]
//    }
//    
//    func getFromFriendCaption() -> String?{
//        return fromFriendCaption
//    }
//    
//    func setFromFriendCaption(str: String){
//        fromFriendCaption = str
//    }
//    
//    func getCaptions() -> [String]{
//        return captions
//    }
//    
//    func getContent() -> AWSContent{
//        return content
//    }
//    func setContent(newContent: AWSContent){
//        content = newContent
//    }
//    
//    func getIsDownloaded() -> Bool{
//        return isDownloaded
//    }
//    
//    func getKey() -> String{
//        return content.key
//    }
//    
//    func setIsDownloaded(didDownload: Bool){
//        isDownloaded = didDownload
//    }
//    
//    func getImage() -> UIImage?{
//        return UIImage(data: content.cachedData)
//    }
//    
//    func getIsFromFriend() -> Bool{
//        return isFromFriend
//    }
//    func setIsFromFriend(fromFriend: Bool){
//        isFromFriend = fromFriend
//    }
//    
//    func downloadCaptions(){
//        print("key: \(content.key)")
//        let str = content.key.stringByReplacingOccurrencesOfString(".jpg", withString: "")
//        print("str: \(str)")
//        let fbRef = Firebase(url: "https://enas400hype.firebaseio.com/ADS").childByAppendingPath(str)
//        fbRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
//            let contentKey = snapshot.value as? String
//            if let key = contentKey{
//                self.captions.append(key)
//            }
//        })
//        
//    }
//    
//    func  downloadContent(completion: (result: DownloadResult) -> Void){
//        if !content.cached{
//            content.downloadWithDownloadType( .Always, pinOnCompletion: false, progressBlock: {(content: AWSContent?, progress: NSProgress?) -> Void in
//                // Handle progress feedback
//                }, completionHandler: {(content: AWSContent?, data: NSData?, error: NSError?) -> Void in
//                    if let error = error {
//                        print("Error with key: \(content?.key)")
//                        print("Error domain: \(error.domain)\n")
////                        print("Failed to download a content from a server.) + \(error)")
//                        completion(result: .Error)
//                    } else {
//                        completion(result: .Downloaded)
//                        self.isDownloaded = true
//                    }
//                    
//            })
//        } else {
//            completion(result: .AlreadyDownloaded)
//        }
//    }
//    
//    func deleteDownload(){
//        content.removeLocal()
//        isDownloaded = false
//    }
    
}

//func == (lhs: HypeAd, rhs: HypeAd) -> Bool {
//    if lhs.getContent().key == rhs.getContent().key {
//        lhs.isFromFriend = true
//        rhs.isFromFriend = true
//        return true
//    } else {
//        return false
//    }
//}
