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
        
        // Customize the appearance of the image view
        groupImageView.layer.borderWidth = 2.5
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
