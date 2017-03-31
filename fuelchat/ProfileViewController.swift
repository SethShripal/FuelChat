//
//  ProfileViewController.swift
//  fuelchat
//
//  Created by Shripal Jain on 31/03/17.
//  Copyright © 2017 Shripal Jain. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    var uname:String!
    var fname:String!
    var lname:String!
    
    
    var pic:String!

    @IBOutlet weak var profilepic: UIButton!
    @IBOutlet weak var lasname: UILabel!
    @IBOutlet weak var firname: UILabel!
    @IBOutlet weak var username: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        lasname.text = lname
        firname.text = fname
        username.text = uname
        profilepic.sd_setImage(with: URL(string: pic), for: .normal)
    }

    @IBAction func goback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
