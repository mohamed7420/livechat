//
//  CustomeUserCell.swift
//  livechat
//
//  Created by Mohamed on 11/15/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit

protocol CustomeUserCellDelegate {
    
    func UserDetail(indexPath:IndexPath)
}

class CustomeUserCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var indexPath:IndexPath!
    
    var delegate:CustomeUserCellDelegate!
    
    let tapRecoginzer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        tapRecoginzer.addTarget(self, action: #selector(imageUserTapped))
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(tapRecoginzer)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func createUser(user:User , indexPath:IndexPath){
        
        self.indexPath = indexPath
        
        userName.text = user.fullname
        
        if user.avatar == ""{
            
            createImageFromText(firstName: user.firstname, surName: user.lastname) { (image) in
                
                self.userAvatar.image = image
            }
        }else if user.avatar != ""{
            
            imageFromData(pictureData: user.avatar) { (avatarImage) in
                
                if avatarImage != nil{
                    
                    self.userAvatar.image = avatarImage!.circleMasked
                }
            }
            
        }
        
    }
    
    
    
    func createImageFromText(firstName:String? , surName:String? ,withBlock: @escaping (_ img:UIImage)->Void){
        
        var string: String!
        var size = 36
        
        if firstName != nil && surName != nil {
            string = String((firstName?.first!)!).uppercased() + String((surName?.first!)!).uppercased()
        } else {
            string = String((firstName?.first!)!).uppercased()
            size = 72
        }
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
        lblNameInitialize.textColor = .white
        lblNameInitialize.font = UIFont(name: lblNameInitialize.font.fontName, size: CGFloat(size))
        lblNameInitialize.text = string
        lblNameInitialize.textAlignment = NSTextAlignment.center
        lblNameInitialize.backgroundColor = UIColor.lightGray
        lblNameInitialize.layer.cornerRadius = 25
        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        withBlock(img!)
    }
    
    
    @objc func imageUserTapped(){
            
        self.delegate.UserDetail(indexPath: indexPath)
        
    }
}
