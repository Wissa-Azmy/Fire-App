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
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var authUI: FUIAuth?
    var DBReference: DatabaseReference!
    var StorageReference: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIEmailAuth()]
        
        authUI?.providers = providers
        
        DBReference = Database.database().reference()
        StorageReference = Storage.storage().reference()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if Auth.auth().currentUser != nil {
            DBReference.child("games").child("2").setValue(["name": "second", "score": 15])
            // Updating db values
//            DBReference.child("games").child("1").child("name").setValue("new name")
//            DBReference.child("games/1/name").setValue("new name")
//            DBReference.child("games/1").setValue(["name": "updated name", "score": 10])
//            let childUpdates = ["games/1/name": "updated name", "games/1/score": nil] as [String: Any]
//            DBReference.updateChildValues(childUpdates)
            
            // Deleting a value
//            DBReference.child("games/1/name").setValue(nil)
//            DBReference.child("games/1/name").removeValue()
        }
    }
    
    private func uploadDataToFirebaseCloudStorage(){
        let gamekey = DBReference.child("games/2").key  // Get object id
        let filename = "\(gamekey!).png"
        let fileReference = StorageReference.child(filename)
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        // Upload a file using its URL whithout loading it to memory
//        let fileURL = Bundle.main.url(forResource: "Moharebs", withExtension: "jpg")
//
//        fileReference.putFile(from: fileURL!, metadata: meta) { (meta, error) in
//            if error == nil {
//                self.DBReference.child("games/1/image").setValue(filename)
//            }
//        }
        
        // Uploading DataFile after loading its data to memory
        if let img = UIImage(named: "Steve.jpg") {
            let pngImg = img.pngData()
            fileReference.putData(pngImg!, metadata: meta) { (meta, error) in
                if error == nil {
                    self.DBReference.child("games/2/image").setValue(filename)
                }
            }
        }
    }


    @IBAction func createUserBtnTapped(_ sender: UIButton) {
        
        uploadDataToFirebaseCloudStorage()
        
//        if let email = emailTxtField.text, let pass = passwordTxtField.text {
//            Auth.auth().createUser(withEmail: email, password: pass) { (response, error) in
//                print(response?.user.email ?? "User was not created.")
//                print(response?.user.uid ?? "No user id found.")
//            }
//        }
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
