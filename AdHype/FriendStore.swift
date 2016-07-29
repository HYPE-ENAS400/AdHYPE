//
//  FriendStore.swift
//  AdHype
//
//  Created by Maxwell Payson on 7/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import Foundation
import Firebase


class FriendStore{
    var friendDict = ["#": [User](), "A": [User](),"B": [User](),"C": [User](), "D": [User](), "E": [User](), "F": [User](), "G": [User](), "H": [User](), "I": [User](), "J": [User](), "K": [User](), "L": [User](), "M": [User](), "N": [User](), "O": [User](), "P": [User](), "Q": [User](), "R": [User](),"S": [User](), "T": [User](), "U": [User](),"V": [User](),"W": [User](), "X": [User](), "Y": [User](), "Z": [User]()]
    
    var defaultFriendDictKeys: [String]
    var activeFriendDictKeys = [String]()
    
    var friendIDDict = [String: NSIndexPath]()
    
    private var friendRefDetachInfo: FIRDetachInfo?
    private var friendRef: FIRDatabaseReference?
    private weak var delegate: FriendStoreDelegate?
    private var userUID: String!
    
    private var hasFriends: Bool = false
    
    init () {
        defaultFriendDictKeys = Array(friendDict.keys)
        defaultFriendDictKeys.sortInPlace()
    }
    
    func downloadFriends(uid: String){
        userUID = uid
        friendRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(uid).child(Constants.USERFRIENDSNODE)
        
        let query = friendRef!.queryOrderedByValue()
        let handle = query.observeEventType(.ChildAdded, withBlock: {(snapshot)-> Void in
            if let nameDict = snapshot.value as? [String: String]{
                
                guard let un = nameDict[Constants.USERDISPLAYNAME] else {
                    print("COULD NOT GET USERNAME")
                    return
                }
                
                let fn = nameDict[Constants.USERFULLNAME]
                let newFriend = User(key: snapshot.key, userName: un, fullName: fn)
                
                let firstChar = un.uppercaseString[un.startIndex]
                let newFriendKey = "A"..."Z" ~= firstChar ? String(firstChar) : "#"
                
                guard self.defaultFriendDictKeys.contains(newFriendKey) else {
                    print("ERROR CONVERTING USERNAME TO INDEX KEY")
                    return
                }
                
                self.friendDict[newFriendKey]?.append(newFriend)
                let row = self.friendDict[newFriendKey]!.count - 1
                var newIndexPath: NSIndexPath
                if let section = self.activeFriendDictKeys.indexOf(newFriendKey){
                    newIndexPath = NSIndexPath(forRow: row, inSection: section)
                } else {
                    self.activeFriendDictKeys.append(newFriendKey)
                    let section = self.activeFriendDictKeys.count - 1
                    newIndexPath = NSIndexPath(forRow: row, inSection: section)
                }
                self.friendIDDict[newFriend.key] = newIndexPath
                self.delegate?.onNewFriendLoaded(newIndexPath)
                
                self.hasFriends = true
                
            } else {
                print("Error getting username")
            }
        })
        
        friendRefDetachInfo = FIRDetachInfo(ref: friendRef!, handle: handle)
    }
    
//    func downloadFriends(uid: String){
//        userUID = uid
//        for _ in 1..<30{
//            
//            let un = randomAlphaNumericString(5)
//            
//            let uuid = NSUUID().UUIDString
//            let newFriend = User(key: uuid, userName: un, fullName: "testName")
//            
//            let firstChar = un.uppercaseString[un.startIndex]
//            let newFriendKey = "A"..."Z" ~= firstChar ? String(firstChar) : "#"
//            
//            guard self.defaultFriendDictKeys.contains(newFriendKey) else {
//                print("ERROR CONVERTING USERNAME TO INDEX KEY")
//                return
//            }
//            
//            self.friendDict[newFriendKey]?.append(newFriend)
//            let row = self.friendDict[newFriendKey]!.count - 1
//            
//            self.friendIDSet.insert(newFriend.key)
//            
//            if let section = self.activeFriendDictKeys.indexOf(newFriendKey){
//                self.delegate?.onNewFriendLoaded(NSIndexPath(forRow: row, inSection: section))
//            } else {
//                self.activeFriendDictKeys.append(newFriendKey)
//                self.activeFriendDictKeys.sortInPlace()
//                let section = self.activeFriendDictKeys.count - 1
//                self.delegate?.onNewFriendLoaded(NSIndexPath(forRow: row, inSection: section))
//            }
//            
//            self.hasFriends = true
//
//        }
//
//    }
    
    func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    func getFriendAtIndexpath(indexPath: NSIndexPath) -> User?{
        let key = activeFriendDictKeys[indexPath.section]
        return friendDict[key]?[indexPath.row]
    }
    func deleteFriendAtIndexPath(indexPath: NSIndexPath){
        let key = activeFriendDictKeys[indexPath.section]
        guard let user = friendDict[key]?[indexPath.row] else {
            return
        }
        guard let frRef = friendRef else {
            return
        }
        
        frRef.child(user.key).removeValue()

        let newFriendsRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(user.key).child(Constants.USERFRIENDSNODE)
        newFriendsRef.child(userUID).removeValue()
        
        friendDict[key]!.removeAtIndex(indexPath.row)
    }

    func getNumberOfSections()->Int{
        return activeFriendDictKeys.count
    }
    func getNumberOfItemsInSection(section: Int)->Int{
        let key = activeFriendDictKeys[section]
        return friendDict[key]!.count
    }
    func getSectionTitles()->[String] {
        return defaultFriendDictKeys
    }
    func getSectionHeaderAtIndex(index: Int)->String{
        return activeFriendDictKeys[index]
    }
    func getSectionForSectionIndexTitle(title: String)->Int{
        var i = 0
        var c = activeFriendDictKeys[i]
        while c < title && i < activeFriendDictKeys.count{
            c = activeFriendDictKeys[i]
            i += 1
        }
        return i
    }
    
    func getHasFriends() -> Bool{
        return hasFriends
    }
    func getFriendIDSet() -> Set<String> {
        return Set(friendIDDict.keys)
    }
    
    func getFriendIndexPathForUID(userUID: String) -> NSIndexPath?{
        return friendIDDict[userUID]
    }
    
    func attatchNewFriendListener(listener: FriendStoreDelegate){
        delegate = listener
    }
    func detachNewFriendListener(){
        delegate = nil
    }

    
    deinit{
        if let detachInfo = friendRefDetachInfo{
            detachInfo.ref.removeObserverWithHandle(detachInfo.handle)
        }
    }
}

protocol FriendStoreDelegate: class {
    func onNewFriendLoaded(indexPath: NSIndexPath)
}