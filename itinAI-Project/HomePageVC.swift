//
//  HomePageVC.swift
//  itinAI-Project
//
//  Created by Varsha Narayanan on 3/16/24.
//

import UIKit

protocol GroupTableUpdater {
    func addGroup(newGroup: Group)
}

class HomePageVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GroupTableUpdater {

    

    @IBOutlet weak var groupTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
       


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("count: ",currentUser!.groupList.count )
        return currentUser!.groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisGroupList = currentUser!.groupList
        // dummy
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableCell", for: indexPath)
        let row = indexPath.row
        let cellText = thisGroupList[row].groupName
        cell.textLabel?.text = cellText
        return cell
    }
    
    func addGroup(newGroup: Group) {
        // Add group to group list array
        currentUser!.groupList.append(newGroup)
        // Refreshes table
        groupTableView.reloadData()
    }
    
    
    // Prepare for segue to group page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CellToGroupSegue",
           let destination = segue.destination as? GroupPageVC,
           let groupIndex = groupTableView.indexPathForSelectedRow?.row
        {
            destination.group = currentUser!.groupList[groupIndex]
        }
    }

}
