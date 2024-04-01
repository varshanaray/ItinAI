// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseAuth
import FirebaseFirestore
import OpenAI

class LoginVC: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        passwordField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        
        /*
        Task {
            print("testing query")
            await queryItinerary()
        }*/
        
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
            
            
            /*
            if let homeNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavController") as? UINavigationController {
                homeNavigationController.modalPresentationStyle = .fullScreen // Set full screen
                self.present(homeNavigationController, animated: true, completion: nil)
            }*/
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


func queryItinerary() async {
    let openAI = OpenAI(apiToken: "hidden")

    let prompt = """
    Generate a detailed travel itinerary for a 3-day trip to Tokyo. Please format the itinerary as follows:

    For each day, bold the day number and provide the beginning and end dates in a subtitle format. Then, list the activities with specific times and detailed descriptions. Ensure the itinerary is practical, considering travel time between locations.

    Example of the desired format:

    **Day 1**
    *Subtitle: date 1 to date 2*

    9:00 AM: Start the day at the Meiji Shrine, a serene escape in the heart of Tokyo, surrounded by a lush forest.
    11:00 AM: Head over to the bustling Harajuku for a glimpse into Tokyo's youth fashion and pop culture.
    1:00 PM: Visit the Shibuya Crossing, the world's busiest pedestrian crossing, and snap some iconic photos.
    3:00 PM: Explore the trendy shops and cafes in Omotesando, often referred to as Tokyo's Champs-Élysées.
    5:00 PM: End your day with a visit to Tokyo Tower for panoramic views of the city as the sun sets.

    Please create a similar itinerary, ensuring each day offers a unique and enriching experience.
    """
    
    let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt3_5Turbo)
    
    do {
        let result = try await openAI.chats(query: query)
        
        print("Itinerary: \(result)")
        for choice in result.choices {
                DispatchQueue.main.async {
                    print("content: \(choice.message.content)")
                }
            }
    } catch {
        // Handle errors here
        print("An error occurred: \(error)")
    }
}

