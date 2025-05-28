//
//  Landing&ProfilePage.swift
//  PetSwipe
//
//  Created by Jessica Wang 05/26/25
// Class for landing page

import UIKit

class ProfilePage: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 10
        nextButton.layer.masksToBounds = true
        
        // goes back to landing page, to test if profile info saved
        backButton.layer.cornerRadius = 10
        backButton.layer.masksToBounds = true
        
        nameField.text = UserDefaults.standard.string(forKey: "savedName")
        emailField.text = UserDefaults.standard.string(forKey: "savedEmail")
        phoneField.text = UserDefaults.standard.string(forKey: "savedPhone")
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    // saves user info even if we leave profile screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set(nameField.text, forKey: "savedName")
        UserDefaults.standard.set(emailField.text, forKey: "savedEmail")
        UserDefaults.standard.set(phoneField.text, forKey: "savedPhone")
    }

    
}
