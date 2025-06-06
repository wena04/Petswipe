import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Authentication Methods

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> User? {
        print("Current user: \(Auth.auth().currentUser?.uid ?? "No user")")
        return Auth.auth().currentUser
    }

    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }

    // pet methods
    
    func fetchUserPreferences(completion: @escaping (Result<UserPreferences, Error>) -> Void) {
        guard let user = getCurrentUser() else {
            completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let preferencesData = data["preferences"] as? [String: Any] else {
                completion(.success(UserPreferences()))
                return
            }
            
            let ageRange = preferencesData["ageRange"] as? [Int] ?? [1, 10]
            let distance = preferencesData["distance"] as? Int ?? 50

            let breeds: [String]
            if let breedArray = preferencesData["breeds"] as? [String] {
                breeds = breedArray
            } else if let breedDict = preferencesData["breeds"] as? [String: Bool] {
                breeds = breedDict.compactMap { key, value in value ? key : nil }
            } else {
                breeds = []
            }
            
            let preferences = UserPreferences(ageRange: ageRange, distance: distance, breeds: breeds)
            completion(.success(preferences))
        }
    }

    func fetchPets(completion: @escaping (Result<[PetModel], Error>) -> Void) {
        db.collection("pets").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let pets = documents.compactMap { document -> PetModel? in
                let data = document.data()
                guard let petName = data["petName"] as? String,
                      let petPicture = data["petPicture"] as? String,
                      let petAge = data["petAge"] as? Int,
                      let petLocation = data["petLocation"] as? [String: Double],
                      let petBreed = data["petBreed"] as? String,
                      let latitude = petLocation["latitude"],
                      let longitude = petLocation["longitude"] else {
                    return nil
                }
                
                return PetModel(
                    id: document.documentID,
                    petName: petName,
                    petPicture: petPicture,
                    petAge: petAge,
                    petLocation: PetModel.Location(latitude: latitude, longitude: longitude),
                    petBreed: petBreed
                )
            }
            
            completion(.success(pets))
        }
    }
    
    private func applyUserPreferencesFilter(to pets: [PetModel], with preferences: UserPreferences, userLocation: CLLocation? = nil) -> [PetModel] {
        return pets.filter { pet in
            let ageMatch = pet.petAge >= preferences.minAge && pet.petAge <= preferences.maxAge
            
            let breedMatch: Bool
            if preferences.breeds.isEmpty || preferences.breeds.contains("Every Pets") {
                breedMatch = true
            } else {
                breedMatch = preferences.breeds.contains(pet.petBreed)
            }
            
            let distanceMatch: Bool
            if let userLoc = userLocation {
                let petLocation = CLLocation(latitude: pet.petLocation.latitude, longitude: pet.petLocation.longitude)
                let distanceInMeters = userLoc.distance(from: petLocation)
                let distanceInMiles = distanceInMeters * 0.000621371
                distanceMatch = distanceInMiles <= Double(preferences.distance)
                
                print("\(pet.petName): Age \(pet.petAge), Distance: \(String(format: "%.1f", distanceInMiles))mi (max: \(preferences.distance)mi), Breed: \(pet.petBreed)")
            } else {
                distanceMatch = true
            }
            
            return ageMatch && breedMatch && distanceMatch
        }
    }
    
    func fetchFilteredPets(completion: @escaping (Result<[PetModel], Error>) -> Void) {
        fetchUserPreferences { [weak self] result in
            switch result {
            case .success(let preferences):
                self?.fetchPets { petsResult in
                    switch petsResult {
                    case .success(let allPets):
                        let filteredPets = self?.applyUserPreferencesFilter(to: allPets, with: preferences) ?? []
                        completion(.success(filteredPets))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):   
                print("Could not fetch user preferences, showing all pets: \(error)")
                self?.fetchPets(completion: completion)
            }
        }
    }
    
    func fetchPetsWithLocationFilter(userLocation: CLLocation?, userPreferences: UserPreferences?, completion: @escaping (Result<[PetModel], Error>) -> Void) {
        if let preferences = userPreferences {
            performLocationFiltering(with: preferences, userLocation: userLocation, completion: completion)
        } else {
            if getCurrentUser() != nil {
                fetchUserPreferences { [weak self] result in
                    switch result {
                    case .success(let preferences):
                        self?.performLocationFiltering(with: preferences, userLocation: userLocation, completion: completion)
                    case .failure(let error):
                        print("Could not fetch user preferences, showing all pets: \(error)")
                        self?.fetchPets(completion: completion)
                    }
                }
            } else {
                print("User not logged in, showing all pets without filtering")
                fetchPets(completion: completion)
            }
        }
    }
    
    private func performLocationFiltering(with preferences: UserPreferences, userLocation: CLLocation?, completion: @escaping (Result<[PetModel], Error>) -> Void) {
        fetchPets { [weak self] petsResult in
            switch petsResult {
            case .success(let allPets):
                let filteredPets = self?.applyUserPreferencesFilter(to: allPets, with: preferences, userLocation: userLocation) ?? []
                completion(.success(filteredPets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }.resume()
    }
    
    // user liked pets methods
    
    func addLikedPet(petId: String, completion: @escaping (Error?) -> Void) {
        guard let user = getCurrentUser() else {
            completion(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        
        userRef.updateData([
            "likedPets": FieldValue.arrayUnion([petId]),
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error adding liked pet: \(error)")
            } else {
                print("Pet \(petId) added to liked pets")
            }
            completion(error)
        }
    }
    
    func removeLikedPet(petId: String, completion: @escaping (Error?) -> Void) {
        guard let user = getCurrentUser() else {
            completion(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        
        userRef.updateData([
            "likedPets": FieldValue.arrayRemove([petId]),
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error removing liked pet: \(error)")
            } else {
                print("Pet \(petId) removed from liked pets")
            }
            completion(error)
        }
    }
    
    func fetchLikedPets(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let user = getCurrentUser() else {
            completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let likedPets = data["likedPets"] as? [String] else {
                completion(.success([]))
                return
            }
            
            completion(.success(likedPets))
        }
    }
}
