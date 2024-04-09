// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var detailsImage: UIImageView!
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
        detailsImage.image = UIImage(named: "japan")
        descript.delegate = self
        descript.allowsEditingTextAttributes = true
        // Get saved description from Firestore
        let db = Firestore.firestore()
        let groupId = group?.groupCode
        db.collection("Groups").document(groupId!).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                // Document found, retrieve description
                let description = document.data()?["description"] as? String ?? "Edit Here"
                descript.text = description
                print("Description: \(description)")
            } else {
                // Document does not exist or there was an error
                print("Document does not exist or there was an error")
            }
        }
         
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupProfilePics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! CustomPeopleTableViewCell
        cell.name.text = displayNames[indexPath.row]
        cell.iconImageView.image = groupProfilePics[indexPath.row]
        return cell
    }

    func textViewDidChange(_ textView: UITextView) {
        saveTextToStorage(textView.text)
    }
    
    // Update description text in Firestore
    func saveTextToStorage(_ text: String) {
        let db = Firestore.firestore()
        let groupId = group?.groupCode

        db.collection("Groups").document(groupId!).setData([
            "description": descript.text!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}
