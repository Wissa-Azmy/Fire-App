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
import FirebaseFirestore

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var verificationCodeTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var statusTxtLbl: UILabel!
    
    var authUI: FUIAuth?
    var DBReference: DatabaseReference!
    var StorageReference: StorageReference!
    var firestore: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusTxtLbl.isHidden = true
        
        configureAuthUI()
        
        DBReference = Database.database().reference()
        StorageReference = Storage.storage().reference()
        firestore = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }


    @IBAction func createUserBtnTapped(_ sender: UIButton) {
//        createUserUsingFirebaseAuth()
        print("\n\n\n Create Button Tapped.")
        createUserUsingPhoneAuth()
    }
    
    // Verify user phone number
    @IBAction func verifyBtnTapped(_ sender: UIButton) {
        if let code = verificationCodeTxtField.text, code != "" {
            if let UserCredential = createUserCredentials(verificationCode: code) {
                signInUser(withCredential: UserCredential)
            }
        }
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
//        loginUsingFirebaseAuth()
        loginUsingFirebaseAuthUI()
    }
    
    
    @IBAction func fireBtnTapped(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            statusTxtLbl.isHidden = false
            
            createObjectUsingFirebaseDatabase()
            updateFBDatabaseData()
            deleteDatafromFBDatabase()
            
            uploadDataToFirebaseCloudStorage()
            uploadFileToFirebaseCloudStorage()
            retrieveDataFromFBCloudStorage()
            retrieveFileURLFromFBCloudStorage()
            
            addDataToFirestore()
            retrieveDataFromFirestore()
            retrieveDataFromFirestoreWithCondition()
            updateDocDataInFirestore()
            deleteDataFromFirestore()
        } else {
            print("Login First to run Firebase methods.")
        }
    }
    
    
    fileprivate func isUserAuthorized() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
}





// MARK: - Firebase Authentication
extension ViewController: FUIAuthDelegate {
    
    func configureAuthUI() {
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth(), FUIEmailAuth()]
        authUI?.providers = providers
    }
    
    func createUserUsingFirebaseAuth() {
        if let email = emailTxtField.text, let pass = passwordTxtField.text {
            Auth.auth().createUser(withEmail: email, password: pass) { (response, error) in
                print(response?.user.email ?? "User was not created.")
                print(response?.user.uid ?? "No user id found.")
            }
        } else {
            print("Email or Password is missing.")
        }
    }
    
    func loginUsingFirebaseAuthUI() {
        if Auth.auth().currentUser == nil {
            if let authVC = authUI?.authViewController() {
                present(authVC, animated: true)
            }
        } else {
            do {
                try Auth.auth().signOut()
                self.loginBtn.setTitle("Login", for: .normal)
            } catch {}
            
        }
    }
    
    func loginUsingFirebaseAuth() {
        if Auth.auth().currentUser == nil {
            if let email = emailTxtField.text, let pass = passwordTxtField.text {
                Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                    if error == nil {
                        self.loginBtn.setTitle("Log Out", for: .normal)
                    }
                }
            }
        } else {
            do {
                try Auth.auth().signOut()
                self.loginBtn.setTitle("Login", for: .normal)
            } catch {}
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error == nil {
            loginBtn.setTitle("Log out", for: .normal)
        }
    }
}



// MARK: - Phone Authentication
extension ViewController {
    fileprivate func createUserUsingPhoneAuth() {
        if let phoneNumber = phoneTxtField.text, phoneNumber != "" {
            PhoneAuthProvider.provider().verifyPhoneNumber("+201285579610", uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print("\n\n\n\n\n Firebase Error: ")
                    print(error.localizedDescription)
                    print("\n\n\n\n")
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                // ...
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
        }
        
    }
    
    // Create a FIRPhoneAuthCredential object from the verification code and verification ID
    fileprivate func createUserCredentials(verificationCode: String) -> PhoneAuthCredential? {
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return nil}
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        return credential
    }
    
    fileprivate func signInUser(withCredential credential: PhoneAuthCredential) {
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User is signed in
            print("Voilla, User is Signed In.")
        }
    }
}



// MARK: - Firebase Database
extension ViewController {
    func createObjectUsingFirebaseDatabase() {
        DBReference.child("games").child("2").setValue(["name": "second", "score": 15])
    }
    
