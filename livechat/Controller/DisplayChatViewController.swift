//
//  DisplayChatViewController.swift
//  livechat
//
//  Created by Mohamed on 11/22/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IDMPhotoBrowser
import AVFoundation
import AVKit
import IQAudioRecorderController
import FirebaseFirestore


class DisplayChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.red)
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.gray)
    
    var roomId:String!
    
    var memberId:[String]!
    
    var memberToPush:[String]!
    
    var messageTitle:String!
    var withUsers:[User] = []
    
    var isGroup:Bool?
    var group: NSDictionary?
    var messages:[JSQMessage] = []
    var objectMessages:[NSDictionary] = []
    var loadedMessage:[NSDictionary] = []
    var allPictureMessages:[String] = []
    var intailLoadComplete = false
    var legitTypes = [kAUDIO , kVIDEO , kTEXT , kLOCATION , kPICTURE]
    
    var maxMessagesNumber = 0
    var minMessagesNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var typingListner: ListenerRegistration?
    var updateChatListner: ListenerRegistration?
    var newChatListner: ListenerRegistration?

    //MARK:- CustomHeader
    let leftBarView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        
        return view
    }()
    
    let avatarButton: UIButton = {
        
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 35, height: 35))
        
        return button
    }()
    
    let titleLabel: UILabel = {
       
        let title = UILabel(frame: CGRect(x: 40, y: 10, width: 140, height: 15))
        
        title.textAlignment = .left
        
        title.font = UIFont(name: title.font.fontName, size: 14)
        
        return title
    }()
    
    let subtite: UILabel = {
        
       let subtitle = UILabel(frame: CGRect(x: 40, y: 25, width: 140, height: 15))
        
        subtitle.textAlignment = .left
        subtitle.font = UIFont(name: subtitle.font.fontName, size: 14)
        
        return subtitle
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        self.senderId = User.getCurrentUserId()
        self.senderDisplayName = User.getCurrentUser()!.firstname
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        setCustomTitle()
        
        loadMessages()

    }
    
    //MARK:- IBActions
    
    @objc func backAction(){
        
        self.navigationController?.popViewController(animated: true)
    }
    

    
    //MARK:- JSQMessages Delegate
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMoreMessages(maxNumber: maxMessagesNumber, minNumber: minMessagesNumber)
        self.collectionView.reloadData()

    }
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraPhoto = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            print("take photo from camera")
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        }
        
        let takeVideoFromLibrary = UIAlertAction(title: "Video Library", style: .default) { (action) in
            

            camera.PresentVideoLibrary(target: self , canEdit: false)
        

        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            
            print("take photo from camera")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            print("cancel")
        }
        
        cameraPhoto.setValue(UIImage(named: "camera"), forKey: "image")
        photoLibrary.setValue(UIImage(named: "picture"), forKey: "image")
        takeVideoFromLibrary.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")

        alert.addAction(cameraPhoto)
        alert.addAction(photoLibrary)
        alert.addAction(takeVideoFromLibrary)
        alert.addAction(shareLocation)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
            
        if text != ""{
            self.sendMessages(text: text, date: date, picture: nil, audio: nil, video: nil, location: nil)
            updateSendingButton(isSend: false)
        }else{
            
            updateSendingButton(isSend: true)
        }

    }
    
    //MARK:- Custom send button
    
    override func textViewDidChange(_ textView: UITextView) {
        
        
        if textView.text != "" {
            
            updateSendingButton(isSend: true)
        }else{
            
            updateSendingButton(isSend: false)
        }
    }
    
    
    //MARK: - UIImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessages(text: nil, date: Date(), picture: picture, audio: nil, video: video, location: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- send messages

    func sendMessages(text:String? , date:Date , picture:UIImage? , audio:String? , video:NSURL? , location:String?){
        
        
        var outgoingMessage:OutgoingMessages?
        let currentUser = User.getCurrentUser()
        
        if let text = text{
            
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        
        //Picture Messages
        
        if let pic = picture{
            
            uploadImage(image: pic, chatRoomId: roomId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil{
                    
                    let text = "[\(kPICTURE)]"
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currentUser!.objectId, senderName: currentUser!.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    
                    outgoingMessage?.sendMessageToFirestore(chatRoomId: self.roomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberId, memberToPush: self.memberToPush)
                    
                }
            }
            
            return
        }
        
        // send Video
        
        if let video = video{
            
            let videoDate = NSData(contentsOfFile: video.path!)
            
            let dataThumbnail = videoThumnail(video: video).jpegData(compressionQuality: 0.3)
            uploadVideo(video: videoDate!, chatRoomId: roomId, view: self.navigationController!.view) { (videoLink) in
                
                if videoLink != nil{
                    
                    let text = "[\(kVIDEO)]"
                    
                outgoingMessage = OutgoingMessages(message: text, videoLink: videoLink!, thumbNail: dataThumbnail! as NSData, senderId: currentUser!.objectId, senderName: currentUser!.fullname , date: date, status: kDELIVERED, type: kVIDEO)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                outgoingMessage?.sendMessageToFirestore(chatRoomId: self.roomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberId, memberToPush: self.memberToPush)
                    
                    
                }
                
            }
            
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        self.finishSendingMessage()
        
        outgoingMessage?.sendMessageToFirestore(chatRoomId: roomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberId, memberToPush: memberToPush)
        
        
    }
    
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == User.getCurrentUserId(){
            
            cell.textView?.textColor = .white
            
        }else{
            
            cell.textView?.textColor = .black
        }
        
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == User.getCurrentUserId(){
            
            return outgoingBubble
            
        }else{
            
            return incomingBubble
            
        }
        
    }
    
    //MARK:- loading Messages
    
    func loadMessages(){
        
        // get last 11 messages
    
    refrence(.Message).document(User.getCurrentUserId()).collection(roomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            self.intailLoadComplete = true
            return
        }
        let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
        
        //remove bad messages
        self.loadedMessage = self.removeBadMessages(allMessages: sorted)
        
        self.insertMessages()
        self.finishReceivingMessage(animated: true)
        
        self.intailLoadComplete = true
        
        print("our sorted is \(sorted)")
        print("we have \(self.messages.count) loaded messages")
        print("my loaded messages " , self.loadedMessage.count)
        // get picture messages
        
        self.getOldMessagesInBackground()
        self.listenToNewChats()
        
        
        
        }
      
    }
    
    
    
    func listenToNewChats(){
        
        var lastMessageData = "0"
        
        if loadedMessage.count > 0{
            
            lastMessageData = loadedMessage.last![kDATE] as! String
        }
        
        newChatListner = refrence(.Message).document(User.getCurrentUserId()).collection(roomId).whereField(kDATE, isEqualTo: lastMessageData).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty{
            
            for diff in snapshot.documentChanges{
                
                if diff.type == .added{
                    
                    let item = diff.document.data() as NSDictionary
                    
                    if let type = item[kTYPE]{
                        
                        if self.legitTypes.contains(type as! String){
                            
                            // For Picture Messages
                            
                            if type as! String == kPICTURE{
                                //add pictures
                            }
                            
                            if self.insertIntialLoadMessages(messageDictionary: item){
                                
                                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                
                            }
                            
                            self.finishReceivingMessage()
                        }
                    }
                }
            }
            
        }
    })
    }
    
    func getOldMessagesInBackground(){
        
        if loadedMessage.count > 10{
            
            let firstMessageDate = loadedMessage.first![kDATE] as! String
            
            refrence(.Message).document(User.getCurrentUserId()).collection(roomId).whereField(kDATE, isEqualTo: firstMessageDate).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessage = self.removeBadMessages(allMessages: sorted) + self.loadedMessage
                
                // get the picture messages
                
                self.maxMessagesNumber = self.loadedMessage.count - self.loadedMessagesCount - 1
                self.minMessagesNumber = self.maxMessagesNumber - kNUMBEROFMESSAGES
                
            }
        }
        
        
    }
    
    
    // MARK:- insert message
    
   
    func insertMessages() {
        
        maxMessagesNumber = loadedMessage.count - loadedMessagesCount
        minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in minMessagesNumber ..< maxMessagesNumber {
            let messageDictionary = loadedMessage[i]
            
            insertIntialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessage.count)
    }

    
    func insertIntialLoadMessages(messageDictionary:NSDictionary)->Bool{
        
        let incomingMessages = IncoumingMessage(collectionView_: self.collectionView)
        
        if (messageDictionary[kSENDERID] as! String) != User.getCurrentUserId(){
            
            
        }
        
        let message = incomingMessages.createMessage(messageDictionary: messageDictionary, chatRoomId: roomId)
        
        if message != nil{
            
            objectMessages.append(messageDictionary)
            
            messages.append(message!)
        
        }
        
        
        return isIncomingMessage(messageDictionary: messageDictionary)
    }
    
    
    //MARK:- Load more messages
    
    func loadMoreMessages(maxNumber: Int , minNumber: Int){
        
        if loadOld{
            
            maxMessagesNumber = minNumber - 1
            
            minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        }
        
        if minMessagesNumber < 0{
            
            minMessagesNumber = 0
            
        }
        
        for i in (minMessagesNumber ... maxMessagesNumber ).reversed(){
            
            let messageDictionary = loadedMessage[i]
            
            self.insertNewMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessage.count)
    }
    
    func insertNewMessages(messageDictionary: NSDictionary){
        
        let incomingMessage = IncoumingMessage(collectionView_: self.collectionView)
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: roomId)
        
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    func updateSendingButton(isSend:Bool){
    
    if isSend{
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        
    }else{
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
    }
}
    
    func removeBadMessages(allMessages:[NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages{
            
        if message[kTYPE] != nil{
            
        if !self.legitTypes.contains(message[kTYPE] as! String){
            
            tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
        
        }else{
            
            tempMessages.remove(at: tempMessages.firstIndex(of: message)!)

        }
        
        }
            
        }
        
        return tempMessages
    }
    
    
    func isIncomingMessage(messageDictionary: NSDictionary)-> Bool{
        
        if User.getCurrentUserId() == messageDictionary[kSENDERID] as! String{
            
            return false
            
        }else{
            
            return true
        }
        
        
    }
    

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.row % 3 == 0 {
            
            let message = messages[indexPath.row]
            
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.row % 3 == 0 {
            
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        
        if indexPath.row % 3 == 0 {
            
            let message = objectMessages[indexPath.row]
            
            let status: NSAttributedString!
            
            let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
            
            switch message[kSTATUS] as! String {
                
            case kDELIVERED:
                
                status = NSAttributedString(string: kDELIVERED)
            case kREAD:
                
                let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
                status = NSAttributedString(string: statusText , attributes: attributedStringColor)
            default:
                
                status = NSAttributedString(string: "✔")
                
            }
            
            if indexPath.row == (message.count - 1){
                
                return status
                
            }else{
                
                return NSAttributedString(string: "")
            }
            
            
        }
        
        
        return NSAttributedString(string: "")
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let data = messages[indexPath.row]
        
        if data.senderId == User.getCurrentUserId(){
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            
            return 0.0
        }
    
    }
    
    
    //MARK:- setCustomTitle
    
    func setCustomTitle(){
        
        leftBarView.addSubview(avatarButton)
        
        leftBarView.addSubview(titleLabel)
        
        leftBarView.addSubview(subtite)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(handleInfoButton))
        
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup ?? false{
            
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
            
        }else{
            
        avatarButton.addTarget(self, action: #selector(self.userProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memberId) { (withUsers) in
            
            self.withUsers = withUsers
            
            if !self.isGroup!{
                
                self.setUIforSignleChat()
                
            }
        }
        
    }
    
    @objc func userProfile(){
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
        
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func showGroup(){
        
       
    }
    
    @objc func handleInfoButton(){
        
        print("show image messages")
    }
    
    func setUIforSignleChat(){
        
        let withUser = withUsers.first
        
        imageFromData(pictureData: withUser!.avatar) { (image) in
            
            if image != nil{
                
                avatarButton.setImage(image!.circleMasked, for: .normal)
                
            }
        }
        avatarButton.setImage(UIImage(named: "avatarPlaceholder"), for: .normal)
        titleLabel.text = withUser!.fullname
        if withUser!.isOnline{
            
            subtite.text = "Online"
            
        }else{
            
            subtite.text = "Offline"
        }
        
        avatarButton.addTarget(self, action: #selector(self.userProfile), for: .touchUpInside)
        
    }
    
}

extension JSQMessagesInputToolbar {
    
override open func didMoveToWindow() {
    
    super.didMoveToWindow()
    
    guard let window = window else { return }
    
    if #available(iOS 11.0, *) {
        
    let anchor = window.safeAreaLayoutGuide.bottomAnchor
    bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0)
        .isActive = true
        
    }
 }
    
}
