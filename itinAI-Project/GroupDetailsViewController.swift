// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var descript: UITextView!
    
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
            
//            descript.delegate = self
//            NSString.self *savedText = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferenceName"];
//            descript.text = savedText;
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
    
        func textViewDidEndEditing(_ textView: UITextView) {
//            NSString *textToSave = descript.text;
//            [[NSUserDefaults standardUserDefaults] setObject:textToSave forKey:@"preferenceName"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }

