//  ProfileDoneButton.swift
import UIKit

class ProfileDoneButton: UIButton {
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
    var joinDoneCallback: (() -> Void)?
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
        addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    // TODO: - Figure out how to save stuff from any modal view when the done button is pressed
    @objc private func doneButtonPressed() {
        switch typeOfButton {
        case .create:
            createDoneCallback?()
        case .join:
            print("Join callback")
            joinDoneCallback?()
        case .reset:
            print("reset callback")
        default:
            print("default")
        }
        dismissCallback?() // dismiss the modal view at the end
    }

}
