//
//  ViewController.swift
//  livechat
//
//  Created by Mohamed on 11/13/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth

class WelcomeViewController: UIViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repeatPassTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }


    //MARK:- IBActions
    
    @IBAction func registerbuttonTapped(_ sender: UIButton) {
        
        
        if emailTF.text != "" && passwordTF.text != "" && repeatPassTF.text != ""{
            
            if passwordTF.text == repeatPassTF.text{
                
                presentViewController()
                
            }else{
                
                
                ProgressHUD.showError("Password don't match")
            }
            
            
            
        }else{
            
            
            ProgressHUD.showError("All fields are required")
        }
        
        
        
        dissmissKeyboard(Fview: view)
        cleanText()
    }
    
    
    @IBAction func loginbuttonTapped(_ sender: UIButton) {
        
        if emailTF.text != "" && passwordTF.text != ""{
            
            if passwordTF.text == repeatPassTF.text{
                
                loginUser()
                
            }else{
                
                ProgressHUD.showError("Password don't match")
            }
            
        }else{
            
            ProgressHUD.showError("All fields are required")
        }
        
        
        dissmissKeyboard(Fview: view)
        cleanText()
    }
    
    //MARK:- Helper Functions
    
    
    func cleanText(){
        
        emailTF.text = ""
        passwordTF.text = ""
        repeatPassTF.text = ""
        
    }
    
    func dissmissKeyboard(Fview:UIView){
        
        Fview.endEditing(true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    
    func loginUser(){
        
        ProgressHUD.show("Login...")
        
        User.loginUserWith(email: emailTF.text!, password: passwordTF.text!) { (error) in
                
            if error != nil{
                
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            ProgressHUD.dismiss()
            self.presentViewControllerToHome()
        }

    }

    func presentViewController(){
        ProgressHUD.dismiss()
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "RegisterViewController") as! RegisterViewController
        
        VC.modalPresentationStyle = .fullScreen
        VC.email = emailTF.text!
        VC.password = passwordTF.text!
        
        present(VC, animated: true, completion: nil)
    }
    
    func presentViewControllerToHome(){
        
        ProgressHUD.dismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: User.getCurrentUserId()])
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        
        VC.modalPresentationStyle = .fullScreen
        
        present(VC, animated: true, completion: nil)
    }
}

