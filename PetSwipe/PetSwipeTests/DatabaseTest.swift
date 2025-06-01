//
//  DatabaseTest.swift
//  PetSwipe
//
//  Created by 郭家玮 on 5/23/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase Initialization
func initializeFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
        print("✅ Firebase configured")
    }
}

// MARK: - FirestorePet Model (Renamed to Avoid Conflict)
struct FirestorePet: Codable {
    let petName: String
    let petAge: Int
    let petBreed: String
    let petPicture: String
    let petLocation: Location

    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
}

// MARK: - Firestore Test Function
func testFetchPetsFromFirestore() {
    initializeFirebaseIfNeeded()

    let db = Firestore.firestore()

    db.collection("pets").getDocuments { (snapshot, error) in
        if let error = error {
            print("❌ Error fetching pets: \(error)")
            return
        }

        guard let documents = snapshot?.documents else {
            print("⚠️ No documents found")
            return
        }

        var pets: [FirestorePet] = []

        for document in documents {
            let data = document.data()
            if
                let name = data["petName"] as? String,
                let age = data["petAge"] as? Int,
                let breed = data["petBreed"] as? String,
                let picture = data["petPicture"] as? String,
                let location = data["petLocation"] as? [String: Any],
                let altitude = location["altitude"] as? Double,
                let longitude = location["longitude"] as? Double
            {
                let pet = FirestorePet(
                    petName: name,
                    petAge: age,
                    petBreed: breed,
                    petPicture: picture,
                    petLocation: FirestorePet.Location(latitude: altitude, longitude: longitude)
                )
                pets.append(pet)
            }
        }

        for pet in pets {
            print("""
            🐾 \(pet.petName)
            • Age: \(pet.petAge)
            • Breed: \(pet.petBreed)
            • Picture: \(pet.petPicture)
            • Location: (\(pet.petLocation.latitude), \(pet.petLocation.longitude))
            """)
        }
    }
}
