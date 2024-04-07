//
//  StyledButton.swift
//  itinAI-Project
//
//  Created by Eric Yang on 4/7/24.
//

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
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5 // Adjust as needed
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        // Set the background color
        self.backgroundColor = UIColor.systemBlue
        
        // Set content edge insets
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Poppins-Bold", size: 24)!)
    }

    
}
