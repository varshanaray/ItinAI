//
//  SignUpVC.swift
//  itinAI-Project
//
//  Created by Varsha Narayanan on 3/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        passwordField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        nameField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
    
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        // Check for empty fields
        guard let email = emailField.text, !email.isEmpty else {
                displayErrorAlert(message: "Please enter your email.")
                return
            }
            
        guard let realName = nameField.text, !realName.isEmpty else {
            displayErrorAlert(message: "Please enter your real name.")
            return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            displayErrorAlert(message: "Please enter your password.")
            return
        }
        
        // Check for email format
        if !isValidEmail(email) {
            displayErrorAlert(message: "Please enter an email address in valid format.")
            return
        }
        
        // Check for password length
        if !isValidPassword(password) {
            displayErrorAlert(message: "Please enter a password of 6 characters or more.")
            return
        }
        
        // user authentication
        createUser(email: emailField.text!, password: passwordField.text!, displayName: nameField.text!)
        
    }
    
    func createUser(email: String, password: String, displayName: String) {
        print("createUser was called!")
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            print("got past auth()")
            /*
             Firestore code
             
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "realName": realName
            ]) { error in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
             */
            var newUser = User(displayName: displayName, groupList: [], profileImageUrl: "")
            
            if (currentUser == nil) {
                print("unexpected error: current User did not get initialized")
            } else {
                //self.performSegue(withIdentifier: "signupToHomeSegue", sender: self)
                
                if let homeNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavController") as? UINavigationController {
                    homeNavigationController.modalPresentationStyle = .fullScreen // Set full screen
                    self.present(homeNavigationController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func displayErrorAlert(message: String) {
        
        let controller = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(controller, animated: true)
    }

}
