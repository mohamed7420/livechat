//
//  ProfileTableViewController.swift
//  livechat
//
//  Created by Mohamed on 11/16/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit


class ProfileTableViewController: UITableViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var phonenumber: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    
    var user: User!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        self.tableView.tableFooterView = UIView()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9742896006, green: 0.9742896006, blue: 0.9742896006, alpha: 1)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            return 0
        }
        
        return 30
    }

    //MARK:- IBActions
    
    @IBAction func buttonCallTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func buttonSendMessage(_ sender: UIButton) {
    }
    
    @IBAction func buttonBlockUserTapped(_ sender: UIButton) {
        
        //blockingUser()
        
        var CurrentblockUsers = User.getCurrentUser()!.blockedUsers
        
        if (CurrentblockUsers.contains(user!.objectId)){
            
            CurrentblockUsers.remove(at:CurrentblockUsers.firstIndex(of: user!.objectId)!)
            
        }else{
            
            CurrentblockUsers.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:CurrentblockUsers]) { (error) in
            
            if error != nil {
                
                print("error while updating data\(error!.localizedDescription)")
                return
            }
            
            self.blockingUser()
        }
        
    }
    
    func updateUI(){

        if user != nil{
            
            self.title = "Profile"
            
            self.fullname.text = self.user.fullname
            
            self.phonenumber.text = self.user.phonenumber
            
            blockingUser()
            
            imageFromData(pictureData: self.user.avatar) { (avatarImage) in
                
                if avatarImage != nil{
                    
                    self.profileImage.image = avatarImage!.circleMasked
                }
                
            }
        }
        
    }
    
    func blockingUser(){
        
        
        if user.objectId != User.getCurrentUserId() {
            
            callButton.isHidden = false
            messageButton.isHidden = false
            blockButton.isHidden = false
            
        }else{
            
            callButton.isHidden = true
            messageButton.isHidden = true
            blockButton.isHidden = true
            
        }
        
        
        if (User.getCurrentUser()!.blockedUsers.contains(user.objectId)){
            
            blockButton.setTitle("Unblock user", for: .normal)
        }else{
            
            blockButton.setTitle("block user", for: .normal)

        }
        
    }
    
}

