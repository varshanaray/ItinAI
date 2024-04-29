// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class AnnouncementsTableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var content: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true

        setupViews()
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
    
    private func setupViews() {
        message.translatesAutoresizingMaskIntoConstraints = false
        message.isScrollEnabled = false  // Important for expanding size
        message.isEditable = false       // Typically not editable in a cell

        NSLayoutConstraint.activate([
            message.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
        ])
    }
}
