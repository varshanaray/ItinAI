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
        
        
        NSLayoutConstraint.activate([
            message.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 50),
        ])
    }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            // Configure the view for the selected state
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set a fixed image size
        let imageSize: CGFloat = 50
        img.frame = CGRect(x: 12, y: 10, width: imageSize, height: imageSize)
        // Set the corner radius to make image circular
        img.layer.cornerRadius = imageSize / 2
        img.clipsToBounds = true
    }

}
