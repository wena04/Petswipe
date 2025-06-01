//
//  ViewController.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit

class SwipePage: UIViewController {

    var pets: [tempPet] = []
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        
        setUpViews()

     //   pets = loadPets()
        print("Loaded pets: \(pets.count)")

        if let first = pets.first {
            petCard.configure(with: first)
        }

        buttonsContainer.onLike = { [weak self] in
            self?.goToNextPet()
        }

        buttonsContainer.onPass = { [weak self] in
            self?.goToNextPet()
        }

    }
    
//    func loadPets() -> [PetModel] {
//        guard let url = Bundle.main.url(forResource: "pet_test", withExtension: "json") else {
//            print("Could not find file in bundle.")
//            return []
//        }
//
//        do {
//            let data = try Data(contentsOf: url)
//            let petModels = try JSONDecoder().decode([PetModel].self, from: data)
//            print("Decoded \(petModels.count) pets from JSON.")
//            return petModels.map { model in
//                if UIImage(named: model.image) == nil {
//                    print("Missing image: \(model.image)")
//                }
//                return PetModel(
//                    name: model.name,
//                    image: UIImage(named: model.image) ?? UIImage(),
//                    age: model.age,
//                    location: model.location,
//                    species: model.species
//                )
//            }
//        } catch {
//            print("JSON decoding error: \(error)")
//            return []
//        }
//    }
//

    lazy var petCard: PetCard = {
        let tc = PetCard()
       tc.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeCard(sender:))))
        return tc
    }()
    
    let buttonsContainer: ButtonsView = {
        let c = ButtonsView()
        return c
    }()
    
    func goToNextPet() {
        currentIndex += 1
        if currentIndex < pets.count {
            petCard.configure(with: pets[currentIndex])
        } else {
            showEndMessage()
        }
    }
    
    func setUpViews() {
        view.addSubview(petCard)
        view.addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            petCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            petCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            petCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            petCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70),
            
            buttonsContainer.topAnchor.constraint(equalTo: petCard.bottomAnchor, constant: 50),
            buttonsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsContainer.widthAnchor.constraint(equalTo: petCard.widthAnchor),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // pin
        ])
    }
    
    @objc func swipeCard(sender: UIPanGestureRecognizer) {
        sender.swipeView(petCard)

        if sender.state == .ended {
            goToNextPet()
        }
    }
    
    func showEndMessage() {
        petCard.nameLabel.text = "No more recommended 🐶"
        petCard.workLabel.text = ""
        petCard.profileImageView.image = nil
    }
}

