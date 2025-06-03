//
//  InfoPageViewController.swift
//  PetSwipe
//
//  Created by George Lee on 5/26/25.
//

import UIKit


class InfoPage: UIViewController {
    var pet: matchesPet?

    @IBOutlet weak var infoPageImage: UIImageView!

    @IBOutlet weak var infoPageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pet = pet else {
                    fatalError("The pet object should not be nil.")
                }
        
        infoPageImage.image = pet.image
        

            infoPageLabel.text = "Meet \(pet.name)!\n\(pet.name) is a \(pet.breed), \(pet.age) years old. \n click the button below to adopt \(pet.name) as your new best friend!"
    

    
        // Do any additional setup after loading the view.
    }
    
 


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
