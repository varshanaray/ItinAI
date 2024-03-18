import UIKit

class CustomPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            name.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set a fixed size for the image view
        let imageSize: CGFloat = 50 // Example size, adjust as needed
        iconImageView.frame = CGRect(x: 12, y: 10, width: imageSize, height: imageSize)
        // Set the corner radius to half the width/height to make it circular
        iconImageView.layer.cornerRadius = imageSize / 2
        iconImageView.clipsToBounds = true
    }



    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
