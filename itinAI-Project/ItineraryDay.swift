//
//  ItineraryDay.swift
//  itinAI-Project
//
//  Created by Eric Yang on 4/8/24.
//

import Foundation

/*class ItineraryDay {
    var dayNumber: String
    var date: String
    var content: [String]

    init(dayNumber: String, date: String, content: [String]) {
        self.dayNumber = dayNumber
        self.date = date
        self.content = content
    }
}*/


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
