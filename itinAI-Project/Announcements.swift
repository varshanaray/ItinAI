import Foundation

// Class to create an announcement object.
class Announcements {
    
    var user: String
    var subject: String
    var message: String
    var timestamp: Date
    
    init(user: String, subject: String, message: String, timestamp: Date) {
        print("initializing announcements")
        self.user = user
        self.subject = subject
        self.message = message
        self.timestamp = timestamp
    }

}
