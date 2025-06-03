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
    let image: UIImage
    let age: Int
    let breed: String
    let latitude: Double
    let longitude: Double
}

struct tempPet {
    let name: String
    let image: UIImage
    let age: Int
    let breed: String
    let latitude: Double
    let longitude: Double
}

struct PetModel: Codable {
    let name: String
    let image: String
    let age: Int
    let location: [Double]
    let species: String
}
