//
//  MatchesPage.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit
import FirebaseFirestore
import FirebaseCore

class MatchesPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var pets: [matchesPet] = []
    private let petsQueue = DispatchQueue(label: "com.petswipe.petsQueue")

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as? MatchesTableViewCell else {
            return UITableViewCell()
        }
        let pet = pets[indexPath.row]
        cell.matchImage.image = pet.image
        cell.matchLabel.text = pet.name
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

    func fetchLikedPetsFromFirestore() {
        FirebaseManager.shared.fetchLikedPets { [weak self] result in
            switch result {
            case .success(let likedPetIds):
                self?.fetchPetsByIDs(likedPetIds: likedPetIds)
            case .failure(let error):
                print("❌ Failed to fetch liked pets: \(error)")
            }
        }
    }

    func fetchPetsByIDs(likedPetIds: [String]) {
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

            let filteredDocuments = documents.filter { likedPetIds.contains($0.documentID) }

            var fetchedPets: [matchesPet] = []
            let dispatchGroup = DispatchGroup()

            for document in filteredDocuments {
                do {
                    let pet = try document.data(as: FirestorePet.self)
                    dispatchGroup.enter()
                    self.loadImage(from: pet.petPicture) { image in
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

            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                self.petsQueue.async {
                    self.pets = fetchedPets
                    DispatchQueue.main.async {
                        self.MatchesTableView.reloadData()
                    }
                }
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
        fetchLikedPetsFromFirestore()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        MatchesTableView.delegate = self
        MatchesTableView.dataSource = self
        initializeFirebaseIfNeeded()
        fetchLikedPetsFromFirestore()
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
