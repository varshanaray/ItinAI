// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit

class ProfileDoneButton: StyledButton {
    enum ButtonType {
        case create, join, reset, cities
        
        var title: String {
            switch self {
                case .create: return "Create"
                case .join: return "Join"
                case .reset: return "Reset"
                case .cities: return "Cities"
            }
        }
    }
    
    var typeOfButton: ButtonType = .create
    var createDoneCallback: (() -> Void)?
    var joinDoneCallback: (() -> Void)?
    var dismissCallback: (() -> Void)?
    var citiesDoneCallback: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        configureDoneButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        configureDoneButton()
    }

    private func configureDoneButton() {
        setTitle("Done", for: .normal)
        addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    @objc private func doneButtonPressed() {
        switch typeOfButton {
        case .create:
            createDoneCallback?()
        case .join:
            print("Join callback")
            joinDoneCallback?()
        case .reset:
            print("reset callback")
        case .cities:
            print("add city callback")
            citiesDoneCallback?()
        default:
            print("default")
        }
        dismissCallback?() // dismiss the modal view at the end
    }

}
