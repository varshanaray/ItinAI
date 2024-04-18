// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AnnounceViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    var time = Date()
    
    @IBOutlet weak var announceTableView: UITableView!
    
        
    var allAnnouncements: [Announcements?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        announceTableView.delegate = self
        announceTableView.dataSource = self
        announceTableView.allowsSelection = false
//        announceTableView.rowHeight = UITableView.automaticDimension
//        announceTableView.estimatedRowHeight = UITableView.automaticDimension
        // announceTableView.rowHeight = 100
//        announceTableView
        //announceTableView.rowHeight = UITableView.automaticDimension
        //announceTableView.estimatedRowHeight = 300
        announceTableView.rowHeight = UITableView.automaticDimension
            //announceTableView.estimatedRowHeight = 100
        
    }
    
    
    @IBAction func addClicked(_ sender: Any) {
        print("Add button pressed")
        let buttonTitle = addAnnounce.title(for: .normal) ?? ""
        setupCreateModalView(title: buttonTitle)
        currentModalView = createModalView
        animateModalView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear called")
        fetchAnnouncements()
        self.announceTableView.reloadData()
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
       
           time = Date()
           
           let db = Firestore.firestore()
               
               // Fetch user data
               db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                   if let document = document, document.exists {
                       let userName = document.data()?["name"] as? String ?? "Unknown User"
                       let userImageURL = document.data()?["profileImageURL"] as? String ?? "Unknown URL"
                       
                       // Proceed with adding the announcement
                       let announcementData: [String: Any] = [
                           "user": userName,  // Add the user's name to the announcement data
                           "userImageURL": userImageURL,
                           "subject": subject,
                           "announcement": announcement,
                           "timestamp": self.time
                       ]
                       
                       // Adding the announcement to the group's announcements array
                       db.collection("Groups").document((self.group?.groupCode)!).updateData([
                           "announcements": FieldValue.arrayUnion([announcementData])
                       ]) { error in
                           if let error = error {
                               print("Error adding announcement: \(error)")
                           } else {
                               self.fetchAnnouncements()
                               print("Announcement added successfully to the group with user name.")
                           }
                       }
                   } else {
                       print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                   }
               }
       }
       
       func fetchAnnouncements() {
           print("fetchGroups() called")
           guard let currentUser = Auth.auth().currentUser else {
               print("No current user found")
               return
           }

           let db = Firestore.firestore()
           let userRef = db.collection("Users").document(currentUser.uid)
           
           userRef.getDocument { (document, error) in
               guard let document = document, document.exists else {
                   print("User document does not exist")
                   return
               }
               self.allAnnouncements = []
                   
               // Access the specific group directly by its code
               let groupRef = db.collection("Groups").document((self.group?.groupCode)!)
                   
               groupRef.getDocument { (groupDoc, error) in
                   let dispatchGroup = DispatchGroup()
                   dispatchGroup.enter()
                   if let error = error {
                       print("Error fetching group document: \(error)")
                       return
                   }
                       
                   guard let groupDoc = groupDoc, groupDoc.exists else {
                       print("Group document does not exist")
                       return
                   }
                       
                   self.allAnnouncements = [] // Clear existing announcements
                   if let announcementsData = groupDoc.data()?["announcements"] as? [[String: Any]] {
                       for announcementDict in announcementsData {
                           if let user = announcementDict["user"] as? String,
                              let userImageURL = announcementDict["userImageURL"] as? String,
                              let subject = announcementDict["subject"] as? String,
                              let message = announcementDict["announcement"] as? String,
                              let timestamp = announcementDict["timestamp"] as? Timestamp {
                               let date = timestamp.dateValue() // Convert Timestamp to Date
                               let announcement = Announcements(user: user, userImageURL: userImageURL, subject: subject, message: message, timestamp: date)
                               self.allAnnouncements.append(announcement)
                               // self.announceTableView.reloadData()
                           }
                       }
                       self.allAnnouncements = self.allAnnouncements.sorted(by: { (announcement1, announcement2) -> Bool in
                               guard let date1 = announcement1?.timestamp, let date2 = announcement2?.timestamp else {
                                   return false // Handle the case where one or both announcements are nil
                               }
                               return date1 > date2 // Sort in descending order based on the date
                           })
                       for announcement in self.allAnnouncements {
                           print(announcement?.message)
                       }
                       self.announceTableView.reloadData()
                       print("allAnnouncements loaded: \(self.allAnnouncements.count)")
                       // Assuming you have a UITableView to reload, called announceTableView
                       // self.announceTableView.reloadData()
                   } else {
                       print("No announcements found in the group document.")
                   }
                   
//                   dispatchGroup.notify(queue: .main) {
//                       for announcement in self.allAnnouncements {
//                           print(announcement?.message)
//                       }
//                       print("allAnnouncements loaded: \(self.allAnnouncements.count)")
//                       // Assuming you have a UITableView to reload, called announceTableView
//                       self.announceTableView.reloadData()
//                   }
               }
           }
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
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
      
    func numberOfSections(in tableView: UITableView) -> Int {
        return allAnnouncements.count
    }
      
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
      
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("here")
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnounceTableCell", for: indexPath) as! AnnouncementsTableViewCell
        let row = indexPath.section
        let userName = allAnnouncements[row]!.user
        let message = allAnnouncements[row]!.message
        let subject = allAnnouncements[row]!.subject
        let timestamp = allAnnouncements[row]!.timestamp
        cell.name.text = userName
        //cell.groupImageView.image = UIImage(named: "japan")
        // downloadGroupImage(groupImageURL, cell)
        cell.subject.text = subject
        let dateString = convertDateToString(date: timestamp)
        cell.time.text = dateString
        // print("name in cell", cell.name.text)
        cell.message.text = message
        cell.message.isScrollEnabled = false
        var currentURL = allAnnouncements[row]!.userImageURL
        //cell.userImageView.clipsToBounds = true
        cell.img.setImage(with: currentURL, placeholder: UIImage(named: "defaultProfilePicture"), fallbackImage: UIImage(named: "defaultProfilePicture"))
        cell.img.contentMode = .scaleAspectFill
        cell.img.clipsToBounds = true
        //cell.allowS = .none
        return cell
    }
       
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        // Example of a format: "yyyy-MM-dd HH:mm:ss"
        // You can adjust this format to meet your needs.
        formatter.dateFormat = "yyyy-MM-dd"
           
        // Optionally, you can set the locale or timezone if needed
        // formatter.locale = Locale(identifier: "en_US_POSIX")
        // formatter.timeZone = TimeZone(secondsFromGMT: 0)
           
        return formatter.string(from: date)
    }
    
}
    

        
            
 
