import UIKit
import CoreLocation

class SwipePage: UIViewController {

    var pets: [matchesPet] = []
    var currentIndex: Int = 0
    var userPreferences: UserPreferences?
    var userLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setUpViews()
        setupLocationServices()
        loadUserPreferences()
        loadPetsFromFirebase()

        buttonsContainer.onLike = { [weak self] in
            self?.likePet()
        }

        buttonsContainer.onPass = { [weak self] in
            self?.passPet()
        }
        
        buttonsContainer.onRefresh = { [weak self] in
            self?.refreshPets()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
            
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func loadUserPreferences() {
        FirebaseManager.shared.fetchUserPreferences { [weak self] result in
            switch result {
            case .success(let preferences):
                self?.userPreferences = preferences
                print("User preferences loaded: Age range \(preferences.minAge)-\(preferences.maxAge), Distance: \(preferences.distance)mi, Breeds: \(preferences.breeds)")
            case .failure(let error):
                print("Failed to load user preferences: \(error)")
            }
        }
    }
    
    func loadPetsFromFirebase() {
        FirebaseManager.shared.fetchPetsWithLocationFilter(userLocation: userLocation, userPreferences: userPreferences) { [weak self] result in
            switch result {
            case .success(let petModels):
                
                let ages = petModels.map { $0.petAge }
                let distances = petModels.map { pet -> String in
                    if let userLoc = self?.userLocation {
                        let petLoc = CLLocation(latitude: pet.petLocation.latitude, longitude: pet.petLocation.longitude)
                        let distanceInMiles = userLoc.distance(from: petLoc) * 0.000621371
                        return String(format: "%.1fmi", distanceInMiles)
                    }
                    return "unknown"
                }
                
                self?.pets = petModels.map { model in
                    model.toMatchesPet(with: UIImage(named: "placeholder_pet") ?? UIImage())
                }
                
                for (index, model) in petModels.enumerated() {
                    FirebaseManager.shared.downloadImage(from: model.petPicture) { [weak self] image in
                        if let image = image, let strongSelf = self, index < strongSelf.pets.count {
                            strongSelf.pets[index].image = image
                            if index == strongSelf.currentIndex && index < strongSelf.pets.count {
                                DispatchQueue.main.async {
                                    if strongSelf.currentIndex < strongSelf.pets.count {
                                        strongSelf.petCard.configure(with: strongSelf.pets[strongSelf.currentIndex])
                                    }
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self?.currentIndex = 0
                    if let first = self?.pets.first, !petModels.isEmpty {
                        self?.petCard.configure(with: first)
                    } else {
                        self?.showNoMatchingPetsMessage()
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
    
    func showNoMatchingPetsMessage() {
        petCard.nameLabel.text = "No pets match your preferences"
        petCard.workLabel.text = "Try adjusting your age, distance, or breed preferences"
        petCard.profileImageView.image = UIImage(systemName: "heart.slash")
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
        guard !pets.isEmpty else {
            showEndMessage()
            return
        }
        
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
    
    func likePet() {
        guard currentIndex < pets.count else { return }
        
        let likedPet = pets[currentIndex]
        
        FirebaseManager.shared.addLikedPet(petId: likedPet.id) { [weak self] error in
            if let error = error {
                print("Failed to save liked pet: \(error)")
                DispatchQueue.main.async {
                    self?.showError(message: "Failed to save like")
                }
            } else {
                print("Successfully liked pet: \(likedPet.name)")
            }
        }
        
        goToNextPet()
    }
    
    func passPet() {
        guard currentIndex < pets.count else { 
            print("No more pets to pass")
            return 
        }
        print("Passed on pet: \(pets[currentIndex].name)")
        goToNextPet()
    }
    
    @objc func swipeCard(sender: UIPanGestureRecognizer) {
        guard currentIndex < pets.count && !pets.isEmpty else {
            return
        }
        
        sender.swipeView(petCard)

        if sender.state == .ended {
            let translation = sender.translation(in: petCard)
            let velocity = sender.velocity(in: petCard)

            let isRightSwipe = translation.x > 50 || velocity.x > 500
            let isLeftSwipe = translation.x < -50 || velocity.x < -500
            
            if isRightSwipe {
                passPet()
            } else if isLeftSwipe {
                likePet()
            } else {
                goToNextPet()
            }
        }
    }
    
    func showEndMessage() {
        petCard.nameLabel.text = "No more recommended 🐶"
        petCard.workLabel.text = ""
        petCard.profileImageView.image = nil
    }
    
    func refreshPets() {
        print("Refreshing pets based on current preferences...")

        currentIndex = 0

        loadUserPreferences()
        loadPetsFromFirebase()
    }
}

extension SwipePage: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location
        
        print("User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        loadPetsFromFirebase()
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied. Showing all pets without distance filtering.")
            loadPetsFromFirebase()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        loadPetsFromFirebase()
    }
}
