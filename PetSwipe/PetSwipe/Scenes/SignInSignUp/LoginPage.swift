//
//  LoginPage.swift
//  PetSwipe
//
//  Created by 郭家玮 on 6/8/25.
//

import UIKit
import FirebaseAuth

class LoginPage: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
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
                        case .userNotFound:
                            DispatchQueue.main.async {
                                self?.showAlert(title: "User Not Found", message: "Please check your email.")
                            }
                        default:
                            DispatchQueue.main.async {
                                self?.showAlert(title: "Login Error", message: error.localizedDescription)
                                self?.passwordField.text = ""
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Login Error", message: error.localizedDescription)
                            self?.passwordField.text = ""
                        }
                    }
                } else {
                    print("Signed in successfully")
                    self?.proceedToMain()
                }
            }
        }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func proceedToMain() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                mainTabBarVC.modalPresentationStyle = .fullScreen
                self.present(mainTabBarVC, animated: true, completion: nil)
            } else {
                print("ERROR: Could not instantiate MainTabBarController")
            }
        }
    }
}
