//
//  ChatsViewController.swift
//  livechat
//
//  Created by Mohamed on 11/15/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController , RecentTableViewCellDelegate ,UISearchResultsUpdating {
   
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats:[NSDictionary] = []
    var filterChat:[NSDictionary] = []
    var listner:ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadRecentChat()
        tableView.tableFooterView = UIView()

    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chats"
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        setupCutomTableViewHeader()
        
    }
    
    
    //MARK:- IBActions
    
    
    @IBAction func buttonChatTapped(_ sender: UIBarButtonItem) {
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "UserTableViewController") as! UserTableViewController
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}
extension ChatsViewController : UITableViewDelegate , UITableViewDataSource{
    
    //MARK:- TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return filterChat.count
            
        }else{
            
            return recentChats.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRecent", for: indexPath) as! RecentTableViewCell
        cell.delegate = self
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            recent = filterChat[indexPath.row]
            
        }else{
            
            recent = recentChats[indexPath.row]
            
        }
        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            recent = filterChat[indexPath.row]
            
        }else{
            
            recent = recentChats[indexPath.row]
            
        }
        //Restart chat
        
        restartRecentChat(recent: recent)
        
        let displayChat = DisplayChatViewController()
        
        displayChat.hidesBottomBarWhenPushed = true
        
        displayChat.roomId = (recent[kCHATROOMID] as? String)!
        displayChat.memberToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        displayChat.memberId = (recent[kMEMBERS] as? [String])!
        displayChat.messageTitle = (recent[kWITHUSERUSERNAME] as? String)
        displayChat.isGroup = recent[kTYPE] as! String == kGROUP
        self.navigationController?.pushViewController(displayChat, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempRecent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            tempRecent = filterChat[indexPath.row]
            
        }else{
            
            tempRecent = recentChats[indexPath.row]
            
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            
            deleteRecent(userDictionary: tempRecent)
            
            self.tableView.reloadData()
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: "Mute") { (muteAction, indexPath) in
            
            print("mute \(indexPath)")
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        
        return [deleteAction , muteAction]
    }
    
    //MARK:- Load Recent Messages

func loadRecentChat(){
    
    refrence(.Recent).whereField(kUSERID, isEqualTo: User.getCurrentUserId()).addSnapshotListener { (snapshot, error) in
        
        self.recentChats = []
        
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty{
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
            
            for recent in sorted{
                
                if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil{
                    
                    self.recentChats.append(recent)
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
}
    
    
    func setupCutomTableViewHeader(){
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: self.tableView.frame.width, height: 35))
        
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        let color = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        groupButton.setTitle("New group", for: .normal)
        groupButton.setTitleColor(color, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: header.frame.height + 10, width: tableView.frame.width, height: 1))
        
        lineView.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        buttonView.addSubview(groupButton)
        header.addSubview(buttonView)
        header.addSubview(lineView)
        
        self.tableView.tableHeaderView = header
        
    }

    @objc func groupButtonPressed(){
        
        print("new group")
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        var recentChat: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            recentChat = filterChat[indexPath.row]
            
        }else{
            
            recentChat = recentChats[indexPath.row]
            
        }
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            refrence(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                if snapshot.exists{
                    
                    let userDictionary = snapshot.data()! as NSDictionary
                    
                    let user = User.init(_dictionary: userDictionary)
                    
                    self.sendToProfileViewController(user: user)
                }
            }
            
        }
    }
    
    
    func sendToProfileViewController(user:User){
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
            
            VC.user = user
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
   
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            self.filteredRecentChat(searchText: searchController.searchBar.text!)
        }
        tableView.reloadData()
    }
    
    func filteredRecentChat(searchText:String , scope: String = "All"){
        
        filterChat = recentChats.filter({ (recentChat) -> Bool in
            
            
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        self.tableView.reloadData()
    }

}
