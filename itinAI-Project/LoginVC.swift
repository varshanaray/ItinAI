//
//  ViewController.swift
//  itinAI-Project
//
//  Created by Varsha Narayanan on 3/7/24.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        passwordField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        // Do any additional setup after loading the view.
    }


}

