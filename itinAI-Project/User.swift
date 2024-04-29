// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

// Class to create a user object.
class User {
    
    var email: String
    var displayName: String
    var profileImageUrl: String
    
    init(email: String, displayName: String, profileImageUrl: String) {
        self.email = email
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
    }
}
