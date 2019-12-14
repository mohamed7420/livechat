//
//  SettingsTableView.swift
//  livechat
//
//  Created by Mohamed on 11/14/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit


class SettingsTableView: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
    }

 
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 3
    }

    
    @IBAction func buttonTappedLogout(_ sender: UIButton) {
        
        User.userLogout { (success) in
            
            if success {
                self.presentViewController()
                return
            }else{
                print("some thing went wrong")
            }
        }
    }
    
    
    func presentViewController(){
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "WelcomeViewController")
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
        
    }
    
}
