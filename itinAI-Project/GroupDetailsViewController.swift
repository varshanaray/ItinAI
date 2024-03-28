// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    
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
        groupNameLabel.text = thisGroup?.groupName
        groupCodeLabel.text = "Group Code: " + thisGroup!.groupCode
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 //thisGroup?.userList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let person = thisGroup?.userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! CustomPeopleTableViewCell
        cell.name.text = "" //person?.email
        cell.iconImageView.image = UIImage(named: "defaultProfilePicture")
        return cell
    }
    
}
