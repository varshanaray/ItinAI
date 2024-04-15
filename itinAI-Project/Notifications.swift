// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import Foundation
import UserNotifications

enum NotificationType {
    case newCity, surveyDeadline
}

func setNotificationPreference(for type: NotificationType, enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: "\(type)NotificationEnabled")
}

func isNotificationEnabled(for type: NotificationType) -> Bool {
    return UserDefaults.standard.bool(forKey: "\(type)NotificationEnabled")
}


func scheduleSurveyDeadlineReminders(cityName: String, deadline: Date) {
    let notificationTimes = calculateNotificationTimes(deadline: deadline)
    
    for (index, notificationTime) in notificationTimes.enumerated() {
        let content = UNMutableNotificationContent()
        content.title = "Survey Deadline Reminder for \(cityName)"
        content.sound = UNNotificationSound.default
        
        switch index {
        case 0:
            content.body = "The survey for \(cityName) closes in 1 day. Don't forget to complete it!"
        case 1:
            content.body = "The survey for \(cityName) closes in 1 hour."
        case 2:
            content.body = "The survey for \(cityName) closes in 10 minutes."
        case 3:
            content.body = "The survey for \(cityName) has now closed. Check the app to generate your itinerary."
        default:
            break
        }
        
        scheduleLocalNotification(content: content, date: notificationTime)
    }
}

func calculateNotificationTimes(deadline: Date) -> [Date] {
    let calendar = Calendar.current
    let dayBefore = calendar.date(byAdding: .day, value: -1, to: deadline)!
    let hourBefore = calendar.date(byAdding: .hour, value: -1, to: deadline)!
    let minutesBefore = calendar.date(byAdding: .minute, value: -10, to: deadline)!
    
    return [dayBefore, hourBefore, minutesBefore, deadline]
}

func scheduleLocalNotification(content: UNMutableNotificationContent, date: Date) {
    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Successfully scheduled notification for \(content.title) at \(date)")
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
