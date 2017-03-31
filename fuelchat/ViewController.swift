//
//  ViewController.swift
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
class ViewController: UIViewController,UITextFieldDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var usernametf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
            if FIRAuth.auth()?.currentUser != nil{
            self.performSegue(withIdentifier: "movefromlogin", sender: nil)
        }
        
    //set textfield delegate to resignFirstResponder Functional
        usernametf.delegate = self
        
    }

    //Segue to signup
    @IBAction func signupclicked(_ sender: Any) {
        performSegue(withIdentifier: "movetosignup", sender: nil)
    }
    
    @IBAction func loginbtnclicked(_ sender: Any) {
       if usernametf.text != ""{
        ProgressHUD.show("Logging in...",interaction:false)
        login(username: usernametf.text!)
        }
       else{
        ProgressHUD.showError("Username must be set")
        }
    }
    
    func login(username:String)
    {
        
        FIRAuth.auth()?.signIn(withEmail: username+"@fuelchat.com", password: "123456", completion: {(user,error) in
            if error != nil {
                ProgressHUD.showError("Invalid Login")
            }
            else{
                self.usernametf.text = ""
                ProgressHUD.dismiss()
                self.performSegue(withIdentifier: "movefromlogin", sender: nil)
            }
        })
        
}
    
    
    //to close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernametf.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(navigationController!.viewControllers.count > 1){
            return true
        }
        return false
    }


}

