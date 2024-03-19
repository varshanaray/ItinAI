// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

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
