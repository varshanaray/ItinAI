// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore

class AnnounceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addAnnounce: UIButton!
    
    var overlayView: UIView = UIView()
    
    let modalHeight: CGFloat = 300
    
    var currentModalView: UIView!
    
    var createModalView: UIView!
    
    // modal view for Join
    var joinModalView: UIView!
    
    // modal view for Change Picture
    var pictureModalView: UIView!
    
    // modal view for Reset password
    var resetModalView: UIView!
    
    var subject = ""
    var announcement = ""
    var group:Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        print("Add button pressed")
        let buttonTitle = addAnnounce.title(for: .normal) ?? ""
        setupCreateModalView(title: buttonTitle)
        currentModalView = createModalView
        animateModalView()
    }
    
    
    func setupCreateModalView(title: String) {
        var modalTitle: String = ""
        let leftMargin: CGFloat = 20.0
        
        createModalView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: modalHeight))
            createModalView.backgroundColor = .white
            createModalView.layer.cornerRadius = 15
            createModalView.layer.masksToBounds = true
            createModalView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add a view for a darkened background
                overlayView = UIView(frame: view.bounds)
                overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                overlayView.alpha = 0.0 // Initially Invisible
                view.addSubview(overlayView)
                
                // Add a tap gesture recognizer to overlayView
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                overlayView.addGestureRecognizer(tapGesture)
                view.addSubview(createModalView)
            
            NSLayoutConstraint.activate([
                createModalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                createModalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                createModalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                createModalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5) // Use a higher multiplier
            ])
        
        // Create Group label
        let titleLabel = UILabel()
        titleLabel.text = "Add Announcement"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 25)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        createModalView.addSubview(titleLabel)
        
        // Add constraints for the label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: createModalView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: createModalView.leadingAnchor, constant: 20),
        ])
        
        print("Create modal view")

        // Create Subject label
        var subjectLabel = UILabel()
        subjectLabel.text = "Subject"
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        subjectLabel.frame.origin.x = leftMargin
        createModalView.addSubview(subjectLabel)
        
        NSLayoutConstraint.activate([
            subjectLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            subjectLabel.leadingAnchor.constraint(equalTo: createModalView.leadingAnchor, constant: 20),
            subjectLabel.widthAnchor.constraint(equalToConstant: 200.0),
            subjectLabel.heightAnchor.constraint(equalToConstant: 25.0)
        ])
        
        // Subject text field
        var placeHolderText = "Max 50 word count"
        var placeHolderFont = UIFont(name: "Poppins-Regular", size: 12)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: placeHolderFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        var attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: attributes)
        
        var subjectTextField = UITextField()
        subjectTextField.delegate = self
        subjectTextField.attributedPlaceholder = attributedPlaceholder
        subjectTextField.backgroundColor = UIColor(red: 242/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        subjectTextField.font = UIFont(name: "Poppins-Regular", size: 12)
        subjectTextField.layer.cornerRadius = 8.0
        subjectTextField.frame.origin.x = leftMargin
        subjectTextField.frame = CGRect(x: leftMargin, y: 100.0, width: 350.0, height: 30.0)
        
        var paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: subjectTextField.frame.height))
        
        subjectTextField.leftView = paddingView
        subjectTextField.leftViewMode = .always
        
        subject = subjectTextField.text!
        
        createModalView.addSubview(subjectTextField)
        
        // Create character count label
        /*
         var characterCountLabel = UILabel()
         characterCountLabel.textColor = .red
         characterCountLabel.isHidden = true
         characterCountLabel.frame = CGRect(x: leftMargin, y: 100.0, width: 200.0, height: 20.0)
         characterCountLabel.font = UIFont(name: "Poppins-Bold", size: 11)
         createModalView.addSubview(characterCountLabel)
         */
        
        // Create Announcement label
        // Announcement Label
            let announceLabel = UILabel()
            announceLabel.text = "Announcement"
            announceLabel.font = UIFont(name: "Poppins-Bold", size: 16)
            announceLabel.translatesAutoresizingMaskIntoConstraints = false
            createModalView.addSubview(announceLabel)
            
            NSLayoutConstraint.activate([
                announceLabel.topAnchor.constraint(equalTo: subjectTextField.bottomAnchor, constant: 15),
                announceLabel.leadingAnchor.constraint(equalTo: createModalView.leadingAnchor, constant: 20),
            ])
            
            // Announcement TextView
            let announceTextView = UITextView()
            announceTextView.backgroundColor = UIColor(red: 242/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
            announceTextView.layer.cornerRadius = 8.0
            announceTextView.font = UIFont(name: "Poppins-Regular", size: 12)
            announceTextView.translatesAutoresizingMaskIntoConstraints = false
            createModalView.addSubview(announceTextView)
            
            NSLayoutConstraint.activate([
                announceTextView.topAnchor.constraint(equalTo: announceLabel.bottomAnchor, constant: 10),
                announceTextView.leadingAnchor.constraint(equalTo: createModalView.leadingAnchor, constant: 20),
                announceTextView.trailingAnchor.constraint(equalTo: createModalView.trailingAnchor, constant: -20),
                announceTextView.heightAnchor.constraint(equalToConstant: 150) // Increased height for more text
            ])
        
        announcement = announceTextView.text!
        
        createModalView.addSubview(announceTextView)
        
        // Configure the Done Button
            let createDoneButton = ProfileDoneButton() // Assuming UIButton, adjust as necessary
            createDoneButton.setTitle("Done", for: .normal)
            createDoneButton.translatesAutoresizingMaskIntoConstraints = false
            createModalView.addSubview(createDoneButton)

            NSLayoutConstraint.activate([
                createDoneButton.centerXAnchor.constraint(equalTo: createModalView.centerXAnchor),
                createDoneButton.bottomAnchor.constraint(equalTo: createModalView.bottomAnchor, constant: -25),  // 20 points from the bottom
                createDoneButton.widthAnchor.constraint(equalToConstant: 70),
                createDoneButton.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            // Ensure the constraints are activated and the layout is updated
            createModalView.layoutIfNeeded()
        
    
         createDoneButton.createDoneCallback = {
             print("Create done callback")
             self.handleAnnouncmentCreation(subject: subjectTextField.text!, announcement: announceTextView.text!)
         }
         
         createDoneButton.dismissCallback = {
             // Dismiss modal view
             self.dismissModalView()
         }
        
    }
    
    func handleAnnouncmentCreation(subject: String, announcement: String) {

        let db = Firestore.firestore()
        /*
        // append to user's groupList
        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        db.collection("Groups").document(code).setData([
            "groupName": name,
            "code": code,
            "userList": [userRef]
            //"userList": [Auth.auth().currentUser!.uid]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let groupRef = db.collection("Groups").document(code)
        userRef.updateData([
            "groupRefs": FieldValue.arrayUnion([groupRef])
        ])  { error in
            if let error = error {
                print("Error updating user document: \(error)")
            } else {
                self.fetchGroups()
                print("Group reference added to user successfully")
            }
        }
         */
    }
    
    func animateModalView() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1.0
            self.currentModalView.frame.origin.y = self.view.frame.height - self.modalHeight
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Dismiss the modal view
        dismissModalView()
    }
    
    func dismissModalView() {
        // Animate modal view and overlay out of the screen
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 0.0
            self.currentModalView.frame.origin.y = self.view.frame.height
        }) { _ in
            // Remove both views from the superview after animation completes
            self.overlayView.removeFromSuperview()
            self.currentModalView.removeFromSuperview()
        }
    }
}
        
            
 
