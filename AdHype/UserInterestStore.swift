//
//  UserInterestStore.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import Foundation
import Firebase

class UserInterestStore {
    let interestCategories = ["Discovery", "Animals", "Apparel", "Apps & Games", "Babies & Kids", "Cars", "Celebrities", "Entertainment", "Fitness & Health", "Food & Cooking", "Lifestyle & Home", "Nerd", "News", "Outdoors", "Sports", "Tech", "Travel"]
    var interestDict = [String: Bool]()
    var interestRef: FIRDatabaseReference?
    
    init() {
        
        for key in interestCategories{
            interestDict[key] = false
        }
       
    }
    
    func getUserInterestCount() -> Int{
        return interestCategories.count
    }
    
    func getUserInterestEntryAtIndex(index: Int) -> (category: String, isInterested: Bool){
        let category = interestCategories[index]
        let isInterested = interestDict[category]!
        return (category, isInterested)
    }
    
    func setIsInterestedInCategory(category: String, isInterested: Bool){
        interestDict[category] = isInterested
        interestRef?.child(category).setValue(isInterested)
    }
    
    func downloadUserInterests(uid: String, callback: (success: Bool) -> Void){
        interestRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(uid).child(Constants.USERINTERESTSNODE)
        interestRef!.observeSingleEventOfType(.Value, withBlock: {(snapshot)->Void in
            
            if let ar = snapshot.value as? [String : Bool]{
                for (category, liked) in ar{
                    self.interestDict[category] = liked
                }
                callback(success: true)
            } else{
                callback(success: false)
                print("COULD NOT GET USER INTERESTS")
            }
            
        })
    }
    
    func isUserInterestedInAd(adDict: [String: String])->Bool{
        //switch so iterates through dictionary, write script so dict only has key if ad fits category
        for key in interestCategories{
            guard let isUserInterest = interestDict[key] else{
                continue
            }
            guard let isInterestedString = adDict[key] else{
                continue
            }
            if isInterestedString != "" && isUserInterest{
                return true
            }
        }
        return false
    }
    
    func clearUserInterests(){
        interestDict.removeAll()
    }
    
}