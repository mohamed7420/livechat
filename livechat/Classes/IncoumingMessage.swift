//
//  IncoumingMessage.swift
//  livechat
//
//  Created by Mohamed on 11/24/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation
import JSQMessagesViewController


class IncoumingMessage{
    
    var collectionView:JSQMessagesCollectionView?

    
    
    init(collectionView_: JSQMessagesCollectionView) {
        
        self.collectionView = collectionView_
    }
    
    // create message function
    
    func createMessage(messageDictionary:NSDictionary , chatRoomId:String)->JSQMessage?{
        
        let type = messageDictionary[kTYPE] as! String
        
        var message:JSQMessage?
        
        switch type {
            
        case kTEXT:
            
           message =  self.createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        case kVIDEO:
            print("message type is video")
        
        case kAUDIO:
            print("message type is audio")
        
        case kLOCATION:
            print("message type is location")
        
        default:
            print("Unkown message")
        
        }
    
        if message != nil{
            
            return message
        }
        
        return nil
    }
    
    
    func createTextMessage(messageDictionary:NSDictionary , chatRoomId:String)->JSQMessage{
        
        let name = messageDictionary[kSENDERNAME] as? String
        
        let userId = messageDictionary[kSENDERID] as? String
        
        var date:Date!
        
        if let created = messageDictionary[kDATE] {
            
            if (created as! String).count != 14{
                
                date = Date()
            }else{
                
                date = dateFormatter().date(from: created as! String)
            }
            
        }else{
            
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    
    
}
