//
//  RecentTableViewCell.swift
//  livechat
//
//  Created by Mohamed on 11/19/19.
//  Copyright © 2019 Mohamed74. All rights reserved.
//

import UIKit

protocol RecentTableViewCellDelegate {
    
    func didTapAvatarImage(indexPath:IndexPath)
}

class RecentTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var labelCounter: UILabel!
    @IBOutlet weak var counterContainer: UIView!
    
    var indexPath:IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    
    var delegate:RecentTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        counterContainer.layer.cornerRadius = counterContainer.frame.height / 2
        labelCounter.layer.cornerRadius = labelCounter.frame.height / 2
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGesture)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    func generateCell(recentChat: NSDictionary , indexPath:IndexPath){
        
    self.indexPath = indexPath
    
    self.fullnameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
    
    self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
    
    if let avatarString = recentChat[kAVATAR]{
        
        imageFromData(pictureData: avatarString as! String) { (avatarImage) in
            
            if avatarImage != nil{
                
                self.avatarImage.image = avatarImage?.circleMasked
            }
        }
    }
    
    if recentChat[kCOUNTER] as! Int != 0{
        
        self.labelCounter.text = "\(recentChat[kCOUNTER] as! Int)"
        
        self.counterContainer.isHidden = false
        self.labelCounter.isHidden = false
        
    }else{
        
        self.counterContainer.isHidden = false
        self.labelCounter.isHidden = false
        
    }
    
    var date:Date!
    
    if let created = recentChat[kDATE]{
        
        if (created as! String).count != 14 {
            
            date = Date()
        }else{
            
            date = dateFormatter().date(from: created as! String)
        }
    }else{
        
        date = Date()
        
    }
    
    self.dateLabel.text = timeElapsed(date: date)
}
    
    @objc func avatarTap(){
        
        delegate!.didTapAvatarImage(indexPath: indexPath)
        
    }

}
