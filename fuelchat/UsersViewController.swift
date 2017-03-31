//
//  UsersViewController.swift
//  fuelchat
//
//  Created by Shripal Jain on 29/03/17.
//  Copyright © 2017 Shripal Jain. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class UsersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var UserTV: UITableView!
    var dbRef: FIRDatabaseReference!
    var contactsRef: FIRDatabaseReference!
    var usernames = [String]()
    var profilelinks = [String]()
    var keys = [String]()
    var index : Int!
    var pic:String!
    var uname:String!
    var fname:String!
    var lname: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        UserTV.delegate = self
        UserTV.dataSource  = self
        
        self.dbRef = FIRDatabase.database().reference()
        self.contactsRef = self.dbRef.child("Contacts")
        
        fetchContacts()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        UserTV.reloadData()
    }
    @IBAction func moremenu(_ sender: Any) {
        
        let alert = UIAlertController(title: "Misc Options", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default , handler:{ (UIAlertAction)in
            
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Profile", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "movetoprofile", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserTableViewCell
        
        cell.name.setTitle(usernames[indexPath.row], for: .normal)
        let url = NSURL(string: profilelinks[indexPath.row])
        cell.profileimg.sd_setImage(with: url as URL?, for: .normal)
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "movetochat" , sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "movetochat"){
        let destinationNavigationController = segue.destination as! UINavigationController
        let chatvc = destinationNavigationController.topViewController as! ChatViewController
        chatvc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatvc.senderDisplayName = FIRAuth.auth()?.currentUser?.email
        chatvc.receiverId = keys[index]
        chatvc.receiverDisplayName = usernames[index]
        }
        else if(segue.identifier == "movetoprofile")
        {
            let destinationNavigationController = segue.destination as! UINavigationController
            let profilevc = destinationNavigationController.topViewController as! ProfileViewController
            profilevc.fname = self.fname
            profilevc.lname = self.lname
            profilevc.uname = self.uname
            profilevc.pic = self.pic
            
        }
    }
    func fetchContacts(){
        self.contactsRef.observe(.childAdded, with: {(snapshot:FIRDataSnapshot) in
            print(snapshot.key)
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            if username+"@fuelchat.com" != FIRAuth.auth()?.currentUser?.email{
            self.usernames.append(username)
            let profilelink = value?["profilepic"] as? String ?? ""
            self.profilelinks.append(profilelink)
            let key = snapshot.key
            self.keys.append(key)
            
            }
            else{
                self.pic = value?["profilepic"] as? String ?? ""
                self.uname = value?["username"] as? String ?? ""
                self.fname = value?["fname"] as? String ?? ""
                self.lname = value?["lname"] as? String ?? ""
            }
            DispatchQueue.main.async {
                self.UserTV.reloadData()
            }
        }, withCancel: {(error) in
                print("Error Fetching Data")
         
        })
    }

}
