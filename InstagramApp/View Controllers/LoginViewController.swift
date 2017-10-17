//
//  LoginViewController.swift
//  InstagramApp
//
//  Created by Hamid Hoseini on 9/29/17.
//  Copyright © 2017 Hamid Hoseini. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else {return}
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
}
