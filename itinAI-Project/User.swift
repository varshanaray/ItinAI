// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

class User {
    
    var email: String
    var displayName: String
    var groupList: [Group]
    var profileImageUrl: String
    
    init(email: String, displayName: String, groupList: [Group], profileImageUrl: String) {
        self.email = email
        self.displayName = displayName
        self.groupList = groupList
        self.profileImageUrl = profileImageUrl
    }
    
}
