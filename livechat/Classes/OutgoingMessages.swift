//
//  OutgoingMessages.swift
//  livechat
//
//  Created by Mohamed on 11/24/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation
import FirebaseFirestore

class OutgoingMessages{
    
    
    var messageDictionary:NSMutableDictionary
    
    init(message:String , senderId:String , senderName:String , date:Date , status:String, type:String) {
        
        messageDictionary = NSMutableDictionary(objects: [message , senderId , senderName , dateFormatter().string(from: date) as NSCopying, status as NSCopying, type as NSCopying], forKeys: [kMESSAGE as NSCopying , kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        
    }
    
    init(message:String , pictureLink: String , senderId:String , senderName:String , date:Date , status:String, type:String) {
        
        messageDictionary = NSMutableDictionary(objects: [message , pictureLink , senderId , senderName , dateFormatter().string(from: date) as NSCopying, status as NSCopying, type as NSCopying], forKeys: [kMESSAGE as NSCopying , kPICTURE as NSCopying , kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        
    }
    
    //MARK:- sending function
    
    
    func sendMessageToFirestore(chatRoomId:String , messageDictionary:NSMutableDictionary , memberIds:[String] , memberToPush:[String]){
        
        let messageId = UUID().uuidString
        
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds{
            
            refrence(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String:Any])
        }
        
        
    }

    
}
