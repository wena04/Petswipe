//
//  Landing&ProfilePage.swift
//  PetSwipe
//
//  Created by Jessica Wang 05/26/25
// Class for landing page

import UIKit
import FirebaseAuth

class LandingPage: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = 10
        startButton.layer.masksToBounds = true
        
        if let user = Auth.auth().currentUser {
            print("LandingPage: User logged in, show MainTabBar")
            let mainTabBarVC = storyboard?.instantiateViewController(identifier: "MainTabBarController")
            mainTabBarVC?.modalPresentationStyle = .fullScreen
            present(mainTabBarVC!, animated: true, completion: nil)
        } else {
            print("LandingPage: No user logged in, show ProfilePage")
            let profileVC = storyboard?.instantiateViewController(identifier: "ProfilePage")
            profileVC?.modalPresentationStyle = .fullScreen
            present(profileVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
}
