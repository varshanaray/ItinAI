// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let darkModeValue = UserDefaults.standard.object(forKey: "darkMode") as? Int, darkModeValue == 1 {
            logoImageView.image = UIImage(named: "logoDarkItinAI")
            logoImageView.alpha = 1.0
            // dark mode is on
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            logoImageView.alpha = 0.0
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
        emailField.backgroundColor = UIColor(named: "LoginFields")
        passwordField.backgroundColor = UIColor(named: "LoginFields")
        nameField.backgroundColor = UIColor(named: "LoginFields")
        passwordField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener()
        {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "signupSegue", sender: self)
                self.passwordField.text = nil
                self.nameField.text = nil
                self.emailField.text = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let darkModeValue = UserDefaults.standard.object(forKey: "darkMode") as? Int, darkModeValue == 1 {
            logoImageView.image = UIImage(named: "logoDarkItinAI")
            logoImageView.alpha = 1.0
            // dark mode is on
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            logoImageView.alpha = 0.0
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
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
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            let db = Firestore.firestore()
            db.collection("Users").document(user.uid).setData([
                 "name": displayName,
                 "profileImageURL": "",
                 "email": email
             ]) { err in
                 if let err = err {
                     print("Error writing document: \(err)")
                 } else {
                     print("Document successfully written!")
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
