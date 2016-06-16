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

class HypeAd{
    private var adRef: FIRStorageReference
    private var adImage: UIImage?
    private var downloaded: Bool
    var title: String
    
    init(refURL: String, title: String){
        self.title = title
//        print("NEW ADD CREATED TITLED: \(title)\n")
        
        let storage = FIRStorage.storage()
        adRef = storage.referenceForURL(refURL)
        downloaded = false
    }
    
    func downloadImage(completion: (DownloadResult) -> Void){
        adRef.dataWithMaxSize(1 * 1024 * 1024){ (data, error) -> Void in
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
    
    func getImage() -> UIImage?{
        return adImage
    }
    
    
}