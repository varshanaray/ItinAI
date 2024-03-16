//
//  HomeViewController.swift
//  itinAI-Project
//
//  Created by Eric Yang on 3/7/24.
//

import UIKit

class GroupPageVC: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var peopleTableView: UITableView!
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var announcementsTableView: UITableView!
    
    var group:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 20
        
        citiesTableView.layer.cornerRadius = 20
        citiesTableView.layer.borderWidth = 1
        citiesTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        peopleTableView.layer.cornerRadius = 20
        peopleTableView.layer.borderWidth = 1
        peopleTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        announcementsTableView.layer.cornerRadius = 20
        announcementsTableView.layer.borderWidth = 1
        announcementsTableView.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    

}
