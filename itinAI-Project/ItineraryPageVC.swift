//
//  itineraryPageVC.swift
//  itinAI-Project
//
//  Created by Eric Yang on 4/1/24.
//

import UIKit
import FirebaseFirestore
import OpenAI

class ItineraryPageVC: UIViewController {

    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainContentView: UIView!
    
    var cityId: String?
    var cityName: String?
    
    var itineraryDays: [ItineraryDay] = [] // Populate this array from Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = cityName

        fetchItineraryData (cityDocId: cityId!){ [weak self] in
            self?.populateScrollView()
        }
    }
    
    func fetchItineraryData(cityDocId: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("Cities").document(cityDocId).collection("ItineraryDays").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                self.itineraryDays = querySnapshot?.documents.compactMap { docSnapshot -> ItineraryDay? in
                    let data = docSnapshot.data()
                    return ItineraryDay(documentData: data)
                } ?? []
                completion()
            }
        }
    }

    
    func populateScrollView() {
        print("populating the scroll view")
        var yOffset: CGFloat = 10
        for day in itineraryDays {
            let block = createItineraryBlock(for: day, yOffset: yOffset)
            scrollView.addSubview(block)
            yOffset += block.frame.height + 10 // Adjust spacing between blocks
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yOffset)
    }
    
    func createItineraryBlock(for day: ItineraryDay, yOffset: CGFloat) -> UIView {
        print("creating itinerary block UIView")
        let blockView = UIView(frame: CGRect(x: 0, y: yOffset, width: scrollView.frame.width, height: 200)) // Adjust height as needed
        
        let dayLabel = UILabel(frame: CGRect(x: 10, y: 10, width: blockView.frame.width - 20, height: 20))
        dayLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dayLabel.text = "Day \(day.dayNumber)"
        blockView.addSubview(dayLabel)
        
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 40, width: blockView.frame.width - 20, height: 20))
        dateLabel.text = day.date
        blockView.addSubview(dateLabel)
        
        let contentView = UITextView(frame: CGRect(x: 10, y: 70, width: blockView.frame.width - 20, height: 120))
        contentView.text = day.content.joined(separator: "\n")
        contentView.isEditable = true // Adjust based on your requirements
        blockView.addSubview(contentView)
        
        return blockView
    }
    
}


func fetchSurveyResponsesAndGenerate(cityDocId: String) async -> Bool {
        let db = Firestore.firestore()
        let docRef = db.collection("Cities").document(cityDocId)
        
        do {
            let document = try await docRef.getDocument()
            guard let data = document.data(), document.exists else {
                print("Document does not exist")
                return false
            }
            
            guard let cityName = data["cityName"] as? String,
                  let surveyResponses = data["surveyResponses"] as? [String],
                  let startDateTimestamp = data["startDate"] as? Timestamp,
                  let endDateTimestamp = data["endDate"] as? Timestamp else {
                print("One or more fields not found or is not in the expected format")
                return false
            }

            // Convert Timestamps to Date and then to String
            let startDate = startDateTimestamp.dateValue()
            let endDate = endDateTimestamp.dateValue()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            // Now call your generateCityItinerary function
            await generateCityItinerary(cityDocId, cityName, surveyResponses, startDateString, endDateString)
            
            return true
        } catch {
            print("Firestore fetch error: \(error)")
            return false
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

