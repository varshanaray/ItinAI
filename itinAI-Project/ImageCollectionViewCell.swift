// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

// Class to store custom properties of collection view cell in people carousel
class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set a fixed image size
        let imageSize: CGFloat = userImageView.frame.size.width
        userImageView.frame = CGRect(x: 12, y: 10, width: imageSize, height: imageSize)
        // Set the corner radius to make image circular
        userImageView.layer.cornerRadius = imageSize / 2
        userImageView.clipsToBounds = true
    }
    
   /* override func updateConfiguration(using state: UICellConfigurationState) {
        print("update config func")
        automaticallyUpdatesBackgroundConfiguration = false
        
        var modifiedState = state
        modifiedState.isHighlighted = false
        modifiedState.isSelected = false
        backgroundConfiguration = backgroundConfiguration?.updated(for: modifiedState)
    } */
    

}
