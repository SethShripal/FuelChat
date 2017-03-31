//
//  UserTableViewCell.swift
//  fuelchat
//
//  Created by Shripal Jain on 29/03/17.
//  Copyright © 2017 Shripal Jain. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileimg: UIButton!
    
    @IBOutlet weak var name: UIButton!
    
    
    @IBOutlet weak var newmessage: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileimg.layer.cornerRadius = 25
        profileimg.clipsToBounds = true
        newmessage.layer.cornerRadius = 25
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
