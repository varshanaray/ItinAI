// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation
import UserNotifications

func setNotificationPreference(enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: "NotificationEnabled")
}

func isNotificationEnabled() -> Bool {
    return UserDefaults.standard.bool(forKey: "NotificationEnabled")
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


// code for settings toggle reference

/*
@IBAction func newCitySwitchToggled(_ sender: UISwitch) {
    setNotificationPreference(for: .newCity, enabled: sender.isOn)
}

@IBAction func surveyDeadlineSwitchToggled(_ sender: UISwitch) {
    setNotificationPreference(for: .surveyDeadline, enabled: sender.isOn)
}

override func viewDidLoad() {
    super.viewDidLoad()
    newCitySwitch.isOn = isNotificationEnabled(for: .newCity)
    surveyDeadlineSwitch.isOn = isNotificationEnabled(for: .surveyDeadline)
}
 
 for city in fetchedCities {
     if let deadline = city.surveyDeadline {
         scheduleSurveyDeadlineReminders(cityName: city.name, deadline: deadline)
     }
 }
 
*/

func printAllPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        print("Pending Notifications:")
        for request in requests {
            print("ID: \(request.identifier), Title: \(request.content.title), Body: \(request.content.body)")
        }
    }
}
