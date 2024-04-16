// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class CircularProfilePicture: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make image view circular
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }

}
