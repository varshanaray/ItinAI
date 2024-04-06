// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfilePage: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicture: CircularProfilePicture!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var changePictureButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    var overlayView: UIView = UIView()
    
    let modalHeight: CGFloat = 300
    var createModalView: UIView!
    
    // modal view for Join
    var joinModalView: UIView!
    
    // modal view for Change Picture
    var pictureModalView: UIView!
    
    // modal view for Reset password
    var resetModalView: UIView!
    
    var currentModalView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultImage = UIImage(named: "defaultProfilePicture")
        profilePicture.image = defaultImage
        
        // Change Picture button
        changePictureButton.setTitle("", for: .normal)
        
        // Reset Password button
        resetPasswordButton.setTitle("Reset password", for: .normal)
        
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
    
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        print("Reset button pressed")
        currentModalView = resetModalView
        //animateModalView()
    }
    
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        print("Change picture button pressed")
        currentModalView = pictureModalView
        //animateModalView()
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
    
    func animateModalView() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1.0
            self.currentModalView.frame.origin.y = self.view.frame.height - self.modalHeight
        }
    }
    
    // TODO: - Handle tapping outside of keyboard to dismiss it without dismissing the modal view
   func textFieldShouldReturn(_ textField:UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
   }
}
