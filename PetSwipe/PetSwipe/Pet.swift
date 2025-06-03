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
    let name: String
    var image: UIImage
    let age: Int
    let location: [Double] // [latitude, longitude]
    let breed: String
}

struct PetModel: Codable {
    let petName: String
    let petPicture: String
    let petAge: Int
    let petLocation: Location
    let petBreed: String
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }

    func toTempPet(with image: UIImage) -> tempPet {
        return tempPet(
            name: petName,
            image: image,
            age: petAge,
            location: [petLocation.latitude, petLocation.longitude],
            breed: petBreed
        )
    }
}
