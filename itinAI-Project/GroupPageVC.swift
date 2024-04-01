// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroupPageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var announcementsTableView: UITableView!
    @IBOutlet weak var collectionViewPeople: UICollectionView!
    
    var group:Group?
    var groupProfilePics = [UIImage?]()
    var displayNames = [String?]()
    var thisGroupUsers = [User?]()
    var citiesArray = [String?] () // temporary for debugging
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewPeople.delegate = self
        collectionViewPeople.dataSource = self
        
        contentView.layer.cornerRadius = 20
        
        citiesTableView.layer.cornerRadius = 20
        citiesTableView.layer.borderWidth = 1
        citiesTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        announcementsTableView.layer.cornerRadius = 20
        announcementsTableView.layer.borderWidth = 1
        announcementsTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        /*var numInGroup: Int = 0 //group?.userList.count ?? -1
        // If less than or equal to 0, do nothing
        if (numInGroup > 0) {
            for i in 0...(numInGroup - 1) {
                print("picture, i: ", i)
                // Default image until database is set up
                var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
                var thisName: String? = "" //group?.userList[i].email
                groupProfilePics.append(thisImage)
                displayNames.append(thisName)
                print("this Name: ", thisName)
            }
        } */
        
        // Get from firestore
        print("group code!: ", (group?.groupCode)!)
        fetchUsers(groupCode: (group?.groupCode)!)
        
    }

    
    
    func fetchUsers(groupCode: String) {
        print("fetchusers() called")
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(groupCode)
        
        groupRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Group document does not exists")
                return
            }
            if let userRefs = document.data()?["userList"] as? [DocumentReference] {
                print("User doc is there")
                let dispatchGroup = DispatchGroup()
                for userRef in userRefs {
                    dispatchGroup.enter()
                    print("userRefs found")
                    userRef.getDocument { (userDoc, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let userDoc = userDoc, userDoc.exists, let email =  userDoc.data()?["email"] as? String, let name =  userDoc.data()?["name"] as? String {
                            //let user = User(email: email, displayName: name, profileImageUrl: "")
                            print("!!! name: ", name)
                            self.displayNames.append(name)
                            var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
                            self.groupProfilePics.append(thisImage)
                            print("group profile pics count: ", self.groupProfilePics.count)
                        } else {
                            print("User document does not exists in User")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    print("reload collection view for people")
                    self.collectionViewPeople.reloadData()
                }
                    
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: ", groupProfilePics.count)
        return groupProfilePics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.userImageView.image = groupProfilePics[indexPath.row]
        cell.userDisplayLabel.text = displayNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table view.
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: "CitiesCell", for: indexPath)

        // Get the city name for the current row.
        let cityName = citiesArray[indexPath.row]

        // Set the city name to the cell's text label.
        cell.textLabel?.text = cityName

        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare to segue to Details page
        if segue.identifier == "GroupToDetails",
           let destination = segue.destination as? GroupDetailsViewController
        {
            destination.thisGroup = group!
        }
        
        // Prepare to seugue to Survey page
//        if segue.identifier == "SurveyPageSegue" {
//            let destination = segue.destination as? SurveyPageVC
//        }
        
        if segue.identifier == "TestSurveySegue" {
            if let destination = segue.destination as? SurveyPageVC {
                destination.cityName = "Tokyo"
            }
        }
    }
    
}
