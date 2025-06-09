//
//  LandingPage.swift
//  PetSwipe
//
//  Created by 郭家玮 on 6/8/25.
//

import UIKit
import FirebaseAuth

class LandingPage: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
            super.viewDidLoad()

            startButton.layer.cornerRadius = 10
            startButton.layer.masksToBounds = true

            if let user = Auth.auth().currentUser {
                print("LandingPage: User already logged in")
            } else {
                print("LandingPage: No user logged in")
            }
        }

    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
}
