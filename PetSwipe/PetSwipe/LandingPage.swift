//
//  Landing&ProfilePage.swift
//  PetSwipe
//
//  Created by Jessica Wang 05/26/25
// Class for landing page

import UIKit

class LandingPage: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.layer.cornerRadius = 10
        startButton.layer.masksToBounds = true
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
}
