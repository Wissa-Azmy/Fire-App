//
//  ViewController.swift
//  Fire App
//
//  Created by Wissa Azmy on 5/6/19.
//  Copyright © 2019 Wissa Azmy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI


class ViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var authUI: FUIAuth?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIEmailAuth()]
        
        authUI?.providers = providers
    }


    @IBAction func createUserBtnTapped(_ sender: UIButton) {
        if let email = emailTxtField.text, let pass = passwordTxtField.text {
            Auth.auth().createUser(withEmail: email, password: pass) { (response, error) in
                print(response?.user.email ?? "User was not created.")
                print(response?.user.uid ?? "No user id found.")
            }
        }
    }
    
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            if let authVC = authUI?.authViewController() {
                present(authVC, animated: true)
            }
//            if let email = emailTxtField.text, let pass = passwordTxtField.text {
//                Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
//                    if error == nil {
//                        self.loginBtn.setTitle("Log Out", for: .normal)
//                    }
//                }
//            }
        } else {
            do {
                try Auth.auth().signOut()
                self.loginBtn.setTitle("Login", for: .normal)
            } catch {}
            
        }
    }
    
}

extension ViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error == nil {
            loginBtn.setTitle("Log out", for: .normal)
        }
    }
}
