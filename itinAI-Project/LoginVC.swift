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
        
        // testing GPT API
        /*
        Task {
            print("calling generateCityItinerary")
            await generateCityItinerary("", "Tokyo", ["I want to shop", "I want to eat sushi", "I want to see Tokyo Tower", "I want to go to Shibuya Crossing", "I want to go to a club"], "April 2nd", "April 5th")
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


func fetchCityInput(cityDocId: String) {

    let db = Firestore.firestore()
    
    let docRef = db.collection("Cities").document(cityDocId)
    
    // Attempt to fetch the document
    docRef.getDocument { (document, error) in
        // Error handling
        if let error = error {
            print("Error getting document: \(error.localizedDescription)")
            return
        }
        
        guard let document = document, document.exists else {
            print("Document does not exist")
            return
        }
        
        // Attempt to retrieve the 'cityName' and 'inputList' from the document
        let data = document.data()
        
        // Retrieve 'cityName' as a String
        guard let cityName = data?["cityName"] as? String else {
            print("City name not found or is not a string")
            return
        }
        
        guard let cityName = data?["cityName"] as? String,
              let inputList = data?["inputList"] as? [String],
              let startDateTimestamp = data?["startDate"] as? Timestamp,
              let endDateTimestamp = data?["endDate"] as? Timestamp else {
            print("One or more fields not found or is not in the expected format")
            return
        }
        
        // Convert Firestore Timestamps to Date
        let startDate = startDateTimestamp.dateValue()
        let endDate = endDateTimestamp.dateValue()
        
        print("Successfully retrieved city data")
        print("City Name: \(cityName)")
        print("Input List: \(inputList)")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)

        
        Task {
            print("calling generateCityItinerary")
            await generateCityItinerary(cityDocId, cityName, inputList, startDateString, endDateString)
        }
    }
}

// calls GPT API to generate itinerary and save to Firestore

func generateCityItinerary(_ cityDocId: String, _ cityName: String, _ inputList: [String], _ startDate: String, _ endDate: String) async {
    
    let openAI = OpenAI(apiToken: "hidden")
    
    let prompt = """
    Generate a detailed travel itinerary for a trip to \(cityName), from \(startDate) to \(endDate). The response should only include the itinerary details, without any additional text. Utilize custom separators to clearly distinguish between different parts of the itinerary. For each day, use '###Day:X###' as a marker where X is the day number, followed by '###Date:Y###' for the date, and use '---' to separate individual itinerary items. Ensure the itinerary is practical, considering travel time between locations, and aligns with the user's interests.

    Example of the desired format:

    ###Day:1### ###Date:April 2nd### --- 9:00 AM: Start the day at the Meiji Shrine, a serene escape in the heart of Tokyo, surrounded by a lush forest. --- 11:00 AM: Head over to the bustling Harajuku for a glimpse into Tokyo's youth fashion and pop culture. --- 1:00 PM: Visit the Shibuya Crossing, the world's busiest pedestrian crossing, and snap some iconic photos. --- 5:00 PM: End your day with a visit to Tokyo Tower for panoramic views of the city as the sun sets.

    Please create a similar itinerary, ensuring each day offers a unique and enriching experience and make sure to consider all of the user's preferences.
    """
    
    // User preferences are considered after the initial prompt, each as a separate message
    var messages: [ChatQuery.ChatCompletionMessageParam] = [ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt)!]
    
    messages.append(contentsOf: inputList.map {ChatQuery.ChatCompletionMessageParam(role: .user, content: $0)! })
    
    let query = ChatQuery(messages: messages, model: .gpt3_5Turbo)
    
    do {
        print("begin querying GPT API")
        let result = try await openAI.chats(query: query)
        
        print("Itinerary full result:\n \(result)")
        for choice in result.choices {
            DispatchQueue.main.async {
                print("content: \(choice.message.content)")
                
                // save to Firestore [itineraryDays]
            }
        }
    } catch {
        // Handle errors here
        print("An error occurred: \(error.localizedDescription)")
    }
}

func parseItinerary(response: String) -> [ItineraryDay] {
    let daySections = response.components(separatedBy: "###Day:")
    var itineraryDays: [ItineraryDay] = []

    for daySection in daySections where !daySection.isEmpty {
        let components = daySection.components(separatedBy: "###Date:")
        let dayNumber = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let rest = components[1].split(separator: "###", maxSplits: 1, omittingEmptySubsequences: true)[0]
        let dateAndContent = rest.split(separator: "---", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        let date = dateAndContent[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let content = dateAndContent[1].split(separator: "---").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        itineraryDays.append(ItineraryDay(dayNumber: dayNumber, date: date, content: content))
    }

    return itineraryDays
}

class ItineraryDay {
    var dayNumber: String
    var date: String
    var content: [String]

    init(dayNumber: String, date: String, content: [String]) {
        self.dayNumber = dayNumber
        self.date = date
        self.content = content
    }
}

