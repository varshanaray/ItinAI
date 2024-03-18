//
//  GroupDetailsViewController.swift
//  itinAI-Project
//
//  Created by Gurman Kalkat on 3/17/24.
//

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var thisGroup: Group? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.rowHeight = UITableView.automaticDimension
        tableView.rowHeight = 75
        print("this group name: ", thisGroup?.groupName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisGroup?.userList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = thisGroup?.userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! CustomPeopleTableViewCell
        cell.name.text = person?.email
        cell.iconImageView.image = UIImage(named: "defaultProfilePicture")
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return tableView.bounds.width / 3
//    }
    
}
