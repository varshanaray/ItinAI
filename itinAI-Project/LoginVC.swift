//  ViewController.swift

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        passwordField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
    }

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
            // temporary implementation: check email against globalUserList to retrieve info
            currentUser = nil
            for user in globalUserList {
                if user.email == email {
                    currentUser = user
                    print("found the user")
                    break
                }
            }
            if currentUser == nil { // temporary implementation: if user did not create account locally
                print("user was not created locally, therefore initialized new user")
                var user = User(email: email, displayName: "Temporarily Unavailable", groupList: [], profileImageUrl: "")
                globalUserList.append(user)
                currentUser = user
            }
            if let homeNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavController") as? UINavigationController {
                homeNavigationController.modalPresentationStyle = .fullScreen // Set full screen
                self.present(homeNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    /* Function to handle and interpret Firebase Auth errors
    func handleLoginError(error: Error) {
        let nsError = error as NSError
        guard let errorCode = AuthErrorCode(rawValue: AuthErrorCode.Code(rawValue: nsError.code) ?? "unknown error") else {
            displayErrorAlert(message: "An unexpected error occurred. Please try again.")
            return
        }
        
        var errorMessage: String
        
        switch errorCode {
        case .userNotFound, .wrongPassword:
            errorMessage = "Invalid email or password. Please try again."
        case .userDisabled:
            errorMessage = "This account has been disabled. Please contact support."
        case .networkError:
            errorMessage = "Check your internet connection and try again."
        // You can handle more specific errors as needed
        default:
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        displayErrorAlert(message: errorMessage)
    } */

    func displayErrorAlert(message: String) {
        let controller = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
}

func isValidEmail(_ email: String) -> Bool {
   let emailRegEx =
       "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
   let emailPred = NSPredicate(format:"SELF MATCHES %@",
       emailRegEx)
   return emailPred.evaluate(with: email)
}
  
func isValidPassword(_ password: String) -> Bool {
   let minPasswordLength = 6
   return password.count >= minPasswordLength
}
