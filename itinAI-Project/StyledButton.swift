// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

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
        self.titleLabel?.minimumScaleFactor = 0.8 // Adjust as needed
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        // Set the background color
        self.backgroundColor = UIColor(red: 242/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Poppins-Bold", size:18)!)
    }

    
}
