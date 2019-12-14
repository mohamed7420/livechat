//
//  RecentChat.swift
//  livechat
//
//  Created by Mohamed on 11/17/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation


func startPrivateChat(user1:User , user2:User)->String{
    
    
    let userID_1 = user1.objectId
    let userID_2 = user2.objectId
    
    var chatRoomId = ""
    
    let value = userID_1.compare(userID_2).rawValue
    
    if value < 0{
        
        chatRoomId = userID_1 + userID_2
    }else{
        
        chatRoomId = userID_2 + userID_1
    }
    
    let memebers = [userID_1 , userID_2]
    
    RecentChat(members: memebers, chatRoomId: chatRoomId, withUserUserName: kWITHUSERFULLNAME, type: kPRIVATE, user: [user1 , user2], avatarGroup: "")
    
    return chatRoomId
}


func RecentChat(members:[String] , chatRoomId:String , withUserUserName:String , type:String , user:[User]? , avatarGroup:String?){

var temp = members

refrence(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
    
    guard let snapshot = snapshot else {return}
    
    if !snapshot.isEmpty{
        
        for recent in snapshot.documents {
            
            let currentRecent = recent.data() as NSDictionary
            
            if let currentUserId = currentRecent[kUSERID]{
                
                if temp.contains(currentUserId as! String){
                    
                    temp.remove(at: temp.firstIndex(of: currentUserId as! String)!)
                }
                
            }
        }
        
    }
    
    for userId in temp{
        
        createRecntItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserName: withUserUserName, type: type, users: user, avatarOfGroup: avatarGroup)
        
    }
    
}

}


func createRecntItems(userId:String , chatRoomId:String , members:[String] , withUserUserName:String,type:String , users:[User]? , avatarOfGroup:String?){
    
    
    let localRefernce = refrence(.Recent).document()
    
    let recentId = localRefernce.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var Recent:[String:Any]!
    
    
    if type == kPRIVATE{
        
        var withUser:User?
        
        if users != nil && users!.count > 0 {
            
            if userId == User.getCurrentUserId(){
                
                withUser = users!.last!
            }else{
                withUser = users!.first!
            }
        }
        
        Recent = [kRECENTID:recentId , kUSERID : userId, kCHATROOMID : chatRoomId,
            kMEMBERS: members , kMEMBERSTOPUSH : members , kWITHUSERFULLNAME: withUser!.fullname , kWITHUSERUSERID:withUser!.objectId , kLASTMESSAGE:"" , kCOUNTER:0 , kDATE:date, kTYPE : type , kAVATAR:withUser!.avatar] as [String:Any]
    }else{
        
        // group
        
        if avatarOfGroup != nil {
            
            Recent = [kRECENTID:recentId,kUSERID:userId,kCHATROOMID:chatRoomId,kMEMBERS:members,kMEMBERSTOPUSH:members,kWITHUSERFULLNAME:withUserUserName,kLASTMESSAGE:"",kCOUNTER:0,kDATE:date,kTYPE:type,kAVATAR:avatarOfGroup!] as [String:Any]
        }
        
    }
    
    localRefernce.setData(Recent)
}


func deleteRecent(userDictionary:NSDictionary){
    
    if let recentId = userDictionary[kRECENTID] {
        
        refrence(.Recent).document(recentId as! String).delete()
        
    }
    
    
}


func restartRecentChat(recent:NSDictionary){
    
    if recent[kTYPE] as! String == kPRIVATE{
            
        RecentChat(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: User.getCurrentUser()!.firstname , type: kPRIVATE, user: [User.getCurrentUser()!], avatarGroup: nil)
    }
    
    if recent[kTYPE] as! String == kGROUP {
        
         RecentChat(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERFULLNAME] as! String , type: kGROUP, user: nil, avatarGroup: recent[kAVATAR] as? String)
        
    }
}

