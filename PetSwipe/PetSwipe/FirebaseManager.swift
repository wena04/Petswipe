import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
        return Auth.auth().currentUser
    }

    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }

    // pet methods
    
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
