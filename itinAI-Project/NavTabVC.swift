// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class NavTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the default tab to the middle tab
        let middleIndex = 1
        selectedIndex = middleIndex
        UITabBar.appearance().unselectedItemTintColor = .white
    }

}
