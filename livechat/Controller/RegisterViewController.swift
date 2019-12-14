//
//  RegisterViewController.swift
//  livechat
//
//  Created by Mohamed on 11/14/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    
    var email:String!
    var password:String!
    var avatar:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.endEditing(true)
        
     
       
    }
    
    //MARK:- IBActions
    
    @IBAction func buttonCancelTapped(_ sender: UIButton) {
        
        cleanText()
        dissmissKeyboard(Fview: view)
        dismiss(animated: true, completion: nil)
    

    }
    

    @IBAction func buttonDoneTapped(_ sender: UIButton) {
        
        ProgressHUD.show("Register...")
        dissmissKeyboard(Fview: view)
        
        if nameTF.text != "" && surnameTF.text != "" && countryTF.text != "" && cityTF.text != "" && phoneTF.text != "" {
            
            User.registerUserWith(email: email, password: password, firstname: nameTF.text!, lastname: surnameTF.text!, avatar: "", country: countryTF.text!, phonenumber: phoneTF.text!, city: cityTF.text!) { (error) in
                
                if error != nil{
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                    
                }else{
                    
                    ProgressHUD.showSuccess("Successfully Registering")
                    self.presentViewController()
                }
                
            }
        }else{
            
            ProgressHUD.showError("All fields are required")
        }
        
        
        cleanText()
        
    }
    
    func cleanText(){
        
        nameTF.text = ""
        surnameTF.text = ""
        countryTF.text = ""
        cityTF.text = ""
        phoneTF.text = ""
    }
    
    func dissmissKeyboard(Fview:UIView){
        
        Fview.endEditing(true)
        
    }
    
    func presentViewController(){
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: User.getCurrentUserId()])
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
        
    }
    
}
