//  User.swift

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
