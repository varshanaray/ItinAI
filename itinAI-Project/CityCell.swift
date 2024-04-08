//
//  CityCellTableViewCell.swift
//  itinAI-Project
//
//  Created by Eric Yang on 4/7/24.
//

import UIKit

class CityCell: UITableViewCell {

    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cityNameLabel.textColor = UIColor.white
        cityImageView.contentMode = .scaleAspectFill
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
