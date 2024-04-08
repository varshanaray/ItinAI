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
        
        signUpButton.setTitleColor(UIColor.black, for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 16)
        // testing GPT API
        /*
        Task {
            print("calling generateCityItinerary")
            await generateCityItinerary("4Mn1JSpDubai", "Dubai", ["I want to shop", "I want to eat sushi", "I want to see Tokyo Tower", "I want to go to Shibuya Crossing", "I want to go to a club"], "April 2nd", "April 5th")
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
              let inputList = data?["inputList"] as? [String], //city responses
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
        Generate a detailed travel itinerary for a trip to \(cityName), from \(startDate) to \(endDate). The response should only include the itinerary details, without any additional text. Utilize custom separators to clearly distinguish between different parts of the itinerary. For each day, prefix the day number with '###Day:', followed by '###Date:' for the date. Each itinerary item should be prefixed with '###Content:'. Do not include any new line characters, leav everything in one single line so it's easily parsable. Ensure the itinerary is practical, considering travel time between locations, and aligns with the user's interests.

        Example of the desired format:

        ###Day:1 ###Date:April 2nd ###Content:9:00 AM: Start your day with a visit to the iconic Tsukiji Fish Market to experience the bustling atmosphere and enjoy some fresh seafood. ###Content:12:00 PM: Head to the upscale Ginza district for high-end shopping at luxury boutiques and department stores. ###Content:3:00 PM: Indulge in a sushi feast at a renowned sushi restaurant in Ginza to satisfy your craving for fresh and delicious sushi. ###Content:6:00 PM: Make your way to Tokyo Tower to marvel at the city skyline from this iconic landmark as it lights up in the evening.

        ###Day:2 ###Date:April 3rd ###Content:10:00 AM: Explore the vibrant Takeshita Street in Harajuku for quirky fashion finds and unique souvenirs. ###Content:1:00 PM: Have a sushi lunch at one of the local sushi joints near Harajuku to continue enjoying delicious sushi. ###Content:4:00 PM: Visit the Meiji Shrine for a peaceful stroll through the serene forest and to learn about Japanese culture and history. ###Content:8:00 PM: Experience Tokyo's nightlife scene at a popular club in Shibuya to dance the night away and enjoy the electric atmosphere.
        
        Recall to do this for however many days from \(startDate) to \(endDate). And note that we do not need to strictly visit 4 places per day.

        Please create a similar itinerary, ensuring each day offers a unique and enriching experience and make sure to consider all of the user's preferences. Translate the entire itinerary to spanish but remember to retain the formatting.
        """

    
    // User preferences are considered after the initial prompt, each as a separate message
    var messages: [ChatQuery.ChatCompletionMessageParam] = [ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt)!]
    
    messages.append(contentsOf: inputList.map {ChatQuery.ChatCompletionMessageParam(role: .user, content: $0)! })
    
    let query = ChatQuery(messages: messages, model: .gpt3_5Turbo)
    
    do {
        print("begin querying GPT API")
        let result = try await openAI.chats(query: query)
        
        print("Itinerary full result:\n \(result)")
        print("\n\n\n")
        for choice in result.choices {
            DispatchQueue.main.async {
                //print("full content: \(choice.message.content)")
                
                print("calling parseItinerary")
                parseItinerary(cityDocId: cityDocId, response: "\(choice.message.content)")
                
            }
        }
    } catch {
        // Handle errors here
        print("An error occurred: \(error.localizedDescription)")
    }
}

func parseItinerary(cityDocId: String, response: String) {
    let modifiedResponse = response.hasSuffix("\"))") ? String(response.dropLast(3)) : response
    let parts = modifiedResponse.components(separatedBy: "###").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    let db = Firestore.firestore()
    var dayNumber = ""
    var date = ""
    var content: [String] = []

    for part in parts {
        let trimmedPart = part.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPart.starts(with: "Day:") {
            if !content.isEmpty {
                // Upload the accumulated content for the previous day to Firestore before starting a new day
                uploadDayItineraryToFirestore(db: db, cityDocId: cityDocId, dayNumber: dayNumber, date: date, content: content)
                content = [] // Reset content for the new day
            }
            dayNumber = String(trimmedPart.dropFirst("Day:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if trimmedPart.starts(with: "Date:") {
            date = String(trimmedPart.dropFirst("Date:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if trimmedPart.starts(with: "Content:") {
            let contentItem = String(trimmedPart.dropFirst("Content:".count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\n", with: "")
                .replacingOccurrences(of: "\\", with: "")
            content.append(contentItem)
        }
    }

    // Don't forget to upload the last day's content to Firestore
    if !content.isEmpty {
        uploadDayItineraryToFirestore(db: db, cityDocId: cityDocId, dayNumber: dayNumber, date: date, content: content)
    }
}

// Helper function to upload a single day's itinerary to Firestore
func uploadDayItineraryToFirestore(db: Firestore, cityDocId: String, dayNumber: String, date: String, content: [String]) {
    let docRef = db.collection("Cities").document(cityDocId).collection("ItineraryDays").document("Day\(dayNumber)")
    docRef.setData([
        "dayNumber": dayNumber,
        "date": date,
        "content": content
    ]) { err in
        if let err = err {
            print("Error adding document: \(err)")
        } else {
            print("Document successfully added for Day \(dayNumber)!")
        }
    }
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
