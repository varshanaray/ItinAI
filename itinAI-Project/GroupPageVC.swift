// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroupPageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
   // @IBOutlet weak var announcementsTableView: UITableView!
    @IBOutlet weak var collectionViewPeople: UICollectionView!
    @IBOutlet weak var addCitiesButton: UIButton!
    
    
    var group:Group?
    var groupProfilePics = [UIImage?]()
    var displayNames = [String?]()
    var thisGroupUsers = [User?]()
    var overlayView: UIView = UIView()
    var citiesModalView: UIView = UIView()
    let modalHeight: CGFloat = 400
    let surveyDeadlinePicker = UIDatePicker()
    
    var currentModalView: UIView!
    
    var cityList: [City?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewPeople.delegate = self
        collectionViewPeople.dataSource = self
        
        contentView.layer.cornerRadius = 20
        
        citiesTableView.layer.cornerRadius = 20
        citiesTableView.layer.borderWidth = 1
        citiesTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        
       // announcementsTableView.layer.cornerRadius = 20
        //announcementsTableView.layer.borderWidth = 1
        //announcementsTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        /*var numInGroup: Int = 0 //group?.userList.count ?? -1
        // If less than or equal to 0, do nothing
        if (numInGroup > 0) {
            for i in 0...(numInGroup - 1) {
                print("picture, i: ", i)
                // Default image until database is set up
                var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
                var thisName: String? = "" //group?.userList[i].email
                groupProfilePics.append(thisImage)
                displayNames.append(thisName)
                print("this Name: ", thisName)
            }
        } */
        
        // Get from firestore
        print("group code!: ", (group?.groupCode)!)
        fetchUsers(groupCode: (group?.groupCode)!)
        
        print("City list in ViewDidLoad:")
        for city in cityList {
            print("  city name: ", city?.name)
        }
        	
        fetchCities()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("CITY COUNT: ", cityList.count)
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesCell", for: indexPath)

        // Get the city name for the current row.
        let thisCity = cityList[indexPath.row]

        // Set the city name to the cell's text label.
        cell.textLabel?.text = thisCity!.name
        print("CITY TEXT: ", thisCity?.name)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        var groupCode = (group?.groupCode)!
        var cityName = (cityList[indexPath.row]?.name)!
        
        //var cityId = "\(group?.groupCode)  \(cityList[indexPath.row]?.name)"
        var cityId = groupCode + cityName
        print("city id: ", cityId)
        let cityRef =  db.collection("Cities").document(cityId)
        
        cityRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("City document does not exists")
                return
            }
            if let deadlineTimestamp = document.data()?["deadline"] as? Timestamp {
                var deadlineDate = deadlineTimestamp.dateValue()
                var currDate = Date()
                var pass = currDate >= deadlineDate
                if pass {
                    print("deadline has passed")
                } else {
                    // deadline not passed
                    print("segue to survey")
                    if let surveyVC = self.storyboard?.instantiateViewController(withIdentifier: "SurveyVCID") as? SurveyPageVC {
                        surveyVC.cityId = cityId
                        surveyVC.cityName = cityName
                        self.navigationController?.pushViewController(surveyVC, animated: true)
                    }
                    
                }
                
            } else {
                print("Issue finding deadline in firestore")
            }
            
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
                           let city = City(name: cityName, startDate: startDate.dateValue(), endDate: endDate.dateValue(), deadline: deadline.dateValue(), imageURL: "")
                           self.cityList.append(city)
                           print("Appended to city list in fetchCities, leng of cityList: ", self.cityList.count)
                       }
                        
                   /*     if let cityDoc = cityDoc, cityDoc.exists {
                            print("it exists")
                            
                        } 
                        else {
                            print("does not")
                        }
                        if let cityName = cityDoc?.data()?["cityName"] as? String {
                            print("City name: \(cityName)")
                        } 
                        else {
                            print("City name not found or not a string")
                        }
                        if let deadline = cityDoc?.data()?["deadline"] as? Timestamp {
                            print("Deadline: \(deadline)")
                        }
                        else {
                            print("Deadline not found or not a date")
                        }
                        if let start = cityDoc?.data()?["startDate"] as? Timestamp {
                            print("Start: \(start)")
                        }
                        else {
                            print("start not found or not a date")
                        } */
                        
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
        citiesModalView.backgroundColor = .white
        citiesModalView.layer.cornerRadius = 15
        citiesModalView.layer.masksToBounds = true
        overlayView.addSubview(citiesModalView)
        
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
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
        destinationLabel.font = .boldSystemFont(ofSize: 16)
        destinationLabel.textColor = .black
        citiesModalView.addSubview(destinationLabel)

        NSLayoutConstraint.activate([
            destinationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            destinationLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            destinationLabel.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20)
        ])
        
        // Add destination text field
        let destinationTextField = UITextField()
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        destinationTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2) // Light grey background
        destinationTextField.layer.cornerRadius = 15 // Rounded corners
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
            destinationTextField.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 10),
            destinationTextField.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20),
            destinationTextField.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20),
            destinationTextField.heightAnchor.constraint(equalToConstant: 40) // Fixed height for the text field
        ])
        
        // Survey Deadline label
        let surveyDeadlineLabel = UILabel()
        surveyDeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        surveyDeadlineLabel.text = "Survey Deadline"
        surveyDeadlineLabel.font = UIFont.boldSystemFont(ofSize: 20)
        surveyDeadlineLabel.textColor = .black
        citiesModalView.addSubview(surveyDeadlineLabel)

        NSLayoutConstraint.activate([
            surveyDeadlineLabel.topAnchor.constraint(equalTo: destinationTextField.bottomAnchor, constant: 20),
            surveyDeadlineLabel.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: 20)
        ])

        surveyDeadlinePicker.translatesAutoresizingMaskIntoConstraints = false
        surveyDeadlinePicker.datePickerMode = .date
        citiesModalView.addSubview(surveyDeadlinePicker)
        
        NSLayoutConstraint.activate([
            surveyDeadlinePicker.topAnchor.constraint(equalTo: surveyDeadlineLabel.bottomAnchor, constant: 10),
            surveyDeadlinePicker.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: -20) // Left-aligned
        ])

        // Trip Dates Label
        let tripDatesLabel = UILabel()
        tripDatesLabel.translatesAutoresizingMaskIntoConstraints = false
        tripDatesLabel.text = "Trip Dates"
        tripDatesLabel.font = UIFont.boldSystemFont(ofSize: 20)
        tripDatesLabel.textColor = .black
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
            startDatePicker.topAnchor.constraint(equalTo: tripDatesLabel.bottomAnchor, constant: 10),
            startDatePicker.leadingAnchor.constraint(equalTo: citiesModalView.leadingAnchor, constant: -20), // Left-aligned
            startDatePicker.widthAnchor.constraint(equalTo: surveyDeadlinePicker.widthAnchor) // Match width with the existing date picker
        ])
        
        // To label between start and end date pickers
        let toLabel = UILabel()
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.text = "to"
        toLabel.font = UIFont.boldSystemFont(ofSize: 16)
        toLabel.textColor = .black
        citiesModalView.addSubview(toLabel)

        NSLayoutConstraint.activate([
            toLabel.centerYAnchor.constraint(equalTo: startDatePicker.centerYAnchor),
            toLabel.centerXAnchor.constraint(equalTo: citiesModalView.centerXAnchor)
        ])

        // End date picker
        let endDatePicker = UIDatePicker()
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.datePickerMode = .date
        citiesModalView.addSubview(endDatePicker)

        NSLayoutConstraint.activate([
            endDatePicker.topAnchor.constraint(equalTo: startDatePicker.topAnchor),
            endDatePicker.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor, constant: 10), // Positioned to the right of "to" label
            endDatePicker.trailingAnchor.constraint(equalTo: citiesModalView.trailingAnchor, constant: -20), // Right-aligned
            endDatePicker.widthAnchor.constraint(equalTo: startDatePicker.widthAnchor) // Match width with the start date picker
        ])


        
        // Create done button for this modal view
        let citiesDoneButton = ProfileDoneButton()
        citiesDoneButton.typeOfButton = .cities
        citiesDoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        citiesDoneButton.citiesDoneCallback = { [self] in
            print("cities done callback")
            self.handleCityCreation(name: destinationTextField.text!, startDate: startDatePicker, endDate: endDatePicker, deadline: surveyDeadlinePicker)
            
        }
        
        citiesDoneButton.dismissCallback = {
            // Dismiss modal view
            self.dismissModalView()
        }
        
        citiesModalView.addSubview(citiesDoneButton)
        
        NSLayoutConstraint.activate([
            citiesDoneButton.centerXAnchor.constraint(equalTo: citiesModalView.centerXAnchor),
            citiesDoneButton.bottomAnchor.constraint(equalTo: citiesModalView.bottomAnchor, constant: -30),
            citiesDoneButton.heightAnchor.constraint(equalToConstant: 50),
            citiesDoneButton.widthAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    func handleCityCreation(name: String, startDate: UIDatePicker, endDate: UIDatePicker, deadline: UIDatePicker) {
//        var groupToAdd: Group = Group(groupName: name, groupCode: code, userList: [currentUser!])
//        globalGroupList.append(groupToAdd)
//        addGroup(newGroup: groupToAdd)

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
                        if let userDoc = userDoc, userDoc.exists, let email =  userDoc.data()?["email"] as? String, let name =  userDoc.data()?["name"] as? String {
                            //let user = User(email: email, displayName: name, profileImageUrl: "")
                            print("!!! name: ", name)
                            self.displayNames.append(name)
                            var thisImage: UIImage? = UIImage(named: "defaultProfilePicture")
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
        cell.userImageView.image = groupProfilePics[indexPath.row]
        cell.userDisplayLabel.text = displayNames[indexPath.row]
        return cell
    }
    
   /* func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("CITY COUNT: ", cityList.count)
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell from the table view.
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: "CitiesCell", for: indexPath)

        // Get the city name for the current row.
        let thisCity = cityList[indexPath.row]

        // Set the city name to the cell's text label.
        cell.textLabel?.text = thisCity!.name
        print("CITY TEXT: ", thisCity?.name)

        return cell
    
    } */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare to segue to Details page
        if segue.identifier == "GroupToDetails",
                   let destination = segue.destination as? GroupDetailsViewController
                {
                    destination.groupProfilePics = groupProfilePics
                    destination.displayNames = displayNames
                    destination.group = group
                }

        
        // Prepare to seugue to Survey page
//        if segue.identifier == "SurveyPageSegue" {
//            let destination = segue.destination as? SurveyPageVC
//        }
        

        

    }
    
}
