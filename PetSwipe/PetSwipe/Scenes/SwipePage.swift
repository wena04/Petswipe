import UIKit

class SwipePage: UIViewController {

    var pets: [matchesPet] = []
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUpViews()
        loadPetsFromFirebase()

        buttonsContainer.onLike = { [weak self] in
            self?.goToNextPet()
        }

        buttonsContainer.onPass = { [weak self] in
            self?.goToNextPet()
        }
    }
    
    func loadPetsFromFirebase() {
        FirebaseManager.shared.fetchPets { [weak self] result in
            switch result {
            case .success(let petModels):
                self?.pets = petModels.map { model in
                    model.toMatchesPet(with: UIImage(named: "placeholder_pet") ?? UIImage())
                }
                
                for (index, model) in petModels.enumerated() {
                    FirebaseManager.shared.downloadImage(from: model.petPicture) { [weak self] image in
                        if let image = image {
                            self?.pets[index].image = image
                            if index == self?.currentIndex {
                                DispatchQueue.main.async {
                                    self?.petCard.configure(with: self?.pets[index] ?? self!.pets[0])
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    if let first = self?.pets.first {
                        self?.petCard.configure(with: first)
                    }
                }
                
            case .failure(let error):
                print("Error loading pets: \(error)")
                DispatchQueue.main.async {
                    self?.showError(message: "Failed to load pets. Please try again later.")
                }
            }
        }
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

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
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
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
