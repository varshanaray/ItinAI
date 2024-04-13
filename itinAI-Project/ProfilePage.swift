// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L   

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import MobileCoreServices
import UniformTypeIdentifiers

class ProfilePage: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: CircularProfilePicture!
    @IBOutlet weak var changePictureButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var overlayView: UIView = UIView()
    
    let modalHeight: CGFloat = 300
    
    // modal view for Change Picture
    var pictureModalView: UIView!
    
    var currentModalView: UIView!
    
    let defaultImage = UIImage(named: "defaultProfilePicture")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = defaultImage
        
        displayNameLabel.text = ""
        displayNameLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        
        // Change Picture button
        changePictureButton.setTitle("", for: .normal)
        
        // Set the display name
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Extract the "displayName" field
                if let displayName = document.get("name") as? String {
                    print("Display Name: \(displayName)")
                    self.displayNameLabel.text = displayName
                    // You can now use the displayName variable as needed
                } else {
                    print("Display name not found or not in expected format")
                }
            } else {
                print("User document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // TODO: FINAL - implement
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        print("Change picture button pressed")
        setupPictureModalView()
        currentModalView = pictureModalView
        animateModalView()
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Dismiss the modal view
        dismissModalView()
    }
    
    // Method to set up and present the picture modal view
    func setupPictureModalView() {
        // Create the picture modal view
        pictureModalView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: modalHeight))
        pictureModalView.backgroundColor = .white
        pictureModalView.layer.cornerRadius = 15
        pictureModalView.layer.masksToBounds = true
        pictureModalView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add a view for a darkened background
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0.0 // Initially Invisible
        view.addSubview(overlayView)

        // Add a tap gesture recognizer to overlayView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        
        // Add the picture modal view to the main view
        overlayView.addSubview(pictureModalView)
        
        NSLayoutConstraint.activate([
            pictureModalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pictureModalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pictureModalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pictureModalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.30)
        ])
        
        // Add buttons to the modal view
        let buttonHeight: CGFloat = 60
        let buttonWidth = pictureModalView.frame.width - 40 // Adjust the width as needed
        let buttonSpacing: CGFloat = 30
        
        let takePictureButton = createButton(title: "Take Picture", imageName: "camera", frame: CGRect(x: 20, y: 20, width: buttonWidth, height: buttonHeight))
        takePictureButton.addTarget(self, action: #selector(takePictureButtonPressed), for: .touchUpInside)
        takePictureButton.translatesAutoresizingMaskIntoConstraints = true
        pictureModalView.addSubview(takePictureButton)
        
        NSLayoutConstraint.activate([
            takePictureButton.topAnchor.constraint(equalTo: pictureModalView.topAnchor, constant: 20.0),
            takePictureButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            takePictureButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            takePictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let accessGalleryButton = createButton(title: "Access Gallery", imageName: "photo.on.rectangle", frame: CGRect(x: 20, y: buttonHeight + buttonSpacing, width: buttonWidth, height: buttonHeight))
        accessGalleryButton.addTarget(self, action: #selector(accessGalleryButtonPressed), for: .touchUpInside)
        accessGalleryButton.translatesAutoresizingMaskIntoConstraints = true
        pictureModalView.addSubview(accessGalleryButton)
        
        NSLayoutConstraint.activate([
            accessGalleryButton.topAnchor.constraint(equalTo: takePictureButton.bottomAnchor, constant: 20.0),
            accessGalleryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            accessGalleryButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            accessGalleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let deletePhotoButton = createButton(title: "Delete Photo", imageName: "trash", frame: CGRect(x: 20, y: (buttonHeight + buttonSpacing) + 70, width: buttonWidth, height: buttonHeight))
        deletePhotoButton.addTarget(self, action: #selector(deletePhotoButtonPressed), for: .touchUpInside)
        deletePhotoButton.translatesAutoresizingMaskIntoConstraints = true
        pictureModalView.addSubview(deletePhotoButton)
        
        NSLayoutConstraint.activate([
            deletePhotoButton.topAnchor.constraint(equalTo: accessGalleryButton.bottomAnchor, constant: 10.0),
            deletePhotoButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            deletePhotoButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            deletePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    func createButton(title: String, imageName: String, frame: CGRect) -> IconButton {
        let button = IconButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.titleLabel?.textAlignment = .left
        
        button.setImage(UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .right
        
        if (title == "Delete Photo") {
            button.imageView?.tintColor = .systemRed
            button.setTitleColor(.systemRed, for: .normal)
        }
        
        return button
    }
    
    // Method to handle button press events
    @objc func takePictureButtonPressed() {
        print("Take picture button pressed")
        // Implement functionality to take a picture using the front camera
    }
    
    @objc func accessGalleryButtonPressed() {
        print("Access gallery button pressed")
        // Implement functionality to access the photo gallery
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [UTType.image.identifier]
        present(imagePickerController, animated: true, completion: nil)
        dismissModalView()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            // Use the selected image
            // For example, you can set it as the profile picture
            profilePicture.image = selectedImage
        }
    }
    
    @objc func deletePhotoButtonPressed() {
        print("Delete photo button pressed")
        // Implement functionality to delete the current photo and replace it with the default image
        profilePicture.image = defaultImage
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
    
    func animateModalView() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1.0
            self.currentModalView.frame.origin.y = self.view.frame.height - self.modalHeight
        }
    }
    
   func textFieldShouldReturn(_ textField:UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
   }
    
    // Logs out user and returns to login page
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            self.dismiss(animated: true)
            
        } catch {
            print("log out error")
        }
    }
}
