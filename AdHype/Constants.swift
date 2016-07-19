//
//  Constants.swift
//  Hype-2
//
//  Created by max payson on 4/12/16.
//  Copyright © 2016 Amazon. All rights reserved.
//
import Foundation

struct Constants {
    static let USERKEY = "HYPELOGINEMAIL"
    static let PASSKEY = "HYPELOGINPASSWORD"
    static let ADSPERCONTENT = 8
    static let INVADSPERCONTENT = 0.25
    static let BASESTORAGEURL = "gs://project-8277179768550916139.appspot.com/"
    
    static let MAXNUMADS = 6
    static let MAXNUMADQUEUE = 12
    
    
    static let HASSEENMAINKEY = "hasSeenMainViewKey"
    static let HASSEENGRIDKEY = "hasSeenGridViewKey"
    static let HASSEENSOCIALKEY = "hasSeenSocialViewKey"
    
    static let RECEIVEDADQUEUENODE = "ReceivedAdsFromFriends"
    static let ADSLIKEDNODE = "cardsLiked"
    static let ADVIEWEDCOUNTNODE = "adViewedCount"
    static let CONTENTCOUNTNODE = "contentCount"
    static let AGGREGATECARDSLIKED = "aggregateCardsLiked"
    static let AGGREGATECARDSDISLIKED = "aggregateCardsDisliked"
    static let AGGREGATECARDSSENT = "aggregateCardsSent"
    static let AGGREGATEUSERCAPTIONS = "aggregateUserCaptions"
    static let AGGREGATECARDSCLICKED = "aggregateCardsClicked"
    static let AGGREGATECARDSSAVED = "aggregateCardsSaved"
    
    static let USERNAMESNODE = "UserNames"
    static let USERSNODE = "users"
    static let USERFRIENDREQUESTSNODE = "friendRequests"
    static let SENTFRIENDREQUESTSNODE = "sentFriendRequests"
    static let USERFRIENDSNODE = "friends"
    static let USERINTERESTSNODE = "interests"
    static let USERNEXTADKEY = "nextAdKey"
    static let USERDISPLAYNAME = "displayName"
    static let USERUID = "userUID"
    static let USERFULLNAME = "userFullName"
    static let USERGENDER = "userGender"
    static let USERAGE = "userAge"
    
    static let ADSNODE = "ads"
    static let ADCOMMENTSNODE = "comments"
    static let ADCOMMENTTEXTNODE = "text"
    static let ADCOMMENTVOTENODE = "netVotes"
    static let ADCOMMENTTOTALVOTES = "totalVotes"
    static let ADNAMENODE = "name"
    static let ADCAPTIONNODE = "caption"
    static let ADURLNODE = "url"
    static let ADPRIMARYTAGNODE = "Primary Tag"
    static let ADISFROMFRIEND = "isFromFriend"
    static let PUBLICADCOMMENTS = "public ad comments"
    
    static let ADCAPTIONVOTEHISTORYNODE = "adCaptionVoteHistroy"
    
//    static let ADCOMMENTDOWNNODE = "downVotes"
    
    static let DEFAULTCORNERRADIUS: Float = 15.0
    static let DEFAULTCORNERRADIUSSMALL: Float = 10.0
    static let DEFAULTBORDERWIDTH: Float = 2.0
    
//    static let DEFAULTFILEEXTENSION = ".jpg"
    
    static let PUBLISHID = "1fa837a6-3922-4647-9d30-d982313726ff"
    
    static let DEFAULTADPRIORITY: Int = 1
    static let FROMFRIENDPRIORITY: Int = 0
   // static let OUTOFADSPRIORITY: Int = 2
    
    static let OUTOFADSUID = "c20534c0-853f-4d09-8b66-01a3530ae412"
    
}