    func updateFBDatabaseData() {
        DBReference.child("games").child("1").child("name").setValue("new name")
        DBReference.child("games/1/name").setValue("new name")
        DBReference.child("games/1").setValue(["name": "updated name", "score": 10])
        let childUpdates = ["games/1/name": "wissa", "games/1/score": nil] as [String: Any]
        DBReference.updateChildValues(childUpdates)
    }
    
    func deleteDatafromFBDatabase() {
        DBReference.child("games/1/name").setValue(nil)
        DBReference.child("games/2/name").removeValue()
    }
}



// MARK: - Firebase Cloud Storage
extension ViewController {
    private func uploadDataToFirebaseCloudStorage() {
        let gamekey = DBReference.child("games/2").key  // Get object id
        let filename = "\(gamekey!).png"
        let fileReference = StorageReference.child(filename)
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
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
    
    private func uploadFileToFirebaseCloudStorage() {
        let gamekey = DBReference.child("games/1").key  // Get object id
        let filename = "\(gamekey!).png"
        let fileReference = StorageReference.child(filename)
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        // Upload a file using its URL whithout loading it to memory
        let fileURL = Bundle.main.url(forResource: "Moharebs", withExtension: "jpg")
        
        fileReference.putFile(from: fileURL!, metadata: meta) { (meta, error) in
            if error == nil {
                self.DBReference.child("games/1/image").setValue(filename)
            }
        }
    }
    
    private func retrieveFileURLFromFBCloudStorage() {
        DBReference.child("games/1/image").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                let fileInstance = self.StorageReference.child(value)
                fileInstance.downloadURL(completion: { (url, error) in
                    if let urlString = url?.absoluteString {
                        print(urlString)
                    }
                })
            }
        }
    }
    
    private func retrieveDataFromFBCloudStorage() {
        DBReference.child("games/1/image").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                let fileInstance = self.StorageReference.child(value)
                fileInstance.getData(maxSize: 10000000, completion: { (data, error) in
                    if error == nil {
                        let img = UIImage(data: data!)
                        DispatchQueue.main.async {
                            let imageView = UIImageView(frame: self.view.frame)
                            imageView.image = img
                            self.view.addSubview(imageView)
                        }
                    } else {
                        print(error?.localizedDescription ?? "")
                    }
                })
            }
        }
    }
    
    private func deleteFileFromFBCloudStorage() {
        DBReference.child("games/1/image").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? String {
                let fileInstance = self.StorageReference.child(value)
                fileInstance.delete(completion: { (error) in
                    // handle error
                })
            }
        }
    }
    
}



// MARK: - Firebase Firestore
extension ViewController {
    fileprivate func addDataToFirestore() {
        firestore.collection("winner").document("100").setData(["game": 1, "user": "Wissa"])
        firestore.collection("winner").addDocument(data:["game": 2, "user": "Farhat"])
        let doc = firestore.collection("winner").document()
        doc.setData(["game": 3, "user": "Azmy"])
    }
    
    fileprivate func retrieveDataFromFirestore() {
        if isUserAuthorized() {
            firestore.collection("winner").getDocuments { (snapshot, error) in
                if error == nil {
                    for doc in (snapshot?.documents)! {
                        print(doc.data())
                    }
                }
            }
        }
    }
    
    fileprivate func retrieveDataFromFirestoreWithCondition() {
        if isUserAuthorized() {
            firestore.collection("winner")
                .whereField("game", isEqualTo: 2)
                .getDocuments { (snapshot, error) in
                if error == nil {
                    for doc in (snapshot?.documents)! {
                        print(doc.data())
                    }
                }
            }
        }
    }
    
    fileprivate func updateDocDataInFirestore(docId: String = "100") {
        // Get the reference of the document to be updated
        let doc = firestore.collection("winner").document(docId)
        
        // Replace Document data with new fields (destructive update)
        doc.updateData(["game": 1, "user": "wissa"])
        
        // Add a new scores field with a dictionary value to the doc (merge update)
        doc.setData(["scores": ["top": 30, "low": 3]], merge: true)
        
        // Update dictionary data using the dot(.) notation
        doc.updateData(["scores.top": 35])
    }
    
    // Hint: deleting collections is not possible through mobile api
    fileprivate func deleteDataFromFirestore() {
        let doc = firestore.collection("winner").document("100")
        
        // Delete a single field of a document
        doc.updateData(["scores": FieldValue.delete()])
        
        // Delete a full document
        doc.delete()
        
        // Bulk delete a group of documents
        firestore.collection("winner").getDocuments { (snapshot, error) in
            if error == nil {
                snapshot?.documents.forEach({$0.reference.delete()})
            }
        }
    }
}
