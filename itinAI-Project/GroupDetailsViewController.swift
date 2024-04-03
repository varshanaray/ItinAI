// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    
    var groupProfilePics = [UIImage?]()
        var displayNames = [String?]()
        var group:Group?
        
        var thisGroup: Group? {
            // Reload table whenever thisGroup is updated
            didSet {
                tableView?.reloadData()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = 75
            groupNameLabel.text = group?.groupName
            groupCodeLabel.text = "Group Code: " + group!.groupCode
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return groupProfilePics.count //thisGroup?.userList.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //let person = thisGroup?.userList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! CustomPeopleTableViewCell
            cell.name.text = displayNames[indexPath.row]
            cell.iconImageView.image = groupProfilePics[indexPath.row]
            return cell
        }
        
    }

