// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginVC: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
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
        passwordField.isSecureTextEntry = true
        signUpButton.setTitleColor(UIColor.black, for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        Auth.auth().addStateDidChangeListener()
        {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.passwordField.text = nil
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
    
    // Authenticate user login info and take them to HomePageVC if existing in Firestore
    @IBAction func loginButtonPressed(_ sender: Any) {
        // Check for empty fields
        guard let email = emailField.text, !email.isEmpty else {
            displayErrorAlert(message: "Please enter your email.")
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
        login(email: email, password: password)
    }
    
    func login(email: String, password: String) {
        print("login was called")
        // Attempt to authenticate login
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle errors from Firebase Authentication
                self.displayErrorAlert(message: error.localizedDescription)
                return
            }
            // login successful
        }
    }

    func displayErrorAlert(message: String) {
        let controller = UIAlertController (
            title: "Error",
            message: message,
            preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
    }
}

// validates email input in terms of formatting
func isValidEmail(_ email: String) -> Bool {
   let emailRegEx =
       "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
   let emailPred = NSPredicate(format:"SELF MATCHES %@",
       emailRegEx)
   return emailPred.evaluate(with: email)
}

// validates password input in terms of formatting
func isValidPassword(_ password: String) -> Bool {
   let minPasswordLength = 6
   return password.count >= minPasswordLength
}
