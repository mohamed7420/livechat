//
//  UserTableViewController.swift
//  livechat
//
//  Created by Mohamed on 11/15/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD


class UserTableViewController: UITableViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    var allUsers:[User] = []
    var filterUser:[User] = []
    var sectionTitleList:[String] = []
    var allgroupedUsers:[String:[User]] = [:]
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        segmentedControll.selectedSegmentIndex = 0
        self.loadUsers(filterText: kCITY)
        self.navigationItem.title = "Users"
        self.navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false

    }

  

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return 1
            
        }else{
            
            return allgroupedUsers.count
        }
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filterUser.count
            
        }else{
            
            let sectionTitle = self.sectionTitleList[section]
            
            let users = self.allgroupedUsers[sectionTitle]
            
            return users!.count
        }
        
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! CustomeUserCell
        
        
        var user: User

        if searchController.isActive && searchController.searchBar.text != ""{
        
            user = filterUser[indexPath.row]
        
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allgroupedUsers[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        cell.createUser(user: user, indexPath: indexPath)
        cell.delegate = self
        return cell
    }

    
    @IBAction func segmentedControllAction(_ sender: UISegmentedControl) {
        
         switch sender.selectedSegmentIndex {
               case 0:
                   loadUsers(filterText: kCOUNTRY)
                   return
               case 1:
                   loadUsers(filterText: kCITY)
               case 2:
                   loadUsers(filterText: "All")
               default:
                   return
               }
    }
    
}

extension UserTableViewController :  UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteringUsers(searchText: searchController.searchBar.text!)
    }
    
    
    func filteringUsers(searchText:String , scope:String = "All"){
        
        filterUser = allUsers.filter({ (user) -> Bool in
            
            
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
    func loadUsers(filterText:String){
        
        ProgressHUD.show()
        
        var query:Query!
        
        switch filterText {
            
        case kCOUNTRY:
            query = refrence(.User).whereField(kCOUNTRY, isEqualTo: User.getCurrentUser()!.country).order(by: kFIRSTNAME, descending: false)
        case kCITY:
            query = refrence(.User).whereField(kCITY, isEqualTo: User.getCurrentUser()!.city).order(by: kFIRSTNAME, descending: false)
        default:
            query = refrence(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            ProgressHUD.dismiss()
            self.allUsers = []
            self.sectionTitleList = []
            self.allgroupedUsers = [:]
            
            if error != nil{
                
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = snapshot else {
                
                ProgressHUD.dismiss();return
                
            }
            
            if !snapshot.isEmpty {

                for userDictionary in snapshot.documents{
                    
                    let userDictionary = userDictionary.data()
                    let user = User(_dictionary: userDictionary as NSDictionary)
                    
                    if user.objectId != User.getCurrentUserId(){
                        
                        self.allUsers.append(user)
                        
                    }
                }
                self.splitUsers()
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
        var user: User
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            user = filterUser[indexPath.row]
            
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allgroupedUsers[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        startPrivateChat(user1: User.getCurrentUser()!, user2: user)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return ""
            
        }else{
            
            return sectionTitleList[section]
        }
        
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return nil
        }else{
            
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    
    fileprivate func splitUsers(){
        
        
        var sectionTitle: String = ""
        
        
        for i in 0..<self.allUsers.count{
            
            let currentUser = allUsers[i]
            
            let firstCar = currentUser.firstname.first
            
            let firstCarString = "\(firstCar!)"
            
            if firstCarString != sectionTitle {
                
                sectionTitle = firstCarString
                
                self.allgroupedUsers[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            
            self.allgroupedUsers[firstCarString]?.append(currentUser)
        }
    }
    
}

extension UserTableViewController : CustomeUserCellDelegate{
    
    func UserDetail(indexPath: IndexPath) {
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
        
        VC.modalPresentationStyle = .fullScreen
        
        var user: User
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            user = filterUser[indexPath.row]
            
        }else{
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allgroupedUsers[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        VC.user = user
        
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    
    
}
