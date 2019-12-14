//
//  User.swift
//  livechat
//
//  Created by Mohamed on 11/13/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import ProgressHUD

class User {
    
    let objectId:String
    let pushId:String?
    var email:String
    var firstname:String
    var lastname:String
    var fullname:String
    let createdAt:Date
    var updatedAt:Date
    var avatar:String
    var isOnline:Bool
    var phonenumber:String
    var countryCode:String
    var country:String
    var city:String
    
    var contacts:[String]
    var blockedUsers: [String]
    
    let loginMethod:String
    
    
    init(_objectId:String , _pushId:String? , _email:String , _firstname:String , _lastname:String ,_createdAt:Date , _updatedAt:Date , _avatar:String , _phonenumber:String, _country:String, _city:String , _loginMethod:String) {
        
        self.objectId = _objectId
        self.pushId = _pushId
        self.firstname = _firstname
        self.lastname = _lastname
        self.fullname = firstname + " " + lastname
        self.email = _email
        self.createdAt = _createdAt
        self.updatedAt = _updatedAt
        self.avatar = _avatar
        self.isOnline = true
        self.phonenumber = _phonenumber
        self.country = _country
        self.countryCode = ""
        self.city = _city
        self.contacts = []
        self.blockedUsers = []
        self.loginMethod = _loginMethod
    }
    
    init(_dictionary:NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        if let created = _dictionary[kCREATEDAT] {
            if (created as! String).count != 14 {
                createdAt = Date()
            } else {
                createdAt = dateFormatter().date(from: created as! String)!
            }
        } else {
            createdAt = Date()
        }
        if let updateded = _dictionary[kUPDATEDAT] {
            if (updateded as! String).count != 14 {
                updatedAt = Date()
            } else {
                updatedAt = dateFormatter().date(from: updateded as! String)!
            }
        } else {
            updatedAt = Date()
        }
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstname = fname as! String
        } else {
            firstname = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastname = lname as! String
        } else {
            lastname = ""
        }
        fullname = firstname + " " + lastname
        if let avat = _dictionary[kAVATAR] {
            avatar = avat as! String
        } else {
            avatar = ""
        }
        if let onl = _dictionary[kISONLINE] {
            isOnline = onl as! Bool
        } else {
            isOnline = false
        }
        if let phone = _dictionary[kPHONE] {
            phonenumber = phone as! String
        } else {
            phonenumber = ""
        }
        if let countryC = _dictionary[kCOUNTRYCODE] {
            countryCode = countryC as! String
        } else {
            countryCode = ""
        }
        if let cont = _dictionary[kCONTACT] {
            contacts = cont as! [String]
        } else {
            contacts = []
        }
        if let block = _dictionary[kBLOCKEDUSERID] {
            blockedUsers = block as! [String]
        } else {
            blockedUsers = []
        }

        if let lgm = _dictionary[kLOGINMETHOD] {
            loginMethod = lgm as! String
        } else {
            loginMethod = ""
        }
        if let cit = _dictionary[kCITY] {
            city = cit as! String
        } else {
            city = ""
        }
        if let count = _dictionary[kCOUNTRY] {
            country = count as! String
        } else {
            country = ""
        }
        
    }
    
    
    //MARK:- getting current user id
    
    class func getCurrentUserId()->String{
        
        
        return Auth.auth().currentUser!.uid
    }
    
    //MARK:- getting current user
    
    class func getCurrentUser()->User?{
        
        if Auth.auth().currentUser != nil{
            
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER){
                
                return User.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
    
    // MARK:- user login to firebase
    
    class func loginUserWith(email:String , password:String , completion: @escaping (_ error:Error?)->Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (firtUser, error) in
            
            if error != nil{
                
                completion(error)
                return
                
            }else{
                
                // fetch current user from firestore and save it locally
                fetchCurrentUserFromFirestore(userId: (firtUser?.user.uid)!)
                completion(error)
            }
            
            
        }
        
        
    }

    
    //MARK:- regitering user to firebase
    
    class func registerUserWith(email:String ,password:String,firstname:String , lastname:String , avatar:String ,country:String,phonenumber:String,city:String, completion: @escaping(_ error:Error?)->Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (firuser, error) in
            
            if error != nil {
                
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            let user = User(_objectId: firuser!.user.uid, _pushId: "",_email: firuser!.user.email!, _firstname: firstname, _lastname: lastname, _createdAt: Date(), _updatedAt: Date(), _avatar: "", _phonenumber: phonenumber, _country:country, _city:city, _loginMethod: kEMAIL)
            
            saveUserLocally(user: user)
            saveUserToFirestore(user: user)
            completion(error)
        }
        
        
        
    }
    
    
    //MARK:-fetch current user from firestore and save it locally
    
    class func fetchCurrentUserFromFirestore(userId:String){
        
        refrence(.User).document(userId).getDocument { (snapshot, error) in
            
            if snapshot!.exists{
                
                print("user update his/her data")
                
                UserDefaults.standard.setValue(snapshot?.data(), forKey: kCURRENTUSER)
                UserDefaults.standard.synchronize()
                
            }
            
        }
        
    }
    
    //MARK:- user logout
    
    class func userLogout(completion: @escaping(_ isSuccess:Bool)->Void){
        UserDefaults.standard.removeObject(forKey: kPUSHID)
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        
        // remove onSignal
        removeOneSignalId()
        UserDefaults.standard.synchronize()
        
        do{
            
            try Auth.auth().signOut()
            completion(true)
        }catch let error as NSError{
            
            completion(false)
            print(error.localizedDescription)
        }
    }
    
}



