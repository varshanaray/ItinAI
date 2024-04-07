//
//  NavTabVC.swift
//  itinAI-Project
//
//  Created by Varsha Narayanan on 4/7/24.
//

import UIKit

class NavTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the default tab to the middle tab
        let middleIndex = 1
        selectedIndex = middleIndex
        UITabBar.appearance().unselectedItemTintColor = .white
        

      
    }
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("View did Layout")
        // Rounded corners
        // Get new y position for the tab bar
        let tabBarHeight = tabBar.frame.size.height
        let newTabBarYPosition = view.frame.height - tabBarHeight - 100
        
      
        // Set the new frame for the tab bar
        tabBar.frame = CGRect(x: 0, y: newTabBarYPosition, width: tabBar.frame.size.width, height: tabBarHeight)
        
    }
     */
    


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
