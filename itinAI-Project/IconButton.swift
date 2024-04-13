//
//  IconButton.swift
//  itinAI-Project
//
//  Created by Erick Albarran on 4/12/24.
//

import UIKit

class IconButton: UIButton {
    let padding: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .systemGray2
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Poppins-Bold", size: 17)
        
        
        // Add title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // Add image view
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -1 * padding).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit // Set content mode here
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        // Example alignment for the button's content
        titleLabel.textAlignment = .left
        imageView.contentMode = .right
        
    }
}
