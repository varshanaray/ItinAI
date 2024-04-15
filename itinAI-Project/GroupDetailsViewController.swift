// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class GroupDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var detailsImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var descript: UITextView!
    
    var groupProfilePics = [UIImage?]()
    var displayNames = [String?]()
    var group:Group?
    
    let imagePicker = UIImagePickerController()
    
    let storage = Storage.storage()
    var groupImagesRef: StorageReference!
    var groupStorageRef: StorageReference!
    var currentGroupImageURL: String!
    var receivedImage: UIImage? // Property to receive the image data

    var thisGroup: Group? {
        // Reload table whenever thisGroup is updated
        didSet {
            tableView?.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        groupNameLabel.text = group?.groupName
        groupCodeLabel.text = "Group Code: " + group!.groupCode
        detailsImage.image = UIImage(named: "japan")
        descript.delegate = self
        descript.allowsEditingTextAttributes = true
        // Get saved description from Firestore
        let db = Firestore.firestore()
        let groupId = group?.groupCode
        db.collection("Groups").document(groupId!).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                // Document found, retrieve description
                let description = document.data()?["description"] as? String ?? "Edit Here"
                descript.text = description
                print("Description: \(description)")
            } else {
                // Document does not exist or there was an error
                print("Document does not exist or there was an error")
            }
        }
        
        // Add tap gesture recognizer to the image view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        detailsImage.addGestureRecognizer(tapGestureRecognizer)
        detailsImage.isUserInteractionEnabled = true
        imagePicker.delegate = self
        
        groupImagesRef = storage.reference().child("GroupImages")
        groupStorageRef = groupImagesRef.child(group!.groupCode)
        
        if let image = receivedImage {
            detailsImage.image = image // Set the received image to the destination image view
        } else {
            retrieveGroupImage()
        }
    }
    
    // Action method to handle tap on the image view
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        // Open the camera roll or perform any action you desire
        openCameraRoll()
    }

    // Function to open the camera roll
    func openCameraRoll() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("inside imagePickerController, didFinishPickingMediaWithInfo")
        // Get the selected image from the info dictionary
        if let selectedImage = info[.originalImage] as? UIImage {
            // Set the selected image as the group image
            detailsImage.image = selectedImage
            print("Selected image is new group image")
            uploadImageToFirebaseStorage(detailsImage.image!)
        } else {
            print("failure to select and set image")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func retrieveGroupImage() {
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(group!.groupCode)
        
        groupRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let groupImageURL = document.get("groupImageURL") as? String {
                    // Profile picture URL found in Firestore
                    // Profile picture URL found in Firestore
                    if (self.currentGroupImageURL != groupImageURL) {
                        self.downloadGroupImage(groupImageURL)
                        self.currentGroupImageURL = groupImageURL
                    }
                    //self.downloadGroupImage(groupImageURL)
                } else {
                    print("Group image URL not found")
                    // Use default profile picture
                }
            } else {
                print("Group document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func downloadGroupImage(_ urlString: String) {
        print("Inside downloadGroupImage")
        print("The url retrieved is: \(urlString)")
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
                    self.detailsImage.image = image
                    print("Successfully retrieved and set group image")
                }
            } else {
                print("Failed to create image from data")
            }
        }
        
        // Start the URLSessionDataTask
        task.resume()
    }
    
    func uploadImageToFirebaseStorage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data")
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        
        // Create a reference to the image in the user's folder
        guard let groupStorageRef = self.groupStorageRef else {
            print("User storage reference is nil")
            return
        }
        
        let imageRef = groupStorageRef.child(imageName)
        
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
                self.updateGroupImageURL(downloadURL)
            }
        }
    }
    
    func updateGroupImageURL(_ downloadURL: URL) {
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(group!.groupCode)
        
        groupRef.updateData(["groupImageURL": downloadURL.absoluteString]) { error in
            if let error = error {
                print("Error updating group image URL: \(error.localizedDescription)")
            } else {
                print("Group image URL updated successfully: ", downloadURL.absoluteString)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupProfilePics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! CustomPeopleTableViewCell
        cell.name.text = displayNames[indexPath.row]
        cell.iconImageView.image = groupProfilePics[indexPath.row]
        return cell
    }

    func textViewDidChange(_ textView: UITextView) {
        saveTextToStorage(textView.text)
    }
    
    // Update description text in Firestore
    func saveTextToStorage(_ text: String) {
        let db = Firestore.firestore()
        let groupId = group?.groupCode

        db.collection("Groups").document(groupId!).setData([
            "description": descript.text!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
}
