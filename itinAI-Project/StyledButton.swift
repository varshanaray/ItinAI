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
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.8 // Adjust as needed
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        // Set the background color
        
        //self.backgroundColor = UIColor.lightGray
        self.backgroundColor = UIColor(red: 242/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        
        // Set content edge insets
        //self.contentEdgeInsets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)
        
        //self.titleLabel?.textColor = UIColor.black
        
        self.setTitleColor(UIColor.black, for: .normal)
        //self.titleLabel?.font = UIFont(name: "Poppins-Bold", size: 20)
        self.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Poppins-Bold", size:18)!)
    }

    
}
