// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseAuth

func setNotificationPreference(enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: "notificationPermission")
}

func isNotificationEnabled() -> Bool {
    return UserDefaults.standard.bool(forKey: "notificationPermission")
}


func scheduleSurveyDeadlineReminders(groupCode: String, groupName: String, cityName: String, deadline: Date) {
    let notificationTimes = calculateNotificationTimes(deadline: deadline)
    
    for (index, notificationTime) in notificationTimes.enumerated() {
        let content = UNMutableNotificationContent()
        content.title = "Interest Survey Deadline Reminder"
        content.sound = UNNotificationSound.default
        
        switch index {
        case 0:
            content.body = "\(cityName) survey for \(groupName) closes in 1 day!"
        case 1:
            content.body = "\(cityName) survey for \(groupName) closes in 1 hour!"
        case 2:
            content.body = "\(cityName) survey for \(groupName) closes in 10 minutes!"
        case 3:
            content.body = "\(cityName) survey for \(groupName) closed. Check app to view generated itinerary."
        default:
            break
        }
        
        scheduleLocalNotification(groupCode: groupCode, cityName: cityName, content: content, date: notificationTime)
    }
}

func calculateNotificationTimes(deadline: Date) -> [Date] {
    let calendar = Calendar.current
    let dayBefore = calendar.date(byAdding: .day, value: -1, to: deadline)!
    let hourBefore = calendar.date(byAdding: .hour, value: -1, to: deadline)!
    let minutesBefore = calendar.date(byAdding: .minute, value: -10, to: deadline)!
    
    return [dayBefore, hourBefore, minutesBefore, deadline]
}

func scheduleLocalNotification(groupCode: String, cityName: String, content: UNMutableNotificationContent, date: Date) {
    guard date > Date() else {
        return
    }
    
    var identifier = "\(groupCode)\(cityName)\(date.hashValue)"
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    
    
    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Successfully scheduled notification for \(groupCode) \(cityName) at \(date.formatted())")
        }
    }
}


func hasNotificationBeenScheduled(groupCode: String, cityName: String, deadline: Date, completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        // Construct the identifier from the groupCode and cityName
        let targetIdentifier = "\(groupCode)\(cityName)\(deadline.hashValue)"

        // Check if any request's identifier matches the targetIdentifier
        let hasScheduled = requests.contains { request in
            request.identifier == targetIdentifier
        }

        DispatchQueue.main.async {
            completion(hasScheduled)
        }
    }
}

func scheduleNotificationsIfNeeded(groupCode: String, groupName: String, cityName: String, deadline: Date) {
    
    // Check if notifications are enabled in user settings
    let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationPermission")
    
    // If notifications are disabled, return immediately
    guard notificationsEnabled else {
        print("Notifications are disabled in settings.")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        return
    }
    
    hasNotificationBeenScheduled(groupCode: groupCode, cityName: cityName, deadline: deadline) { alreadyScheduled in
        guard !alreadyScheduled else {
            print("\(groupName) \(cityName) notifications are already scheduled.")
            return
        }
        scheduleSurveyDeadlineReminders(groupCode: groupCode, groupName: groupName, cityName: cityName, deadline: deadline)
    }
}



func printAllPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        print("Pending Notifications:")
        for request in requests {
            print("ID: \(request.identifier), Title: \(request.content.title), Body: \(request.content.body)")
        }
    }
}


func fetchGroupsAndScheduleNotifications() {
    
    let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationPermission")
    
    // If notifications are disabled, return immediately
    guard notificationsEnabled else {
        print("Notifications are disabled in settings. fetchGroupsAndScheduleNotifications returns")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        return
    }
    
    guard let userId = Auth.auth().currentUser?.uid else {
        print("User is not logged in")
        return
    }

    let db = Firestore.firestore()
    
    print("performing global notification scheduling")

    print("userID \(userId)")
    // Fetch groups referenced by the current user
    db.collection("Users").document(userId).getDocument { (document, error) in
        guard let document = document, let data = document.data(), error == nil else {
            print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        guard let groupRefs = data["groupRefs"] as? [DocumentReference] else {
            print("No groups found for this user.")
            return
        }
        // Iterate through each group reference
        for groupRef in groupRefs {
            groupRef.getDocument { (groupDoc, error) in
                guard let groupDoc = groupDoc, let groupData = groupDoc.data(), error == nil else {
                    print("Error fetching group data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let groupCode = groupRef.documentID
                let groupName = groupData["groupName"] as? String ?? "Unknown Group Name"

                if let cityRefs = groupData["cityList"] as? [DocumentReference] { // Assuming cityList contains IDs of cities
                    for cityRef in cityRefs {
                        cityRef.getDocument { (cityDoc, error) in
                            guard let cityDoc = cityDoc, let cityData = cityDoc.data(), error == nil else {
                                print("Error fetching city data: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            let cityName = cityData["cityName"] as? String ?? "Unknown City"
                            if let deadlineTimestamp = cityData["deadline"] as? Timestamp {
                                let deadline = deadlineTimestamp.dateValue()
                                print("attempting auto notification schedule for \(groupName)(\(groupCode)) \(cityName)")
                                scheduleNotificationsIfNeeded(groupCode: groupCode, groupName: groupName, cityName: cityName, deadline: deadline)
                            }
                        }
                    }
                }
            }
        }
    }
}
