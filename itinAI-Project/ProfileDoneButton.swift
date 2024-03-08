//
//  ProfileDoneButton.swift
//  ItinAI_ProfilePageUI
//
//  Created by Erick Albarran on 3/7/24.
//

import UIKit

class ProfileDoneButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    enum ButtonType {
        case create, join, reset
        
        var title: String {
            switch self {
            case .create: return "Create"
            case .join: return "Join"
            case .reset: return "Reset"
            }
        }
    }
    
    var typeOfButton: ButtonType = .create
    var createDoneCallback: (() -> Void)?
    //var joinDoneCallback:
    //var resetDoneCallback:
    var dismissCallback: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        configureDoneButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        configureDoneButton()
    }

    
    private func configureDoneButton() {
        backgroundColor = .black
        layer.cornerRadius = 10.0
        setTitleColor(.white, for: .normal)
        setTitle("Done", for: .normal)
//        addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    
    // TODO: - Figure out how to save stuff from any modal view when the done button is pressed
    @objc private func doneButtonPressed() {
//        switch typeOfButton {
//        case .create:
//            // execute the callback with the groupname
//            doneCallback("")
//        case .join:
//            <#code#>
//        case .reset:
//            <#code#>
//        }
        
        dismissCallback?()
    }

}
