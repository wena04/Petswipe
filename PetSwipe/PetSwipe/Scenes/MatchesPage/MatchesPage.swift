//
//  MatchesPage.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit
import FirebaseFirestore
import FirebaseCore

var pets: [matchesPet] = [
//    tempPet(name: "Buddy", image: UIImage(named: "dog1") ?? UIImage(), age: 3, location: [47.6062, -122.3321], species: "Dog"),
//    tempPet(name: "Whiskers", image: UIImage(named: "cat1") ?? UIImage(), age: 2, location: [34.0522, -118.2437], species: "Cat"),
//    tempPet(name: "Chirpy", image: UIImage(named: "bird1") ?? UIImage(), age: 1, location: [40.7128, -74.0060], species: "Bird")
]

// MARK: table cell logic
class MatchesPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as? MatchesTableViewCell else {
            return UITableViewCell()
        }
        cell.matchImage.image = pets[indexPath.row].image
        cell.matchLabel.text = pets[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPet = pets[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let moreInfoVC = storyboard.instantiateViewController(withIdentifier: "InfoPage") as? InfoPage {
            moreInfoVC.pet = selectedPet
            navigationController?.pushViewController(moreInfoVC, animated: true)
        }
    }


  
    @IBOutlet weak var MatchesTableView: UITableView!

    
// MARK: fetch from the firebase and populate
    
    func fetchPetsFromFirestore() {
        let db = Firestore.firestore()

        db.collection("pets").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error fetching pets: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No documents found")
                return
            }

            var fetchedPets: [matchesPet] = []
            let dispatchGroup = DispatchGroup()

            for document in documents {
                do {
                    let pet = try document.data(as: FirestorePet.self)
                    dispatchGroup.enter()
                    loadImage(from: pet.petPicture) { image in
                        let convertedPet = matchesPet(
                            id: document.documentID,
                            name: pet.petName,
                            image: image ?? UIImage(),
                            age: pet.petAge,
                            location: [pet.petLocation.latitude, pet.petLocation.longitude],
                            breed: pet.petBreed
                        )
                        fetchedPets.append(convertedPet)
                        dispatchGroup.leave()
                    }
                } catch {
                    print("⚠️ Could not decode FirestorePet: \(error)")
                }
            }

            dispatchGroup.notify(queue: .main) {
                pets = fetchedPets
                self.MatchesTableView.reloadData()
            }
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    
    
    // MARK: when the user clicks on the actual page do the following:
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPetsFromFirestore()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MatchesTableView.delegate = self
        MatchesTableView.dataSource = self
        initializeFirebaseIfNeeded()
        fetchPetsFromFirestore()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
