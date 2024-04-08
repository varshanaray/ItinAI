// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation

// Class to create a city object.
class City {
    
    var name: String
    var startDate: Date
    var endDate: Date
    var deadline: Date
    var cityImageURL: String
    
    init(name: String, startDate: Date, endDate: Date, deadline: Date, imageURL: String) {
        self.name = name
        self.startDate = startDate
        self.deadline = deadline
        self.endDate = endDate
        self.cityImageURL = imageURL
    }
}
