//
//  SignupViewController.swift
//  InstagramApp
//
//  Created by Hamid Hoseini on 9/27/17.
//  Copyright © 2017 Hamid Hoseini. All rights reserved.
//

import UIKit
import Firebase


class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confPassField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage:  StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        let storage = Storage.storage().reference(forURL: "gs://instagram-e06fb.appspot.com")
        ref = Database.database().reference()
        userStorage = storage.child("users")
     
    }

    @IBAction func selectImageBtnPressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confPassField.text != "" else {
            return
        }
        
        if passwordField.text == confPassField.text {
            //FirbaseAuth.auth()?.creatUser(
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            
                            if let url = url {
                                let userInfo: [String : Any] = ["uid" : user.uid,
                                                              "full name" : self.nameField.text!,
                                                              "urlToImage" : url.absoluteString]
                                
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                
                                self.present(vc, animated: true, completion: nil)
                                
                            }
                        })
                    })
                    
                    uploadTask.resume()
                    
                }
            })
        
        } else {
            print(" password does not match!")
        }
    }
}
