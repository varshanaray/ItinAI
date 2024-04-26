//
//  SettingsVC.swift
//  itinAI-Project
//
//  Created by Varsha Narayanan on 4/15/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class SettingsVC: UIViewController {

    
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    @IBOutlet weak var notifsSwitch: UISwitch!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    let storage = Storage.storage()
    var groupImagesRef: StorageReference!
    var groupStorageRef: StorageReference!
    var currentGroupImageURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // .isOn = tru
        
        if (UserDefaults.standard.object(forKey: "notificationPermission")! as! Int == 1) {
            print("is on")
            notifsSwitch.isOn = true
        } else {
            notifsSwitch.isOn = false
        }
        
        if let darkModeValue = UserDefaults.standard.object(forKey: "darkMode") as? Int, darkModeValue == 1 {
            // dark mode is on
            darkModeSwitch.isOn = true
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            darkModeSwitch.isOn = false
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
        // Do any additional setup after loading the view.
        settingsLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        
        notificationsLabel.font = UIFont(name: "Poppins-Regular", size: 17)
        darkModeLabel.font = UIFont(name: "Poppins-Regular", size: 17)


    }
    

    @IBAction func darkModeChanged(_ sender: Any) {
        print("Dark mode switch changed")
        if (sender as! UISwitch).isOn {
            print("darkMode switch is ON")
            UserDefaults.standard.set(true, forKey: "darkMode")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            print("Darkmode Switch is OFF")
            UserDefaults.standard.set(false, forKey: "darkMode")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
         
        }
        
    }
    
    @IBAction func notifsSwitchChange(_ sender: Any) {
        print("Notif switch changed")
        if (sender as! UISwitch).isOn {
            print("Switch is ON")
            UserDefaults.standard.set(true, forKey: "notificationPermission")
            fetchGroupsAndScheduleNotifications()
        } else {
            print("Switch is OFF")
            UserDefaults.standard.set(false, forKey: "notificationPermission")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }

}
