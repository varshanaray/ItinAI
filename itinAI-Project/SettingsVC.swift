// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

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
        if (UserDefaults.standard.object(forKey: "notificationPermission")! as! Int == 1) {
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
        if (sender as! UISwitch).isOn {
            UserDefaults.standard.set(true, forKey: "darkMode")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            UserDefaults.standard.set(false, forKey: "darkMode")
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func notifsSwitchChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            UserDefaults.standard.set(true, forKey: "notificationPermission")
            fetchGroupsAndScheduleNotifications()
        } else {
            UserDefaults.standard.set(false, forKey: "notificationPermission")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
}
