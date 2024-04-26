// Project: itinAI-Beta
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UniformTypeIdentifiers

class GroupPageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var announceCell: UITableViewCell!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    // @IBOutlet weak var announcementsTableView: UITableView!
    @IBOutlet weak var collectionViewPeople: UICollectionView!
    @IBOutlet weak var addCitiesButton: UIButton!
    
    @IBOutlet weak var announceName: UILabel!
    @IBOutlet weak var announceImage: UIImageView!
    @IBOutlet weak var announceMessage: UIButton!
    
    var group:Group?
    var groupProfilePics = [UIImage?]()
    var profilePicsURLs = [String?]()
    var displayNames = [String?]()
    var thisGroupUsers = [User?]()
    var overlayView: UIView = UIView()
    var citiesModalView: UIView = UIView()
    let modalHeight: CGFloat = 430
    let surveyDeadlinePicker = UIDatePicker()
    var lastAnnouncement: Announcements = Announcements(user: "", userImageURL: "", subject: "", message: "", timestamp: Date())
    var datesAreValid: Bool?
    
    var currentModalView: UIView!
    
    var cityList: [City?] = []
    
    let imagePicker = UIImagePickerController()
    
    let storage = Storage.storage()
    var groupImagesRef: StorageReference!
    var groupStorageRef: StorageReference!
    var citiesStorageRef: StorageReference!
    var currentGroupImageURL: String!
    var imageToPass: UIImage? // Property to store the image data
    var currentEditingCityIndexPath: IndexPath?
    var currentEditingCityId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewPeople.delegate = self
        collectionViewPeople.dataSource = self
        collectionViewPeople.backgroundColor = UIColor(named: "CustomBackground")
        collectionViewPeople.allowsSelection = false
        collectionViewPeople.isScrollEnabled = true
        // Assuming you have already set up your collectionView
        if let layout = collectionViewPeople.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        contentView.layer.cornerRadius = 15
        
        groupNameLabel.text = group?.groupName
        groupNameLabel.font = UIFont(name: "Poppins-Bold", size: 30)
        groupNameLabel.textColor = .white
        groupNameLabel.setCharacterSpacing(-1.5)
        groupNameLabel.shadowColor = .black
        groupNameLabel.shadowOffset = CGSize(width: 1, height: 1)
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        citiesTableView.layer.cornerRadius = 15
        citiesTableView.layer.borderWidth = 1
        citiesTableView.layer.borderColor = UIColor(named: "CustomDarkGrey")?.cgColor
        citiesTableView.backgroundColor = UIColor(named: "CustomBackground")
        
        groupImagesRef = storage.reference().child("GroupImages")
        groupStorageRef = groupImagesRef.child(group!.groupCode)
        citiesStorageRef = storage.reference().child("CityImages")
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        
        
        announceCell.layer.cornerRadius = 15
        announceCell.layer.borderWidth = 1
        // CustomDarkGrey
        announceCell.layer.borderColor = UIColor(named: "CustomDarkGrey")?.cgColor
        
        let imageSize: CGFloat = 50
        announceImage.image = UIImage(named: "defaultProfilePicture")
        announceImage.frame = CGRect(x: 20, y: 20, width: imageSize, height: imageSize)
        // Set the corner radius to make image circular
        announceImage.layer.cornerRadius = imageSize / 2
        announceImage.clipsToBounds = true
        announceMessage.setTitle("No announcments yet!", for: .normal)
        announceName.text = ""
        
        // Get from firestore
        print("group code!: ", (group?.groupCode)!)
        fetchUsers(groupCode: (group?.groupCode)!)
        
        print("City list in ViewDidLoad:")
        for city in cityList {
            print("  city name: ", city?.name)
        }
        
        fetchCities()
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        fetchCitiesAndScheduleReminders(forGroupCode: group!.groupCode)
        // fetchLastAnnouncement()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        // Add tap gesture recognizer to the cell
        announceCell.addGestureRecognizer(tapGesture)
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        self.navigateToAnnouncements(group: group!)
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& viewWillAppear called")
    //        fetchLastAnnouncement()
    //    }
    
    func fetchLastAnnouncement() {
        print("IN FETCH LAST ANNOUNCEMT -------------------------------")
        let db = Firestore.firestore()
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
            
            if let announcementsData = groupDoc.data()?["announcements"] as? [[String: Any]], !announcementsData.isEmpty {
                let lastAnnouncementDict = announcementsData.last! // Get the last announcement from the list
                
                // Assuming you have a model set up to configure your cell
                if let user = lastAnnouncementDict["user"] as? String,
                   let userImageURL = lastAnnouncementDict["userImageURL"] as? String,
                   let subject = lastAnnouncementDict["subject"] as? String,
                   let message = lastAnnouncementDict["announcement"] as? String,
                   let timestamp = lastAnnouncementDict["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue() // Convert Timestamp to Date
                    let lastAnnouncement = Announcements(user: user, userImageURL: userImageURL, subject: subject, message: message, timestamp: date)
                    
                    // Store this last announcement in a property
                    self.lastAnnouncement = lastAnnouncement
                    
                    DispatchQueue.main.async {
                        print("about to update announce")
                        print("last announce", lastAnnouncement.message)
                        self.updateAnnounceCell(lastAnnouncement: lastAnnouncement)
                    }
                }
            } else {
                print("No announcements found in the group document.")
            }
        }
    }
    
    func updateAnnounceCell(lastAnnouncement: Announcements) {
        print("in updateAnnounceCell")
        announceName.text = lastAnnouncement.user
        announceImage.contentMode = .scaleAspectFill
        announceImage.clipsToBounds = true
        announceImage.setImage(with: lastAnnouncement.userImageURL, placeholder: UIImage(named: "defaultProfilePicture"), fallbackImage: UIImage(named: "defaultProfilePicture"))
        var messageDisplayed = lastAnnouncement.message
        if lastAnnouncement.message.count > 35 {
            let index = lastAnnouncement.message.index(lastAnnouncement.message.startIndex, offsetBy: 35)
            messageDisplayed = String(lastAnnouncement.message.prefix(upTo: index)) + "..."
        }
        announceMessage.setTitle(messageDisplayed, for: .normal)
        announceMessage.setTitleColor(.black, for: .normal)
        // Allow multiple lines
        // announceMessage.titleLabel?.numberOfLines = 1
        // Add an ellipsis if the text exceeds the width of the button
        // announceMessage.titleLabel?.lineBreakMode = .byTruncatingTail
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchLastAnnouncement()
        retrieveGroupImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func retrieveGroupImage() {
        let db = Firestore.firestore()
        let userRef = db.collection("Groups").document(group!.groupCode)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let groupImageURL = document.get("groupImageURL") as? String {
                    // Profile picture URL found in Firestore
                    if (self.currentGroupImageURL != groupImageURL) {
                        //self.downloadGroupImage(groupImageURL)
                        self.imageView.setImage(with: groupImageURL, fallbackImage: UIImage(named: "scene"))
                        self.imageToPass = self.imageView.image
                        self.currentGroupImageURL = groupImageURL
                    }
                    //self.downloadGroupImage(groupImageURL)
                } else {
                    print("Profile image URL not found")
                    // Use default profile picture
                }
            } else {
                print("User document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
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
                    self.imageView.image = image
                    print("Successfully retrieved and set group image")
                    self.imageToPass = image
                }
            } else {
                print("Failed to create image from data")
            }
        }
        
        // Start the URLSessionDataTask
        task.resume()
    }
    
    @IBAction func announceClicked(_ sender: Any) {
        //self.navigateToAnnouncements(group: group!)
    }
    
    func navigateToAnnouncements(group: Group) {
        print("segue to announcements")
        if let announceVC = self.storyboard?.instantiateViewController(withIdentifier: "AnnounceVCID") as? AnnounceViewController {
            announceVC.group = group
            self.navigationController?.pushViewController(announceVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("CITY COUNT: ", cityList.count)
        return 1 //cityList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        
        let newWidth = cell.contentView.frame.width * 0.5
        let margin = (cell.contentView.frame.width - newWidth) / 2.0
        
        //cell.contentView.frame = CGRect(x: margin, y: 0, width: newWidth, height: cell.contentView.frame.height)
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        //cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // Get the city name for the current row.
        let thisCity = cityList[indexPath.section]
        
        // Set the city name to the cell's text label.
        cell.layer.cornerRadius = 15
        cell.cityNameLabel?.text = thisCity!.name.uppercased()
        cell.cityNameLabel?.setCharacterSpacing(-1.5)
        cell.cityNameLabel?.shadowColor = .black
        cell.cityNameLabel?.shadowOffset = CGSize(width: 1, height: 1)
        
        var currentURL = thisCity!.cityImageURL
        cell.cityImageView?.setImage(with: currentURL, fallbackImage: UIImage(named: "f"))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        let groupCode = group?.groupCode ?? ""
        let cityName = cityList[indexPath.section]?.name ?? ""
        //let cityImageURL = cityList[indexPath.section]?.cityImageURL
        //let cityImage = (citiesTableView.cellForRow(at: indexPath)?.imageView?.image)!
        
        let cityId = "\(groupCode)\(cityName)"
        print("City ID:", cityId)
        let cityRef = db.collection("Cities").document(cityId)
        
        cityRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("City document does not exist")
                return
            }
            
            if let deadlineTimestamp = document.data()?["deadline"] as? Timestamp {
                let deadlineDate = deadlineTimestamp.dateValue()
                if Date() >= deadlineDate {
                    // Deadline has passed, check if itinerary is generated
                    self.checkIfItineraryGenerated(cityId: cityId) { isGenerated in
                        if isGenerated {
                            // If generated, segue to Itinerary page directly
                            self.navigateToItineraryPage(cityId: cityId, cityName: cityName)
                        } else {
                            // If not generated, generate itinerary first
                            self.showLoadingOverlay() // Show a loading indicator to the user
                            
                            self.generateItinerary(cityId: cityId) { success in
                                self.hideLoadingOverlay() // Hide the loading indicator
                                
                                if success {
                                    self.navigateToItineraryPage(cityId: cityId, cityName: cityName)
                                } else {
                                    // Handle failure to generate itinerary
                                    print("Failed to generate itinerary")
                                }
                            }
                        }
                    }
                } else {
                    // Deadline not passed, segue to Survey page
                    self.navigateToSurveyPage(cityId: cityId, cityName: cityName)
                }
            } else {
                print("Issue finding deadline in Firestore")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func checkIfItineraryGenerated(cityId: String, completion: @escaping (Bool) -> Void) {
        print("calling checkIfItineraryGenerated")
        let db = Firestore.firestore()
        db.collection("Cities").document(cityId).collection("ItineraryDays").limit(to: 1).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error checking itinerary generation: \(err)")
                completion(false)
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func generateItinerary(cityId: String, completion: @escaping (Bool) -> Void) {
        print("calling generateItinerary")
        Task {
            let success = await fetchSurveyResponsesAndGenerate(cityDocId: cityId)
            completion(success)
        }
    }
    
    func showLoadingOverlay() {
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.tag = 100 // Arbitrary tag to identify the overlay later
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = overlay.center
        overlay.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.addSubview(overlay)
        self.view.isUserInteractionEnabled = false // Disables interaction with the underlying view
    }
    
    func hideLoadingOverlay() {
        if let overlay = self.view.viewWithTag(100) {
            overlay.removeFromSuperview()
        }
        self.view.isUserInteractionEnabled = true // Re-enables interaction
    }
    
    
    func navigateToItineraryPage(cityId: String, cityName: String) {
        if let itineraryVC = self.storyboard?.instantiateViewController(withIdentifier: "ItineraryVCID") as? ItineraryPageVC {
            print("segueing to itinerary page")
            itineraryVC.cityId = cityId
            itineraryVC.cityName = cityName
            //itineraryVC.cityImage = cityImage
            self.navigationController?.pushViewController(itineraryVC, animated: true)
        }
    }
    
func navigateToSurveyPage(cityId: String, cityName: String) {
        print("segue to survey")
        if let surveyVC = self.storyboard?.instantiateViewController(withIdentifier: "SurveyVCID") as? SurveyPageVC {
            surveyVC.cityId = cityId
            surveyVC.cityName = cityName
            //surveyVC.cityImage = cityImage
            self.navigationController?.pushViewController(surveyVC, animated: true)
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        print("add button pressed!")
        setupCitiesModalView(title: "Add A City")
        currentModalView = citiesModalView
        animateModalView()
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
    
    func fetchCities() {
        print("fetchCities() called")
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document((group?.groupCode)!)
        
        groupRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Group document does not exists")
                return
            }
            self.cityList = []
            if let cityRefs = document.data()?["cityList"] as? [DocumentReference] {
                let dispatchGroup = DispatchGroup()
                for cityRef in cityRefs {
                    dispatchGroup.enter()
                    print("cityRefs found")
                    cityRef.getDocument { (cityDoc, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        print("type of deadline: " ,type(of: cityDoc?.get("deadline")))
                        print("type of citydoc: ", type(of: cityDoc))
                        if let cityDoc = cityDoc, cityDoc.exists, let cityName =  cityDoc.data()?["cityName"] as? String,
                           let deadline = cityDoc.data()?["deadline"] as? Timestamp,
                           let startDate = cityDoc.data()?["startDate"] as? Timestamp,
                           let endDate = cityDoc.data()?["endDate"] as? Timestamp {
                            print("start date value: ", startDate.dateValue())
                            print("start type: ", type(of: startDate.dateValue()))
                            let cityImageURL = cityDoc.data()?["cityImageURL"] as? String
                            let city = City(name: cityName, startDate: startDate.dateValue(), endDate: endDate.dateValue(), deadline: deadline.dateValue(), imageURL: cityImageURL ?? "default")
                            self.cityList.append(city)
                            print("Appended to city list in fetchCities, leng of cityList: ", self.cityList.count)
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    print("Printing city after fetching cityRefs")
                    for city in self.cityList {
                        print("HELLOOOOOOOOOOOOOOO")
                        print(city?.name)
                    }
                    self.citiesTableView.reloadData()
                }
                
            }
        }
    }
    
    
    func setupCitiesModalView(title: String) {
        var modalTitle: String = ""
        let leftMargin: CGFloat = 20.0
        
        // Add a view for a darkened background
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0.0 // Initially Invisible
        view.addSubview(overlayView)
        
        // Add a tap gesture recognizer to overlayView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        // Create modal view
        citiesModalView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: modalHeight))
        //citiesModalView.backgroundColor = .white
        citiesModalView.backgroundColor = UIColor(named: "CustomBackground")
        citiesModalView.layer.cornerRadius = 15
        citiesModalView.layer.masksToBounds = true
        view.addSubview(citiesModalView)
        
        // Constraints for citiesModalView
        NSLayoutConstraint.activate([
            citiesModalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesModalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesModalView.heightAnchor.constraint(equalToConstant: modalHeight),
            citiesModalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create and configure titleLabel
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        titleLabel.text = "Add City" // Set the title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        citiesModalView.addSubview(titleLabel)
        
        // Constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: citiesModalView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20)
        ])
        
        // Add destination label
        let destinationLabel = UILabel()
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.text = "Destination"
        destinationLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        //destinationLabel.textColor = .black
        destinationLabel.textColor = UIColor(named: "CustomOutlineText")
        citiesModalView.addSubview(destinationLabel)
        
        NSLayoutConstraint.activate([
            destinationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            destinationLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            destinationLabel.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20),
        ])
        
        // Add destination text field
        let destinationTextField = UITextField()
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        destinationTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2) // Light grey background
        destinationTextField.layer.cornerRadius = 10 // Rounded corners
        destinationTextField.layer.masksToBounds = true
        destinationTextField.placeholder = "Enter city name"
        
        // Adjusting placeholder text size
        let placeholderText = "Enter city name"
        let placeholderAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), // Adjust font size as needed
            NSAttributedString.Key.foregroundColor: UIColor.darkGray // Optional: Adjust placeholder text color
        ]
        destinationTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        
        // Adding left padding to the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: destinationTextField.frame.height))
        destinationTextField.leftView = paddingView
        destinationTextField.leftViewMode = .always
        
        citiesModalView.addSubview(destinationTextField)
        
        NSLayoutConstraint.activate([
            destinationTextField.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 5),
            destinationTextField.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            destinationTextField.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20),
            destinationTextField.heightAnchor.constraint(equalToConstant: 40) // Fixed height for the text field
        ])
        
        // Survey Deadline label
        let surveyDeadlineLabel = UILabel()
        surveyDeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        surveyDeadlineLabel.text = "Survey Deadline"
        surveyDeadlineLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        //surveyDeadlineLabel.textColor = .black
        surveyDeadlineLabel.textColor = UIColor(named: "CustomOutlineText")
        citiesModalView.addSubview(surveyDeadlineLabel)
        
        NSLayoutConstraint.activate([
            surveyDeadlineLabel.topAnchor.constraint(equalTo: destinationTextField.bottomAnchor, constant: 20),
            surveyDeadlineLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20)
        ])
        
        surveyDeadlinePicker.translatesAutoresizingMaskIntoConstraints = false
        surveyDeadlinePicker.datePickerMode = .dateAndTime
        citiesModalView.addSubview(surveyDeadlinePicker)
        
        NSLayoutConstraint.activate([
            surveyDeadlinePicker.topAnchor.constraint(equalTo: surveyDeadlineLabel.bottomAnchor, constant: 5),
            surveyDeadlinePicker.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20), // Left-aligned
            //surveyDeadlinePicker.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        // Trip Dates Label
        let tripDatesLabel = UILabel()
        tripDatesLabel.translatesAutoresizingMaskIntoConstraints = false
        tripDatesLabel.text = "Trip Dates"
        tripDatesLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        //tripDatesLabel.textColor = .black
        tripDatesLabel.textColor = UIColor(named: "CustomOutlineText")
        citiesModalView.addSubview(tripDatesLabel)
        
        NSLayoutConstraint.activate([
            tripDatesLabel.topAnchor.constraint(equalTo: surveyDeadlinePicker.bottomAnchor, constant: 20),
            tripDatesLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            tripDatesLabel.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20)
        ])
        
        let startDatePicker = UIDatePicker()
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        startDatePicker.datePickerMode = .date
        citiesModalView.addSubview(startDatePicker)
        
        NSLayoutConstraint.activate([
            startDatePicker.topAnchor.constraint(equalTo: tripDatesLabel.bottomAnchor, constant: 5),
            startDatePicker.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20), // Left-aligned
            //startDatePicker.widthAnchor.constraint(equalToConstant: 200) // Match width with the existing date picker
        ])
        
        // To label between start and end date pickers
        let toLabel = UILabel()
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.text = "to"
        toLabel.font = UIFont(name: "Poppins", size: 16)
        //toLabel.textColor = .black
        toLabel.textColor = UIColor(named: "CustomOutlineText")
        citiesModalView.addSubview(toLabel)
        
        NSLayoutConstraint.activate([
            toLabel.centerYAnchor.constraint(equalTo: startDatePicker.centerYAnchor),
            toLabel.leadingAnchor.constraint(equalTo: startDatePicker.trailingAnchor, constant: 10)
        ])
        
        // End date picker
        let endDatePicker = UIDatePicker()
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.datePickerMode = .date
        citiesModalView.addSubview(endDatePicker)
        
        NSLayoutConstraint.activate([
            endDatePicker.topAnchor.constraint(equalTo: startDatePicker.topAnchor),
            endDatePicker.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor, constant: 10), // Positioned to the right of "to" label
        ])
        
        // Create done button for this modal view
        let citiesDoneButton = ProfileDoneButton()
        citiesDoneButton.typeOfButton = .cities
        citiesDoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        citiesDoneButton.citiesDoneCallback = { [weak self] in
            print("cities done callback")
            guard let self = self else { return }
            
            let startDate = startDatePicker.date.timeIntervalSince1970
            let endDate = endDatePicker.date.timeIntervalSince1970
            let deadline = surveyDeadlinePicker.date.timeIntervalSince1970
            
            print("The deadline date is: \(deadline)")
            print("The start date is: \(startDate)")
            print("The end date is: \(endDate)")
            
            datesAreValid = validateDates(startDate: startDate, endDate: endDate, deadline: deadline)
            // Validate the selected dates
            if !self.datesAreValid! {
                return
            }
            
            self.handleCityCreation(name: destinationTextField.text!, startDate: startDatePicker, endDate: endDatePicker, deadline: surveyDeadlinePicker)
        }
        
        citiesDoneButton.dismissCallback = {
            // Dismiss modal view
            if !self.datesAreValid! {
                return
            }
                
            self.dismissModalView()
        }
        
        citiesModalView.addSubview(citiesDoneButton)
        
        NSLayoutConstraint.activate([
            citiesDoneButton.centerXAnchor.constraint(equalTo: citiesModalView.centerXAnchor),
            citiesDoneButton.bottomAnchor.constraint(equalTo: citiesModalView.bottomAnchor, constant: -40),
            citiesDoneButton.heightAnchor.constraint(equalToConstant: 50),
            citiesDoneButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func validateDates(startDate: TimeInterval, endDate: TimeInterval, deadline: TimeInterval) -> Bool {
        let currentDate = Date().timeIntervalSince1970
        print(currentDate)
        // Check if any date is in the past
        if startDate < currentDate - 10 || endDate < currentDate - 10 || deadline < currentDate - 10 {
            presentAlert(title: "Invalid Date", message: "Please ensure all dates are not set in the past.")
            return false
        }
        
        // Check if the deadline is the earliest date
        if deadline > startDate || deadline > endDate {
            presentAlert(title: "Invalid Deadline", message: "Deadline should be earlier than both the start and end dates.")
            return false
        }
        
        // Check if the start date is before the end date
        if startDate > endDate {
            presentAlert(title: "Invalid Date Range", message: "End date cannot be earlier than the start date.")
            return false
        }

        return true
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func handleCityCreation(name: String, startDate: UIDatePicker, endDate: UIDatePicker, deadline: UIDatePicker) {
        let db = Firestore.firestore()
        let cityId = group!.groupCode + name
        let startTimestamp = Timestamp(date: startDate.date)
        let endTimestamp = Timestamp(date: endDate.date)
        let deadlineTimestamp = Timestamp(date: deadline.date)
        print("CITY ID: ", cityId)
        // append to user's groupList
        // let cityRef = db.collection("Cities").document(cityId)
        db.collection("Cities").document(cityId).setData([
            "cityName": name,
            "startDate": startTimestamp,
            "endDate": endTimestamp,
            "deadline": deadlineTimestamp
            //"userList": [Auth.auth().currentUser!.uid]
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let cityRef = db.collection("Cities").document(cityId)
        let groupRef = db.collection("Groups").document((group?.groupCode)!)
        groupRef.updateData([
            "cityList": FieldValue.arrayUnion([cityRef])
        ])  { error in
            if let error = error {
                print("Error updating group document with new city: \(error)")
            } else {
                self.fetchCities()
                print("City reference added to group successfully")
            }
        }
        
        self.scheduleNotificationsIfNeeded(groupCode: self.group!.groupCode, groupName: self.group!.groupName, cityName: name, deadline: deadline.date)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Dismiss the modal view
        dismissModalView()
    }
    
    @objc func selectDateButtonTapped() {
        let selectedDate = surveyDeadlinePicker.date
        // Use selectedDate as needed, e.g., display it below the label
    }
    
    func fetchUsers(groupCode: String) {
        print("fetchusers() called")
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(groupCode)
        
        groupRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Group document does not exists")
                return
            }
            if let userRefs = document.data()?["userList"] as? [DocumentReference] {
                print("User doc is there")
                let dispatchGroup = DispatchGroup()
                for userRef in userRefs {
                    dispatchGroup.enter()
                    print("userRefs found")
                    userRef.getDocument { (userDoc, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let userDoc = userDoc, userDoc.exists, let email =  userDoc.data()?["email"] as? String, let name =  userDoc.data()?["name"] as? String, let profileImageURL = userDoc.data()?["profileImageURL"] {
                            //let user = User(email: email, displayName: name, profileImageUrl: "")
                            print("!!! name: ", name)
                            self.displayNames.append(name)
                            var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
                            self.profilePicsURLs.append(profileImageURL as? String ?? "")
                            self.groupProfilePics.append(thisImage)
                            print("group profile pics count: ", self.groupProfilePics.count)
                        } else {
                            print("User document does not exists in User")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    print("reload collection view for people")
                    self.collectionViewPeople.reloadData()
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: ", groupProfilePics.count)
        return groupProfilePics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        //cell.userImageView.image = groupProfilePics[indexPath.row]
        var currentURL = self.profilePicsURLs[indexPath.row]
        //cell.userImageView.clipsToBounds = true
        cell.userImageView.contentMode = .scaleAspectFill
        
        DispatchQueue.main.async {
            cell.userImageView.setImage(with: currentURL!, fallbackImage: UIImage(named: "defaultProfilePicture"))
        }
        
        
        //cell.userImageView.clipsToBounds = true
        //cell.userDisplayLabel.text = displayNames[indexPath.row]
        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare to segue to Details page
        if segue.identifier == "GroupToDetails",
           let destination = segue.destination as? GroupDetailsViewController
        {
            destination.groupProfilePics = groupProfilePics
            destination.displayNames = displayNames
            destination.group = group
            destination.receivedImage = imageToPass
            destination.currentGroupImageURL = self.currentGroupImageURL
            destination.profilePicsURLs = self.profilePicsURLs
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Create an action for editing the city image
        let editAction = UIContextualAction(style: .normal, title: "Edit Image") { [weak self] (action, view, completionHandler) in
            self?.editCityImage(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        // Create an action for deleting the city
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteCity(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        // Combine actions into a swipe actions configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
    func deleteCity(at indexPath: IndexPath) {
        let cityName = cityList[indexPath.section]?.name
        let cityId = group!.groupCode + cityName!
        let db = Firestore.firestore()
        
        // Remove city from Firestore document in Groups collection
        let groupDocRef = db.collection("Groups").document("groupCode")
        groupDocRef.updateData([
            "cityList": FieldValue.arrayRemove([cityId])
        ])
        
        // Delete the city document from Cities collection
        db.collection("Cities").document(cityId).delete { error in
            if let error = error {
                print("Error deleting city: \(error)")
            } else {
                print("City successfully deleted")
                DispatchQueue.main.async {
                    self.cityList.remove(at: indexPath.section)
                    let indexSet = IndexSet(arrayLiteral: indexPath.section)
                    
                    self.citiesTableView.deleteSections(indexSet, with: .automatic)
                }
            }
        }
    }
    
    func editCityImage(at indexPath: IndexPath) {
        let cityName = cityList[indexPath.section]?.name
        let cityId = group!.groupCode + cityName!
        currentEditingCityIndexPath = indexPath
        currentEditingCityId = group!.groupCode + cityName!
        
        print("Initiate edit for city image: \(cityName)")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [UTType.image.identifier]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            uploadImageToFirebaseStorage(selectedImage)

        }
    }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        

        
        
    func uploadImageToFirebaseStorage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data")
            return
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        
        // Create a reference to the image in the user's folder
        guard let citiesStorageRef = citiesStorageRef else {
            print("Cities storage reference is nil")
            return
        }
        
        let imageRef = citiesStorageRef.child(imageName)
        
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
                self.updateCityPictureURL(downloadURL)
            }
        }
    }
        
        
    func updateCityPictureURL(_ downloadURL: URL) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        let db = Firestore.firestore()
        let cityRef = db.collection("Cities").document(currentEditingCityId!)
        
        cityRef.updateData(["cityImageURL": downloadURL.absoluteString]) { error in
            if let error = error {
                print("Error updating city picture URL: \(error.localizedDescription)")
            } else {
                print("City picture URL updated successfully: ", downloadURL.absoluteString)
                self.fetchCities()
            }
        }
    }
    
    func fetchCitiesAndScheduleReminders(forGroupCode groupCode: String) {
        
        print("Attempting to schedule reminders for cities")
        let db = Firestore.firestore()
        
        // Reference to the group document in the Groups collection
        let groupDocRef = db.collection("Groups").document(groupCode)
        
        // Fetch the document
        groupDocRef.getDocument { (document, error) in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching group: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Check if the cityList array exists
            guard let cityRefs = document.data()?["cityList"] as? [DocumentReference] else {
                print("No cities found for this group.")
                return
            }
            
            // Iterate through each cityId and fetch corresponding city data
            for cityRef in cityRefs {
                cityRef.getDocument { (cityDoc, error) in
                    guard let cityDoc = cityDoc, cityDoc.exists, error == nil else {
                        print("Error fetching city data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // Extract cityName and deadline from the city document
                    guard let cityName = cityDoc.data()?["cityName"] as? String,
                          let deadlineTimestamp = cityDoc.data()?["deadline"] as? Timestamp else {
                        print("City data is incomplete or improperly formatted.")
                        return
                    }
                    
                    let deadlineDate = deadlineTimestamp.dateValue()
                    
                    // Call the function to schedule reminders
                    self.scheduleNotificationsIfNeeded(groupCode: self.group!.groupCode, groupName: self.group!.groupName, cityName: cityName, deadline: deadlineDate)
                }
            }
        }
    }

    func hasNotificationBeenScheduled(groupCode: String, cityName: String, deadline: Date, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Construct the identifier from the groupCode and cityName
            let targetIdentifier = "\(groupCode)\(cityName)\(deadline.hashValue)"

            // Check if any request's identifier matches the targetIdentifier
            let hasScheduled = requests.contains { request in
                request.identifier == targetIdentifier
            }

            DispatchQueue.main.async {
                completion(hasScheduled)
            }
        }
    }

    func scheduleNotificationsIfNeeded(groupCode: String, groupName: String, cityName: String, deadline: Date) {
        
        //printAllPendingNotifications()
        
        hasNotificationBeenScheduled(groupCode: groupCode, cityName: cityName, deadline: deadline) { [weak self] alreadyScheduled in
            guard !alreadyScheduled else {
                print("\(groupName) \(cityName) notifications are already scheduled.")
                return
            }
            scheduleSurveyDeadlineReminders(groupCode: groupCode, groupName: groupName, cityName: cityName, deadline: deadline)
        }
    }
    
    
}
