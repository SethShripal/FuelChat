//
//  SignUpViewController.swift
//  fuelchat
//
//  Created by Shripal Jain on 29/03/17.
//  Copyright © 2017 Shripal Jain. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profilebtn: UIButton!
    @IBOutlet weak var camerabtn: UIButton!
    @IBOutlet weak var lastnametf: UITextField!
    @IBOutlet weak var usernametf: UITextField!
    @IBOutlet weak var firstnametf: UITextField!
    

    var imgtask:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        profilebtn.layer.cornerRadius = 52
        profilebtn.clipsToBounds = true
        camerabtn.layer.cornerRadius = 18
        camerabtn.clipsToBounds = true
        
        //newUser = BackendlessUser()
        // Do any additional setup after loading the view.
    }

    //To fetch gallery feed
    @IBAction func profilebtnclicked(_ sender: Any) {
        let imgpicker = UIImagePickerController()
        imgpicker.allowsEditing = true
        imgpicker.delegate = self
        imgpicker.sourceType = .photoLibrary
        
        self.present(imgpicker, animated: true, completion: nil)
    }
    @IBAction func savebtnclicked(_ sender: Any) {
        if firstnametf.text == "" {
            ProgressHUD.showError("First Name Cannot Be Empty")
        }else if lastnametf.text == "" {
            ProgressHUD.showError("Last Name Cannot Be Empty")
        }
        else if usernametf.text == ""{
            ProgressHUD.showError("Username Name Cannot Be Empty")
        }
        else if (usernametf.text?.contains(" "))! {
            ProgressHUD.showError("Username Name Cannot contain spaces")
        }
        else{
            ProgressHUD.show("Signing Up...",interaction:false)
            register(fname: firstnametf.text!, lname: lastnametf.text!, avatar: profilebtn.imageView?.image,username: usernametf.text!)
            print("Registring Now")
        }
        
    }
    //Register Function
    func register(fname:String,lname:String,avatar:UIImage?,username:String){
       //data var fileurl = ""
        let data = UIImageJPEGRepresentation(imgtask, 0.3)
        let filename = "\(NSDate().timeIntervalSince1970)\(username).jpeg"
        
        FIRAuth.auth()?.createUser(withEmail: username+"@fuelchat.com", password: "123456") { (user, error) in
            if error != nil {
                ProgressHUD.showError("Error in Registration")
            }
            else{
                let storage = FIRStorage.storage()
                let storageRef = storage.reference()
                let riversRef = storageRef.child(filename)
                
                // Upload the file to the path "images/rivers.jpg"
                riversRef.put(data!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata.downloadURL()?.absoluteString
                    print(downloadURL!)
                    let data: Dictionary<String,Any> = ["username":username,"fname":fname,"lname":lname,"profilepic":downloadURL!]
                    FIRDatabase.database().reference().child("Contacts").child((user?.uid)!).setValue(data)
                    self.usernametf.text = ""
                    self.firstnametf.text = ""
                    self.lastnametf.text = ""
                    
                        self.login(username: username)
                }
                
                
            }

        }

        
            }
    
    //Login on Register
    func login(username:String)
    {
        
        FIRAuth.auth()?.signIn(withEmail: username+"@fuelchat.com", password: "123456", completion: {(user,error) in
            if error != nil {
                ProgressHUD.showError("Invalid Login")
            }
            else{
                ProgressHUD.dismiss()
                self.performSegue(withIdentifier: "movefromreg", sender: nil)
            }
        })
        
    }
    
    //To Fetch Camera Feed
    @IBAction func camerabtnclicked(_ sender: Any) {
        let imgpicker = UIImagePickerController()
        imgpicker.allowsEditing = true
        imgpicker.delegate = self
        imgpicker.sourceType = .camera
        
        self.present(imgpicker, animated: true, completion: nil)
    }
    
    //Set after edit on profile
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgtask = info[UIImagePickerControllerEditedImage] as! UIImage
        profilebtn.setImage(imgtask, for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    //If cancel btn on picker is pressed
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
        firstnametf.resignFirstResponder()
        lastnametf.becomeFirstResponder()
        }
        else if textField.tag == 2{
            lastnametf.resignFirstResponder()
            usernametf.becomeFirstResponder()
        }
        else if textField.tag == 3{
            
            if firstnametf.text == "" {
                ProgressHUD.showError("First Name Cannot Be Empty")
            }else if lastnametf.text == "" {
                ProgressHUD.showError("Last Name Cannot Be Empty")
            }
            else if usernametf.text == ""{
                ProgressHUD.showError("Username Name Cannot Be Empty")
            }
            else if (usernametf.text?.contains(" "))! {
                ProgressHUD.showError("Username Name Cannot contain spaces")
            }
            else{
                ProgressHUD.show("Signing Up...",interaction:false)
                register(fname: firstnametf.text!, lname: lastnametf.text!, avatar: profilebtn.imageView?.image,username: usernametf.text!)
                print("Registring Now")
            }

            
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
