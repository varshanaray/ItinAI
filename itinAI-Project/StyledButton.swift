// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

// Class that styles a button like how we designed in Figma.
class StyledButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }

    private func customInit() {
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.8
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        // Set the background color
        self.backgroundColor = UIColor(named: "LoginButton")
        
        self.setTitleColor(UIColor(named: "LoginButtonText"), for: .normal)
        self.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Poppins-Bold", size:18)!)
    }

}
