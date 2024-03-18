//
//  User.swift
//  itinAI-Project
//
//  Created by Eric Yang on 3/18/24.
//

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
