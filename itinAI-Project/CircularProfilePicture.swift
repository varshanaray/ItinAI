//  CircularProfilePicture.swift

import UIKit

class CircularProfilePicture: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make image view circular
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }

}
