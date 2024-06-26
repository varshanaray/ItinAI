// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

// Class to create an announcement object.
class Announcements {
    
    var user: String
    var userImageURL: String
    var subject: String
    var message: String
    var timestamp: Date
    
    init(user: String, userImageURL: String, subject: String, message: String, timestamp: Date) {
        self.user = user
        self.userImageURL = userImageURL
        self.subject = subject
        self.message = message
        self.timestamp = timestamp
    }
}
