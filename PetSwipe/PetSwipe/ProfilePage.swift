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

            if let user = Auth.auth().currentUser {
                print("Current logged in user id = \(user.uid)")
                print("Current user email = \(user.email ?? "No email")")
                loadUserData(for: user) {
                    print("DEBUG: loadUserData in viewDidLoad completed")
                }
            } else {
                print("No existing user logged in")
            }
        }
        
    func loadUserData(for user: User, completion: @escaping () -> Void) {
        print("DEBUG: Calling loadUserData(for: \(user.uid))")

        let ref = db.collection("users").document(user.uid)
        ref.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let data = snapshot?.data() {
                print("DEBUG: Firestore user document data =", data)

                let name = data["name"] as? String ?? "Unknown"
                let email = data["email"] as? String ?? "Unknown"

                print("DEBUG: Parsed name =", name)
                print("DEBUG: Parsed email =", email)

                self.nameField.text = name
                self.emailField.text = email

                if data["preferences"] == nil {
                    print("Preferences is nil -- will let SettingsPage manage preferences")
                }

                if data["likedPets"] == nil {
                    ref.setData(["likedPets": []], merge: true)
                    print("Added missing likedPets field")
                }

                completion()

            } else {
                print("DEBUG: No user data or error: \(error?.localizedDescription ?? "Unknown")")
                completion()
            }
        }
    }
        
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text,
                  let password = passwordField.text,
                  !email.isEmpty, !password.isEmpty else {
                showAlert(title: "Missing Fields", message: "Please enter both email and password.")
                return
            }

            if !isValidEmail(email) {
                showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    print("Sign in failed: \(error.localizedDescription)")

                    if let errorCode = AuthErrorCode(rawValue: error._code) {
                        switch errorCode {
                        case .wrongPassword:
                            DispatchQueue.main.async {
                                self?.showAlert(title: "Wrong Password", message: "Please try again.")
                                self?.passwordField.text = ""
                            }
                        case .emailAlreadyInUse:
                            DispatchQueue.main.async {
                                self?.showAlert(title: "Email Already Registered", message: "Please log in.")
                                self?.passwordField.text = ""
                            }
                        case .userNotFound:
                            self?.signUp(email: email, password: password)
                        default:
                            DispatchQueue.main.async {
                                self?.showAlert(title: "Login Error", message: error.localizedDescription)
                                self?.passwordField.text = ""
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error", message: error.localizedDescription)
                            self?.passwordField.text = ""
                        }
                    }
                } else {
                    print("Signed in successfully")
                    self?.proceedToMain()
                }
            }
        }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
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
                    print("Full user profile created in Firestore")
                    self.proceedToMain()
                }
            }
        }
    }
    
    func proceedToMain() {
        guard Auth.auth().currentUser != nil else {
            print("No current user in proceedToMain")
            return
        }

        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { [weak self] token, error in
            if let error = error {
                print("Error refreshing token: \(error)")
            } else {
                print("Token refreshed, ready to proceed")

                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                        mainTabBarVC.modalPresentationStyle = .fullScreen
                        self?.present(mainTabBarVC, animated: true, completion: nil)
                    } else {
                        print("ERROR: Could not instantiate MainTabBarController")
                    }
                }
            }
        }
    }
    
    // saves user info even if we leave profile screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let user = Auth.auth().currentUser else { return }

        let nameToSave = nameField.text ?? ""
        let emailToSave = user.email ?? ""

        print("DEBUG: viewWillDisappear - saving name =", nameToSave)
        print("DEBUG: viewWillDisappear - saving email =", emailToSave)

        let userData: [String: Any] = [
            "name": nameToSave,
            "email": emailToSave,
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
