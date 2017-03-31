//
//  ChatViewController.swift
//  fuelchat
//
//  Created by Shripal Jain on 29/03/17.
//  Copyright © 2017 Shripal Jain. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private var messages = [JSQMessage]()
    
    var imgtask:UIImage!
    var receiverId:String!
    var receiverDisplayName:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        fetchchat()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let BubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        if message.senderId==senderId{
        return BubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
        }
        else{
            return BubbleFactory?.incomingMessagesBubbleImage(with: UIColor.green)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"avatarPlaceholder"), diameter: 30)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        //let msg = messages[indexPath.item]
    }
    //END Collection View Functions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        let interval = NSDate().timeIntervalSince1970
        let data: Dictionary<String,Any> = ["senderId":senderId,"senderName":senderDisplayName,"receiverId":receiverId,"receiverDisplayName":receiverDisplayName, "text":text, "interval":"\(interval)","media":""]
        FIRDatabase.database().reference().child("Messages").childByAutoId().setValue(data);
        //This empty text
        
        finishSendingMessage()
        self.view.endEditing(true)
    }
    
    
    //For Images
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alert = UIAlertController(title: "Media Options", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photos", style: .default , handler:{ (UIAlertAction)in
            let imgpicker = UIImagePickerController()
            imgpicker.allowsEditing = true
            imgpicker.delegate = self
            imgpicker.sourceType = .photoLibrary
            
            self.present(imgpicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            let imgpicker = UIImagePickerController()
            imgpicker.allowsEditing = true
            imgpicker.delegate = self
            imgpicker.sourceType = .camera
            
            self.present(imgpicker, animated: true, completion: nil)

        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })

        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgtask = info[UIImagePickerControllerEditedImage] as? UIImage
        ProgressHUD.show("Uploading Media...",interaction:false)
        let data = UIImageJPEGRepresentation(imgtask, 0.3)
        let filename = "\(NSDate().timeIntervalSince1970)\(senderId).jpeg"

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
            let interval = NSDate().timeIntervalSince1970
            let data: Dictionary<String,Any> = ["senderId": self.senderId,"senderName": self.senderDisplayName,"receiverId": self.receiverId,"receiverDisplayName":self.receiverDisplayName, "text":"", "interval":"\(interval)","media":downloadURL!]
            FIRDatabase.database().reference().child("Messages").childByAutoId().setValue(data);

            
        }
        
        

        
        
        
        picker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }

    //If cancel btn on picker is pressed
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @IBAction func gotousers(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchchat(){
        
    FIRDatabase.database().reference().child("Messages").observe(.childAdded, with: {(snapshot:FIRDataSnapshot) in
            let value = snapshot.value as? NSDictionary
            let sId = value?["senderId"] as? String ?? ""
            let dName = value?["senderDisplayName"] as? String ?? ""
            let txt = value?["text"] as? String ?? ""
            let rId = value?["receiverId"] as? String ?? ""
            let murl = value?["media"] as? String ?? ""
        if(txt != ""){
        if(sId == self.receiverId){
            if(rId == self.senderId){
                self.messages.append(JSQMessage(senderId: sId, displayName: dName, text: txt))
            }
        }
        else if(sId == self.senderId){
            if(rId == self.receiverId){
                self.messages.append(JSQMessage(senderId: sId, displayName: dName, text: txt))
            }
            }
        }else{
            let tempImageView = UIImageView(image: nil)
            tempImageView.sd_setImage(with: URL(string: murl), completed: {
                (image, error, cacheType, url) in
                let img = JSQPhotoMediaItem(image: tempImageView.image)
                
                if(sId == self.receiverId){
                    if(rId == self.senderId){
                        self.messages.append(JSQMessage(senderId: sId, displayName: dName, media: img))
                        self.collectionView.reloadData()
                        ProgressHUD.dismiss()

                    }
                }
                else if(sId == self.senderId){
                    if(rId == self.receiverId){
                        self.messages.append(JSQMessage(senderId: sId, displayName: dName, media: img))
                        self.collectionView.reloadData()
                        ProgressHUD.dismiss()
                    }
                }
            })
            
        }
        
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }, withCancel: {(error) in
            print("Error Fetching Data")
            
        })

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
