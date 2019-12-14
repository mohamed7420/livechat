//
//  Downloader.swift
//  livechat
//
//  Created by Mohamed on 12/14/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation


let storage = Storage.storage()


//Image

func uploadImage(image: UIImage , chatRoomId: String , view: UIView, completion: @escaping (_ imageLink: String?)->Void){
    
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let photoFileName = "PictureMessages/" + User.getCurrentUserId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    
    var task: StorageUploadTask!
    
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
        
        task.removeAllObservers()
        
        progressHUD.hide(animated: true)
        
        if error != nil{
            
            print(error!.localizedDescription)
            return
        }
        
        storageRef.downloadURL { (url, error) in
            
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            
            completion(downloadURL.absoluteString)
        }
        
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
    
}


func downloadImage(imageUrl: String , completion: @escaping (_ image: UIImage?)-> Void){
    
    
    let imageURL = NSURL(string: imageUrl)
    
    let imageFileName = (imageUrl.components(separatedBy: "K").last!).components(separatedBy: "?").first!
    
}


func fileInDocumentDirectory(fileName: String) -> String{
    
    let fileURL = getDocumentURL().appendingPathComponent(fileName)

    return fileURL.path
}

func getDocumentURL() -> URL{
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentURL!
}

func fileExisitsAtPath(path: String) -> Bool{
    
    var doesExisit = false
    
    let filePath = fileInDocumentDirectory(fileName: path)
    let fileManger = FileManager.default
    
    if fileManger.fileExists(atPath: filePath){
        
        doesExisit = true
    }else{
        
        doesExisit = false
        
    }
    
    return doesExisit
}
