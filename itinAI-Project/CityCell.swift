// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

// Class dedicated to a city cell in a group.
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 0.5
    }
}
