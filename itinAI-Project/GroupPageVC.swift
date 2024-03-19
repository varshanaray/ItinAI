// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class GroupPageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var announcementsTableView: UITableView!
    @IBOutlet weak var collectionViewPeople: UICollectionView!
    
    var group:Group?
    var groupProfilePics = [UIImage?]()
    var displayNames = [String?]()
    
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
        
        var numInGroup: Int = group?.userList.count ?? -1
        // If less than or equal to 0, do nothing
        if (numInGroup > 0) {
            for i in 0...(numInGroup - 1) {
                print("picture, i: ", i)
                // Default image until database is set up
                var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
                var thisName: String? = group?.userList[i].email
                groupProfilePics.append(thisImage)
                displayNames.append(thisName)
                print("this Name: ", thisName)
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
    
    // Prepare to segue to Details page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GroupToDetails",
           let destination = segue.destination as? GroupDetailsViewController
        {
            destination.thisGroup = group!
        }
    }
    
}
