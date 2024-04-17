//
//  AnnouncementsTableViewCell.swift
//  itinAI-Project
//
//  Created by Gurman Kalkat on 4/16/24.
//

import UIKit

class AnnouncementsTableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true

        // Customize the appearance of the image view
        /*
        groupImageView.layer.borderWidth = 0.5
        groupImageView.layer.borderColor = UIColor.black.cgColor
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 10 // Optional: Add rounded corners
        groupImageView.clipsToBounds = true
        */
        
        /*
        NSLayoutConstraint.activate([
                    myLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                    myLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                    myLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                    
                    myImageView.topAnchor.constraint(equalTo: myLabel.bottomAnchor, constant: 10),
                    myImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                    myImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                    myImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                    myImageView.heightAnchor.constraint(equalToConstant: 100)  // Fixed height for image view
                ])*/
    }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            // Configure the view for the selected state
        }

}
