// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

struct ItineraryDay {
    var dayNumber: String
    var date: String
    var content: [String]
    
    // Helper to initialize from Firestore document data
    init?(documentData: [String: Any]) {
        guard let dayNumber = documentData["dayNumber"] as? String,
              let date = documentData["date"] as? String,
              let content = documentData["content"] as? [String] else { return nil }
        self.dayNumber = dayNumber
        self.date = date
        self.content = content
    }
}
