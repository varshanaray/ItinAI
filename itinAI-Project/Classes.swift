//
//  Classes.swift
//  itinAI-Main
//
//  Created by Eric Yang on 3/8/24.
//

import Foundation
import UIKit

// All groups existing on app for all users
var globalGroupList: [Group] = []
var globalUserList: [User] = []
var currentUser: User?

class User {
    
    var displayName: String
    var groupList: [Group]
    var profileImageUrl: String
    
    init(displayName: String, groupList: [Group], profileImageUrl: String) {
        self.displayName = displayName
        self.groupList = groupList
        self.profileImageUrl = profileImageUrl
        currentUser = self
    }
    
}

class Group {
    
    var groupName: String
    var groupCode: String
    var userList: [User]
    // var cityList: [City]
    // var dateList: [Date]
    // var announcementList: [Announcement]
    
    init(groupName: String, groupCode: String, userList: [User]) {
        self.groupName = groupName
        self.groupCode = groupCode
        self.userList = userList
    }


}
