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

    @IBAction func handleFindPet(_ sender: Any) {
        let selectedPet = pet
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let MapPage = storyboard.instantiateViewController(withIdentifier: "MapPage") as? MapPage {
            MapPage.pet = selectedPet
            navigationController?.pushViewController(MapPage, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pet = pet else {
            print("Error: Pet object is nil")
            navigationController?.popViewController(animated: true)
            return
        }

        infoPageImage.image = pet.image
        infoPageLabel.text = "Meet \(pet.name)!\n\(pet.name) is a \(pet.breed), and they are \(pet.age) years old.\nClick the button below to learn more about \(pet.name) and how to adopt your new best friend!"
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
