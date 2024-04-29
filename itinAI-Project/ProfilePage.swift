// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L   

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import MobileCoreServices
import UniformTypeIdentifiers

class ProfilePage: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var resetStatusLabel: UILabel!
    @IBOutlet weak var profilePicture: CircularProfilePicture!
    @IBOutlet weak var changePictureButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var overlayView: UIView = UIView()
    
    let modalHeight: CGFloat = 300
    
    // modal view for Change Picture
    var pictureModalView: UIView!
    
    var currentModalView: UIView!
    
    let storage = Storage.storage()
    var pfpRef: StorageReference!
    var userStorageRef: StorageReference!
    var currentProfilePictureUrl: String?
    var userEmail: String?
    
    let defaultImage = UIImage(named: "defaultProfilePicture")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetStatusLabel.text = ""
        profilePicture.image = defaultImage
        
        displayNameLabel.text = ""
        displayNameLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        
        // Change Picture button
        changePictureButton.setTitle("", for: .normal)
        
        pfpRef = storage.reference().child("ProfilePictures")
        
        // Retrieve the current user's UID
        guard let userId = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        
        var userStorageRef = pfpRef.child(Auth.auth().currentUser!.uid)
        self.userStorageRef = userStorageRef
        
        logoutButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 15)
        resetPasswordButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveProfilePicture()
        resetStatusLabel.text = ""
        // Set the display name
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Extract the "displayName" field
                if let displayName = document.get("name") as? String {
                    print("Display Name: \(displayName)")
                    self.displayNameLabel.text = displayName
                } else {
                    print("Display name not found or not in expected format")
                }
                if let email = document.get("email") as? String {
                    print("Email: \(email)")
                    self.userEmail = email
                } else {
                    print("Email not found or not in expected format")
                }
            } else {
                print("User document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @IBAction func resetPassPressed(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: userEmail ?? "") { error in
            if let error = error {
                // Handle error
                print("Error sending password reset email: \(error.localizedDescription)")
                // Display error message to the user
                self.resetStatusLabel.textColor = .red
                self.resetStatusLabel.text = "Unable to send password request!"
            } else {
                // Password reset email sent successfully
                print("Password reset email sent successfully")
                //self.resetStatusLabel.textColor = .black
                self.resetStatusLabel.text = "Password reset request successfully sent!"
                // Display success message to the user
            }
        }
    }
    
    func retrieveProfilePicture() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(currentUser.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let profileImageUrl = document.get("profileImageURL") as? String {
                    // Profile picture URL found in Firestore
                    self.currentProfilePictureUrl = profileImageUrl
                    //self.downloadProfilePicture(profileImageUrl)
                    self.profilePicture.setImage(with: profileImageUrl, placeholder: UIImage(named: "defaultProfilePicture"), fallbackImage: UIImage(named: "defaultProfilePicture"))
                } else {
                    print("Profile image URL not found")
                    // Use default profile picture
                }
            } else {
                print("User document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func downloadProfilePicture(_ urlString: String) {
        guard let url = URL(string: urlString) else {
             print("Invalid URL")
             return
         }
         
        // Create a URLSessionDataTask to fetch the image data from the URL
        // Create a URLSessionDataTask to fetch the image data from the URL
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            // Check for response status code
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            // Check if data is available
            guard let imageData = data else {
                print("No data received")
                return
            }
            
            // Convert the downloaded data into a UIImage
            if let image = UIImage(data: imageData) {
                // Update the profileImageView with the downloaded image
                DispatchQueue.main.async {
                    self.profilePicture.image = image
                    print("Successfully retrieved and set profile picture")
                }
            } else {
                print("Failed to create image from data")
            }
        }
        
        // Start the URLSessionDataTask
        task.resume()
    }
    
    @IBAction func changePictureButtonPressed(_ sender: Any) {
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
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            imagePickerController.cameraCaptureMode = .photo
            present(imagePickerController, animated: true, completion: nil)
            dismissModalView()
        } else {
            // If no camera is available, pop up an alert
            let alertVC = UIAlertController(
                title: "No camera",
                message: "Sorry, this device doesn't have a camera",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style: .default)
            alertVC.addAction(okAction)
            present(alertVC,animated:true)
        }
    }
    
    @objc func accessGalleryButtonPressed() {
        // Implement functionality to access the photo gallery
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [UTType.image.identifier]
        present(imagePickerController, animated: true, completion: nil)
        dismissModalView()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            if let selectedImage = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.profilePicture.image = selectedImage
                    self.uploadImageToFirebaseStorage(selectedImage)
                }
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func deletePhotoButtonPressed() {
       // Implement functionality to delete the current photo and replace it with the default image
       profilePicture.image = defaultImage
       let db = Firestore.firestore()
       let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
       userRef.updateData(["profileImageURL": ""]) { error in
           if let error = error {
               print("Error updating profile picture URL: \(error.localizedDescription)")
           } else {
               print("Profile picture URL deleted successfully")
           }
       }
       dismissModalView()
   }
    
    func uploadImageToFirebaseStorage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data")
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        
        // Create a reference to the image in the user's folder
        guard let userStorageRef = userStorageRef else {
            print("User storage reference is nil")
            return
        }
        
        let imageRef = userStorageRef.child(imageName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                return
            }
            
            // Image uploaded successfully
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                print("Image uploaded to Firebase Storage")
                // Save download URL to Firestore
                self.updateProfilePictureURL(downloadURL)
            }
        }
    }

    func updateProfilePictureURL(_ downloadURL: URL) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(currentUser.uid)
        
        userRef.updateData(["profileImageURL": downloadURL.absoluteString]) { error in
            if let error = error {
                print("Error updating profile picture URL: \(error.localizedDescription)")
            } else {
                print("Profile picture URL updated successfully: ", downloadURL.absoluteString)
            }
        }
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
