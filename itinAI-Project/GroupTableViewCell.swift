// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

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
        self.clipsToBounds = true

        // Customize the appearance of the image view
        groupImageView.layer.borderWidth = 0.5
        groupImageView.layer.borderColor = UIColor.black.cgColor
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.layer.cornerRadius = 10 // Optional: Add rounded corners
        groupImageView.clipsToBounds = true
        
        datesRangeLabel.isHidden = true
        
        groupNameLabel.font = UIFont(name: "Poppins-Bold", size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
