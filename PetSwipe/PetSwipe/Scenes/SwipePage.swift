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

//        view.backgroundColor = .white
//        view.backgroundColor = UIColor(hex: "#FEFBFD")

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

    func loadUserPreferences(completion: (() -> Void)? = nil) {
        FirebaseManager.shared.fetchUserPreferences { [weak self] result in
            switch result {
            case .success(let preferences):
                self?.userPreferences = preferences
                print("User preferences loaded: Age range \(preferences.minAge)-\(preferences.maxAge), Distance: \(preferences.distance)mi, Breeds: \(preferences.breeds)")
            case .failure(let error):
                print("Failed to load user preferences: \(error)")
            }
            completion?()
        }
    }

    func loadPetsFromFirebase() {
        FirebaseManager.shared.fetchPetsWithLocationFilter(userLocation: userLocation, userPreferences: userPreferences) { [weak self] result in
            switch result {
            case .success(let petModels):
                let dispatchGroup = DispatchGroup()
                var tempPets: [matchesPet] = []

                for model in petModels {
                    dispatchGroup.enter()
                    let placeholderImage = UIImage(named: "placeholder_pet") ?? UIImage()
                    var pet = model.toMatchesPet(with: placeholderImage)

                    FirebaseManager.shared.downloadImage(from: model.petPicture) { image in
                        if let image = image {
                            pet.image = image
                        }
                        tempPets.append(pet)
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    self.pets = tempPets
                    self.currentIndex = 0

                    if let first = self.pets.first {
                        self.petCard.configure(with: first)
                    } else {
                        self.showNoMatchingPetsMessage()
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
            petCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            petCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            petCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            petCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])

        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: petCard.bottomAnchor, constant: 16),
            buttonsContainer.leadingAnchor.constraint(equalTo: petCard.leadingAnchor),
            buttonsContainer.trailingAnchor.constraint(equalTo: petCard.trailingAnchor),
            buttonsContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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

        let currentPet = pets[currentIndex]

        FirebaseManager.shared.fetchLikedPets { [weak self] result in
            switch result {
            case .success(let likedPetIds):
                if likedPetIds.contains(currentPet.id) {
                    FirebaseManager.shared.removeLikedPet(petId: currentPet.id) { error in
                        if let error = error {
                            print("Failed to remove liked pet: \(error)")
                        } else {
                            print("Successfully removed \(currentPet.name) from liked pets")
                        }
                    }
                } else {
                    print("Passed on pet: \(currentPet.name)")
                }
            case .failure(let error):
                print("Failed to check liked pets: \(error)")
                print("Passed on pet: \(currentPet.name)")
            }
        }

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
                likePet()
            } else if isLeftSwipe {
                passPet()
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

        loadUserPreferences { [weak self] in
            self?.loadPetsFromFirebase()
        }
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
