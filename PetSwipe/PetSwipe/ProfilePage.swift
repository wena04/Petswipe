//
//  Landing&ProfilePage.swift
//  PetSwipe
//
//  Created by Jessica Wang 05/26/25
// Class for landing page

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfilePage: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = 10
        nextButton.layer.masksToBounds = true

        backButton.layer.cornerRadius = 10
        backButton.layer.masksToBounds = true

        do {
            try Auth.auth().signOut()
            print("Existing session cleared; authentication required")
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func loadUserData(for user: User) {
        let ref = db.collection("users").document(user.uid)
        ref.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let data = snapshot?.data() {
                self.nameField.text = data["name"] as? String
                self.emailField.text = data["email"] as? String

                // Add missing fields
                var updateNeeded = false
                var updateData: [String: Any] = [:]

                if data["likedPets"] == nil {
                    updateData["likedPets"] = []
                    updateNeeded = true
                }
                if data["preferences"] == nil {
                    updateData["preferences"] = [
                        "distance": 50,
                        "ageRange": [1, 10],
                        "breeds": []
                    ]
                    updateNeeded = true
                }

                if updateNeeded {
                    ref.setData(updateData, merge: true)
                    print("Added missing default fields")
                }

            } else {
                print("No user data or error: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text,
                      let password = passwordField.text,
                      !email.isEmpty, !password.isEmpty else {
                    print("Email or password missing")
                    return
                }

                Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                    if let error = error {
                        print("Sign in failed: \(error.localizedDescription)")
                        self?.signUp(email: email, password: password)
                    } else {
                        print("Signed in successfully")
                        self?.performSegue(withIdentifier: "toMain", sender: self)
                    }
                }
            }
        

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self, let user = result?.user else {
                print("Sign up failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let userData: [String: Any] = [
                "name": self.nameField.text ?? "",
                "email": email,
                "createdAt": Timestamp(),
                "lastUpdated": Timestamp(),
                "likedPets": [],
                "preferences": [
                    "distance": 50,
                    "ageRange": [1, 10],
                    "breeds": []
                ]
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Failed to store user info: \(error)")
                } else {
                    print("✅ Full user profile created in Firestore")
                    self.performSegue(withIdentifier: "toMain", sender: self)
                }
            }
        }
    }

    
    // saves user info even if we leave profile screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let user = Auth.auth().currentUser else { return }

        let userData: [String: Any] = [
            "name": nameField.text ?? "",
            "email": user.email ?? "",
            "lastUpdated": Timestamp()
        ]

        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user info: \(error)")
            } else {
                print("User info saved to Firestore")
            }
        }
    }
}
