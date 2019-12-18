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
    
    // MARK:- create message function
    
    func createMessage(messageDictionary:NSDictionary , chatRoomId:String)->JSQMessage?{
        
        let type = messageDictionary[kTYPE] as! String
        
        var message:JSQMessage?
        
        switch type {
            
        case kTEXT:
            
           message =  self.createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:

            message = createVideoMessage(messageDictionary: messageDictionary)
            
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
    
    
    func createPictureMessage(messageDictionary:NSDictionary)->JSQMessage{
        
        let name = messageDictionary[kSENDERNAME] as? String
        
        let userId = messageDictionary[kSENDERID] as? String
        
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            
            if (created as! String).count != 14{
                
                date = Date()
            }else{
                
                date = dateFormatter().date(from: created as! String)
            }
            
        }else{
            
            date = Date()
        }
        
        
        //download image
        
        let mediaItem = PhotoMediaItem(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            
            if image != nil{
                    
                mediaItem?.image = image!
                self.collectionView!.reloadData()
            }
        }
        return JSQMessage(senderId: userId, senderDisplayName: name , date: date, media: mediaItem)
    }
    
    func createVideoMessage(messageDictionary:NSDictionary)->JSQMessage{
        
        let name = messageDictionary[kSENDERNAME] as? String
        
        let userId = messageDictionary[kSENDERID] as? String
        
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            
            if (created as! String).count != 14{
                
                date = Date()
            }else{
                
                date = dateFormatter().date(from: created as! String)
            }
            
        }else{
            
            date = Date()
        }
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        
        //download image
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            
            let url = NSURL(fileURLWithPath: fileInDocumentDirectory(fileName: fileName))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String) { (image) in
                
                if image != nil{
                    mediaItem.image = image!
                    self.collectionView?.reloadData()
                }
            }
            self.collectionView!.reloadData()
        }
      
        return JSQMessage(senderId: userId, senderDisplayName: name , date: date, media: mediaItem)
    }
    
    
    
    //MARK: - Helper
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool{
        
        if senderId == User.getCurrentUserId(){
            
            return true
            
        }else{
            
            return false
        }
        
        
        return senderId == User.getCurrentUserId()
    }
    
}
