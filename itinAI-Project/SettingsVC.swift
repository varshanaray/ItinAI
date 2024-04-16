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
        
        if (UserDefaults.standard.object(forKey: "darkMode")! as! Int == 1) {
            // dark mode is on
            darkModeSwitch.isOn = true
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            darkModeSwitch.isOn = false
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
        // Do any additional setup after loading the view.
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
            //var granted = true
          /*  UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            var allow = true
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("value of granted: ", granted)
                print("value of allow: ", allow)
                // User granted permission
                print("Notification permission granted")
            }
          
        } */
        } else {
            print("Switch is OFF")
            UserDefaults.standard.set(false, forKey: "notificationPermission")
           /* UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                var allow = false
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("value of granted: ", granted)
                    print("value of allow: ", allow)
                    // User granted permission
                    print("Notification permission NOT granted")
                }
            } */
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
