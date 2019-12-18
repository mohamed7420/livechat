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

//MARK:- Uploading video to Firestore

func uploadVideo(video:NSData , chatRoomId: String , view: UIView , completion: @escaping (_ videoLink: String?)-> Void){
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let videoFile = "VideoMessages/" + User.getCurrentUserId() + "/" + dateString + ".mov"

    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFile)
    
    var task: StorageUploadTask!
    
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metaData, error) in
        
        task.removeAllObservers()
        
        progressHUD.hide(animated: true)
        
        
        if error != nil{
            
            
            print("couldn't upload video to firestore because: \(error!.localizedDescription)")
            
            return
        }
        
        
        storageRef.downloadURL { (videoLink, error) in
            
            guard let videoLink = videoLink else {
                
                completion(nil)
                return
                
            }
            
            completion(videoLink.absoluteString)
            
        }
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        }
        
    })
    
   
    
}


func downloadImage(imageUrl: String , completion: @escaping (_ image: UIImage?)-> Void){
    
    
    let imageURL = NSURL(string: imageUrl)
    
    let imageFileName = (imageUrl.components(separatedBy: "K").last!).components(separatedBy: "?").first!
    
    if fileExisitsAtPath(path: imageFileName){
        
        if let contentsOFFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)){
            
            completion(contentsOFFile)
        }else{
            
            print("Coudn't generate image")
            completion(nil)
        }
        
    }else{
        
        let downloadQueue = DispatchQueue.init(label: "imageDownloadQueue")
        
        downloadQueue.async {
            
            let data = NSData(contentsOf: imageURL! as URL)
            
            if data != nil{
                
                var docURL = getDocumentURL()
                
                docURL = docURL.appendingPathComponent(imageFileName , isDirectory: false)
                
                data!.write(to: docURL, atomically: true )
                
                let imageToReturn = UIImage(data: data! as Data)
                
                DispatchQueue.main.async {
                    completion(imageToReturn!)
                }
                
            }else{
                DispatchQueue.main.async {
                    
                    print("no image in database")
                    completion(nil)
                }
                
            }
            
        }
        
    }
    
}

func videoThumnail(video: NSURL)-> UIImage{
        
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do{
        
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        
        
        
    }catch let error as NSError{
        
        print(error.localizedDescription)
    }
    
    let thumnail = UIImage(cgImage: image!)
    
    return thumnail
}


func downloadVideo(videoUrl: String , completion: @escaping (_ isReadyToPlay: Bool , _ videoFileName: String)-> Void){
    
    
    let videoURL = NSURL(string: videoUrl)
    
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    if fileExisitsAtPath(path: videoFileName){
        
        
        completion(true , videoFileName)
        
    }else{
        
        let downloadQueue = DispatchQueue.init(label: "videoDownloadQueue")
        
        downloadQueue.async {
            
            let data = NSData(contentsOf: videoURL! as URL)
            
            if data != nil{
                
                var docURL = getDocumentURL()
                
                docURL = docURL.appendingPathComponent(videoFileName , isDirectory: false)
                
                data!.write(to: docURL, atomically: true )
                
                DispatchQueue.main.async {
                    completion(true , videoFileName)
                }
                
            }else{
                DispatchQueue.main.async {
                    
                    print("no image in database")
                }
                
            }
            
        }
        
    }
    
}

//Helpers

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
