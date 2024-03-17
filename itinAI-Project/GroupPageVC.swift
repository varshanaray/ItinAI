//
//  HomeViewController.swift
//  itinAI-Project
//
//  Created by Eric Yang on 3/7/24.
//

import UIKit

class GroupPageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  

    
    @IBOutlet weak var peopleScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var announcementsTableView: UITableView!
    
    @IBOutlet weak var collectionViewPeople: UICollectionView!
    var group:Group?
    
    var groupProfilePics = [UIImage?]()
    
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
        
        // userList
        // for i in 1...3 {
        // !!!!!!!!! DUMMY DATA
        // before i put 5 it was (group?.userList.count)!
        var numInGroup: Int? = 5 - 1
        // 1 is default for number in group (counting self)
        for i in 0...(numInGroup ?? 1) {
            print("picture, i: ", i)
            // Would be getting from userList directly but this is for testing:
            var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
            groupProfilePics.append(thisImage)
            
            //let profilePic = UIImageView()
            //let xPosition = self.view.frame.width * CGFloat(i/4)
            //imageView.image = thisImage
            //imageView.frame = CGRect(x: xPosition, y: 40, width: self.view.frame.width/4, height: 30)
            
            
        }
            
            
            
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: ", groupProfilePics.count)
        return groupProfilePics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionViewPeople.dequeueReusableCell(withReuseIdentifier: "collViewCell", for: indexPath) as! PicCell
        let row = indexPath.row
        cell.profileImageView.image = groupProfilePics[indexPath.row]
        return cell
    }
    
    
    

}


class PicCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
}
