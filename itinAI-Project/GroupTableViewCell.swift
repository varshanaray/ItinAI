//
//  GroupTableViewCell.swift
//  itinAI-Project
//
//  Created by Erick Albarran on 4/7/24.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var datesRangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        //self.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        // Customize the appearance of the image view
        groupImageView.layer.borderWidth = 0.5
        groupImageView.layer.borderColor = UIColor.black.cgColor
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 10 // Optional: Add rounded corners
        groupImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