//MARK: glopal Functions

enum FCollectionRefrence:String{
    
    case User
    case Typing
    case Message
    case Recent
}

// reference

func refrence(_ collectionreference:FCollectionRefrence)->CollectionReference{
    
    return Firestore.firestore().collection(collectionreference.rawValue)
}


//MARK:- user dictionary function

func userDictionaryFrom(user: User) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.firstname, user.lastname, user.fullname, user.avatar, user.contacts, user.blockedUsers, user.isOnline, user.phonenumber, user.countryCode, user.city, user.country], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kCONTACT as NSCopying, kBLOCKEDUSERID as NSCopying, kISONLINE as NSCopying, kPHONE as NSCopying, kCOUNTRYCODE as NSCopying, kCITY as NSCopying, kCOUNTRY as NSCopying])
}
 

//MARK:- save user locally on user device

func saveUserLocally(user:User){
    
    UserDefaults.standard.setValue(userDictionaryFrom(user: user), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}

//MARK:- save user on firestore

func saveUserToFirestore(user:User){
    
    refrence(.User).document(user.objectId).setData(userDictionaryFrom(user: user) as! [String : Any]) { (error) in
        
        print(error?.localizedDescription as Any)
    }
}

//MARK: OneSignal

func updateOneSignalId() {
    
    if User.getCurrentUser() != nil {

        if let pushId = UserDefaults.standard.string(forKey: kPUSHID) {
            setOneSignalId(pushId: pushId)
        } else {
            removeOneSignalId()
        }
    }
}


func setOneSignalId(pushId: String) {
    updateCurrentUserOneSignalId(newId: pushId)
}


func removeOneSignalId() {
    updateCurrentUserOneSignalId(newId: "")
}

//MARK: Updating Current user funcs

func updateCurrentUserOneSignalId(newId: String) {

    updateCurrentUserInFirestore(withValues: [kPUSHID : newId]) { (error) in
        if error != nil {
            print("error updating push id \(error!.localizedDescription)")
        }
    }
}

func getUsersFromFirestore(withIds: [String], completion: @escaping (_ usersArray: [User]) -> Void) {
    
    var count = 0
    var usersArray: [User] = []
    
    //go through each user and download it from firestore
    for userId in withIds {
        
        refrence(.User).document(userId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {

                let user = User(_dictionary: snapshot.data()! as NSDictionary)
                count += 1
                
                //dont add if its current user
                if user.objectId != User.getCurrentUserId() {
                    usersArray.append(user)
                }

            } else {
                completion(usersArray)
            }
            
            if count == withIds.count {
                //we have finished, return the array
                completion(usersArray)
            }

        }
        
    }
}

func updateCurrentUserInFirestore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        var tempWithValues = withValues
        
        let currentUserId = User.getCurrentUserId()
        
        let updatedAt = dateFormatter().string(from: Date())
        
        tempWithValues[kUPDATEDAT] = updatedAt
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        userObject.setValuesForKeys(tempWithValues)
        
        refrence(.User).document(currentUserId).updateData(withValues) { (error) in
            
            if error != nil {
                
                completion(error)
                return
            }

            //update current user
            UserDefaults.standard.setValue(userObject, forKeyPath: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            
            completion(error)
        }

    }
}
