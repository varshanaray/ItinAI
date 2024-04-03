// Project: itinAI-Alpha
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol GroupTableUpdater {
    func addGroup(newGroup: Group)
}

class HomePageVC: UIViewController, UITableViewDataSource, UITableViewDelegate, GroupTableUpdater, UITextFieldDelegate {
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var groupTableView: UITableView!
    
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
    
    // String var that will hold the code to copy to clipboard
    var codeToCopy: String?
    
    var groupList: [Group?] = []
    
    var groupNameHere = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        
        fetchGroups()
        
        // reset codeToCopy to blank
        codeToCopy = ""
       
        // Create Button
        createButton.backgroundColor = UIColor.black
        createButton.setTitle("Create", for: .normal)
        createButton.setTitleColor(UIColor.white, for: .normal)
        createButton.layer.cornerRadius = 10
        createButton.clipsToBounds = true
        
        // Join Button
        joinButton.backgroundColor = UIColor.black
        joinButton.setTitle("Join", for: .normal)
        joinButton.setTitleColor(UIColor.white, for: .normal)
        joinButton.layer.cornerRadius = 10
        joinButton.clipsToBounds = true
        
        // Populate group array
        //groupNames = currentUser?.groupList
        
        print("viewDidLoad() called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear called")
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        print("Create button pressed")
        setupCreateModalView(title: createButton.title(for: .normal)!)
        currentModalView = createModalView
        animateModalView()
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        print("Join button pressed")
        setupJoinModalView(title: joinButton.title(for: .normal)!)
        currentModalView = joinModalView
        animateModalView()
    }
    
    func setupCreateModalView(title: String) {
        var modalTitle: String = ""
        let leftMargin: CGFloat = 20.0
        
        // Create modal view
        createModalView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: modalHeight))
        createModalView.backgroundColor = .white
        createModalView.layer.cornerRadius = 15
        createModalView.layer.masksToBounds = true
        
        // Add a view for a darkened background
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0.0 // Initially Invisible
        view.addSubview(overlayView)
        
        // Add a tap gesture recognizer to overlayView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        // Add a title label for the modal view
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: createModalView.frame.width - 40, height: 30))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        createModalView.addSubview(titleLabel)
        
        view.addSubview(createModalView)
        
        modalTitle = "Create a group"
        print("Create modal view")
        
        // Create Group Name label
        var groupNameLabel = UILabel()
        groupNameLabel.text = "Enter your group's name"
        groupNameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        groupNameLabel.frame.origin.x = leftMargin
        groupNameLabel.frame = CGRect(x: leftMargin, y: 60.0, width: 200.0, height: 30.0)
        createModalView.addSubview(groupNameLabel)
        
        // Group name text field
        let placeHolderText = "Max 20 characters"
        let placeHolderFont = UIFont.systemFont(ofSize: 12.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: placeHolderFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: attributes)
        
        var groupTextField = UITextField()
        groupTextField.delegate = self
        groupTextField.attributedPlaceholder = attributedPlaceholder
        groupTextField.backgroundColor = UIColor.lightGray
        groupTextField.font = UIFont.systemFont(ofSize: 12.0)
        groupTextField.layer.cornerRadius = 8.0
        groupTextField.frame.origin.x = leftMargin
        groupTextField.frame = CGRect(x: leftMargin, y: 90.0, width: 300.0, height: 30.0)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: groupTextField.frame.height))
        
        groupTextField.leftView = paddingView
        groupTextField.leftViewMode = .always
        createModalView.addSubview(groupTextField)
        
        groupNameHere = groupTextField.text!
        
        // Create character count label
        var characterCountLabel = UILabel()
        characterCountLabel.textColor = .red
        characterCountLabel.isHidden = true
        characterCountLabel.frame = CGRect(x: leftMargin, y: 100.0, width: 200.0, height: 20.0)
        characterCountLabel.font = UIFont.systemFont(ofSize: 11.0)
        createModalView.addSubview(characterCountLabel)
        
        // Create group code label
        var groupCodeLabel = UILabel()
        groupCodeLabel.text = "Group Code:"
        groupCodeLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        groupCodeLabel.frame = CGRect(x: leftMargin, y: 150.0, width: 200.0, height: 30.0)
        createModalView.addSubview(groupCodeLabel)
        
        // Create code display label
        var codeDisplayLabel = UILabel()
        var codeToGenerate:String = genCode()
        codeDisplayLabel.text = codeToGenerate
        var code : String = codeDisplayLabel.text!
        codeDisplayLabel.font = UIFont.systemFont(ofSize: 16.0)
        codeDisplayLabel.frame = CGRect(x: 190.0, y: 150.0, width: 200.0, height: 30.0)
        createModalView.addSubview(codeDisplayLabel)
        
        // Create clipboard button
        var clipboardButton = UIButton(type: .system)
        let clipboardImage = UIImage(systemName: "clipboard")
        clipboardButton.setImage(clipboardImage, for: .normal)
        codeToCopy = code
        clipboardButton.addTarget(self, action: #selector(copyCodeToClipboard(_:)), for: .touchUpInside)
        var buttonWidth: CGFloat = 30.0
        var buttonHeight: CGFloat = buttonWidth
        clipboardButton.frame = CGRect(x: 270.0, y: 150.0, width: buttonWidth, height: buttonHeight)
        createModalView.addSubview(clipboardButton)
        
        // Create done button for this modal view
        let createDoneButton = ProfileDoneButton()
        
        createDoneButton.createDoneCallback = {
            print("Create done callback")
            self.handleGroupCreation(name: groupTextField.text!, code: codeDisplayLabel.text!)
        }
        
        createDoneButton.dismissCallback = {
            // Dismiss modal view
            self.dismissModalView()
        }
        createDoneButton.frame = CGRect(x: 160.0, y: 200.0, width: 70.0, height: 40.0)
        
        createModalView.addSubview(createDoneButton)
        
        print("group name frame: \(groupNameLabel.frame)")
        print("group text field frame: \(groupTextField.frame)")
        print("group code label frame: \(groupCodeLabel.frame)")
        
        // set the title label of modal view
        titleLabel.text = modalTitle
    }
    
    // code for join modal view
    func setupJoinModalView(title: String) {
        var modalTitle: String = ""
        let leftMargin: CGFloat = 20.0
        
        // Create modal view
        joinModalView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: modalHeight))
        joinModalView.backgroundColor = .white
        joinModalView.layer.cornerRadius = 15
        joinModalView.layer.masksToBounds = true
        
        // Add a view for a darkened background
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0.0 // Initially Invisible
        view.addSubview(overlayView)
        
        // Add a tap gesture recognizer to overlayView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        // Add a title label for the modal view
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: joinModalView.frame.width - 40, height: 30))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = "Join a group"
        joinModalView.addSubview(titleLabel)
        
        view.addSubview(joinModalView)
        
        // Create Enter group code label
        var enterGroupCodeLabel = UILabel()
        enterGroupCodeLabel.text = "Enter a group code"
        enterGroupCodeLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        enterGroupCodeLabel.frame.origin.x = leftMargin
        enterGroupCodeLabel.frame = CGRect(x: leftMargin, y: 80.0, width: 200.0, height: 30.0)
        joinModalView.addSubview(enterGroupCodeLabel)
        
        // Enter group code text field
        let placeHolderText = "7 character code"
        let placeHolderFont = UIFont.systemFont(ofSize: 12.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: placeHolderFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: attributes)
        
        var codeTextField = UITextField()
        codeTextField.delegate = self
        codeTextField.attributedPlaceholder = attributedPlaceholder
        codeTextField.backgroundColor = UIColor.lightGray
        codeTextField.font = UIFont.systemFont(ofSize: 12.0)
        codeTextField.layer.cornerRadius = 8.0
        codeTextField.frame.origin.x = leftMargin
        codeTextField.frame = CGRect(x: leftMargin, y: 120.0, width: 300.0, height: 30.0)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: codeTextField.frame.height))
        
        codeTextField.leftView = paddingView
        codeTextField.leftViewMode = .always
        joinModalView.addSubview(codeTextField)
        
        // Create done button for this modal view
        let joinDoneButton = ProfileDoneButton()
        joinDoneButton.typeOfButton = .join
        
        // TODO: - Find a way to initialize currentUser
        // TODO: Ensure correct group is being found in joinDoneCallback
        // TODO: Ensure the group that is found is added to currentUser's groupList
        joinDoneButton.joinDoneCallback = {
            print("Join done callback")
            // need to get correct group based on group code
            var enteredCode:String = codeTextField.text ?? "0000000"
            print("The code that was entered is \(enteredCode)")
            //var groupToJoin: Group
            
//            for group in globalGroupList {
//                if (enteredCode == group.groupCode) {
//                    print("Found a match for the entered code")
//                    groupToJoin = group
//                    print("group joined's name: \(groupToJoin.groupName)")
//                    self.addGroup(newGroup: groupToJoin)
//                    groupToJoin.userList.append(currentUser!)
//                    break
//                }
//            }
            
            // handle joining group in firestore
            self.handleJoinGroup(code: enteredCode)
            
        }
        
        joinDoneButton.dismissCallback = {
            // Dismiss modal view
            self.dismissModalView()
        }
        joinDoneButton.frame = CGRect(x: 160.0, y: 200.0, width: 70.0, height: 40.0)
        
        joinModalView.addSubview(joinDoneButton)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        // Dismiss the modal view
        dismissModalView()
    }
    
    // handle copying whatever is currently the group code in the create group modal view to the user's clipboard
    @objc func copyCodeToClipboard(_ sender: UIButton) {
        let clipboardCode = self.codeToCopy
        UIPasteboard.general.string = clipboardCode
        print("Code copied to clipboard: \(clipboardCode!)")
        codeToCopy = ""
    }
    
    func handleGroupCreation(name: String, code: String) {
//        var groupToAdd: Group = Group(groupName: name, groupCode: code, userList: [currentUser!])
//        globalGroupList.append(groupToAdd)
//        addGroup(newGroup: groupToAdd)

        let db = Firestore.firestore()
        
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
    }
    
    // takes care of adding a User to a Group in Firestore
    func handleJoinGroup(code: String!) {
        print("In handleJoinGroup")
        print("Group Code: ", code!)
        let db = Firestore.firestore()
            
        // Reference to the user's document
        let userDocumentRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        
        // Update group document
        db.collection("Groups").document(code).getDocument { (document, error) in
            if let error = error {
                print("Error fetching group document: \(error)")
                return
            }
            
            guard let document = document else {
                print("Group document does not exist")
                return
            }
            
            if document.exists {
                print("Group document exists")
                
                // Check if user already exists in group
                if let userList = document.data()?["userList"] as? [DocumentReference] {
                    if userList.contains(userDocumentRef) {
                        print("User is already a member of this group")
                        return
                    } else {
                        print("User is not already a member of this group")
                    }
                } else {
                    print("Couldn't find userList")
                }
                
                // Document found, add user's document reference to group
                let groupRef = db.collection("Groups").document(code)
                groupRef.updateData([
                    "userList": FieldValue.arrayUnion([userDocumentRef])
                ]) { error in
                    if let error = error {
                        print("Error updating group document: \(error)")
                    } else {
                        print("User added to group successfully")
                        
                        // Add group reference to user's groupRefs field
                        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
                        userRef.updateData([
                            "groupRefs": FieldValue.arrayUnion([groupRef])
                        ]) { error in
                            if let error = error {
                                print("Error updating user document: \(error)")
                            } else {
                                self.fetchGroups()
                                print("Group reference added to user successfully")
                            }
                        }
                    }
                }
//                let group = Group(groupName: self.groupNameHere, groupCode: code)
                // self.addGroupToTable(newGroup: Group(groupName: self.groupNameHere, groupCode: code))
               
                //self.fetchGroups()
            } else {
                print("Group document does not exist")
            }
        }
    }
    
    /*
    func fetchGroups() {
        print("fetchGroups() called")
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        
        userRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("User document does not exists")
                return
            }
            self.groupList = []
            if let groupRefs = document.data()?["groupRefs"] as? [DocumentReference] {
                let dispatchGroup = DispatchGroup()
                for groupRef in groupRefs {
                    dispatchGroup.enter()
                    print("groupRefs found")
                    groupRef.getDocument { (groupDoc, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let groupDoc = groupDoc, groupDoc.exists, let groupName =  groupDoc.data()?["groupName"] as? String {
                            let group = Group(groupName: groupName, groupCode: groupDoc.documentID)
                            self.groupList.append(group)
                        } else {
                            print("Group document does not exists in User")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    print("Printing groupList after fetching groupRefs")
                    for group in self.groupList {
                        print(group?.groupName)
                        print(group?.groupCode)
                    }
                    self.groupTableView.reloadData()
                }
                    
            }
        }
    }
    */
    
    func fetchGroups() {
        print("fetchGroups() called")
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        
        userRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("User document does not exists")
                return
            }
            self.groupList = []
            if let groupRefs = document.data()?["groupRefs"] as? [DocumentReference] {
                let dispatchGroup = DispatchGroup()
                for groupRef in groupRefs {
                    dispatchGroup.enter()
                    print("groupRefs found")
                    groupRef.getDocument { (groupDoc, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let groupDoc = groupDoc, groupDoc.exists, let groupName =  groupDoc.data()?["groupName"] as? String {
                            let group = Group(groupName: groupName, groupCode: groupDoc.documentID)
                            self.groupList.append(group)
                        } else {
                            print("Group document does not exists in User")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    print("Printing groupList after fetching groupRefs")
                    for group in self.groupList {
                        print(group?.groupName)
                        print(group?.groupCode)
                    }
                    self.groupTableView.reloadData()
                }
                    
            }
        }
    }
    
    func genCode() -> String {
        let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let codeLength = 7
        
        var randomCode = ""
        var isUnique = false
        
        while !isUnique {
            randomCode = ""
            for _ in 0..<codeLength {
                let randomIndex = Int(arc4random_uniform(UInt32(lettersAndNumbers.count)))
                let randomCharacter = lettersAndNumbers[lettersAndNumbers.index(lettersAndNumbers.startIndex, offsetBy: randomIndex)]
                randomCode.append(randomCharacter)
            }
            
            // Check if the generated code already exists in the global array
            isUnique = true
            // TODO: Merge functionality with Firestore to check if a group with a code already exists
//            for group in globalGroupList {
//                if (group.groupCode == randomCode) {
//                    isUnique = false
//                }
//            }
        }
        print("random code: \(randomCode)")
        return randomCode
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return true}
        
        // check if the char count exceeds 20
        let newLength = text.count + string.count - range.length
//        if newLength > 20 {
//            characterC
//        }
        return newLength <= 20
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
    // Called when 'return' key pressed

       func textFieldShouldReturn(_ textField:UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("count: ",currentUser!.groupList.count )
        return groupList.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dummy
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableCell", for: indexPath)
        let row = indexPath.row
        let cellText = groupList[row]!.groupName
        cell.textLabel?.text = cellText
        return cell
    }
    
    func addGroup(newGroup: Group) {
        // Add group to group list array
        groupList.append(newGroup)
        print("New group added's name: ", newGroup.groupName)
        // Refreshes table
        groupTableView.reloadData()
    }
    
    // Prepare for segue to group page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CellToGroupSegue",
           let destination = segue.destination as? GroupPageVC,
           let groupIndex = groupTableView.indexPathForSelectedRow?.row
        {
            destination.group = groupList[groupIndex]
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            self.dismiss(animated: true)
            
            
        } catch {
            print("log out error")
        }
    }
    
}

