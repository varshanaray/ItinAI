//
//  GroupDetailsViewController.swift
//  itinAI-Project
//
//  Created by Gurman Kalkat on 3/17/24.
//

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    var thisGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        thisGroup = Group(groupName: "temp", groupCode: "", userList: [])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisGroup?.userList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = thisGroup?.userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleCell", for: indexPath) as! CustomPeopleTableViewCell
        cell.name.text = person?.displayName
        cell.iconImageView.image = UIImage(named: person?.profileImageUrl ?? "defaultProfilePicture")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
