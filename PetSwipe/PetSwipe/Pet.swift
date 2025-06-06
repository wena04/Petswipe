//
//  Pet.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
// Class defining a single pet, and any associated functions/data we will need for it

// jessica test comment

import Foundation
import UIKit

class Pet{
    
}

struct matchesPet {
    let id: String
    let name: String
    var image: UIImage
    let age: Int
    let location: [Double] // [latitude, longitude]
    let breed: String
}

struct PetModel: Codable {
    let id: String
    let petName: String
    let petPicture: String
    let petAge: Int
    let petLocation: Location
    let petBreed: String
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }

    func toMatchesPet(with image: UIImage) -> matchesPet {
        return matchesPet(
            id: id,
            name: petName,
            image: image,
            age: petAge,
            location: [petLocation.latitude, petLocation.longitude],
            breed: petBreed
        )
    }
}

struct UserPreferences {
    let ageRange: [Int]
    let distance: Int
    let breeds: [String]
    
    init(ageRange: [Int] = [1, 10], distance: Int = 50, breeds: [String] = []) {
        self.ageRange = ageRange
        self.distance = distance
        self.breeds = breeds
    }
    
    var minAge: Int {
        return ageRange.first ?? 1
    }
    
    var maxAge: Int {
        return ageRange.last ?? 10
    }
}
