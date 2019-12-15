//
//  PhotoMediaItem.swift
//  livechat
//
//  Created by Mohamed on 12/15/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem{
    
    override func mediaViewDisplaySize() -> CGSize {
        
        let defaultSize: CGFloat = 256
        
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        
    
    if (self.image != nil && self.image.size.height > 0 && self.image.size.width > 0){
        
        
        let ascpect: CGFloat = self.image.size.width / self.image.size.height
        
        if (self.image.size.width > self.image.size.height){
            
            thumbSize = CGSize(width: defaultSize, height: defaultSize / ascpect)
            
        }else{
            
            thumbSize = CGSize(width: defaultSize * ascpect, height: defaultSize)
            
        }
        
    }
    
        return thumbSize
    }
    
    
    
}
