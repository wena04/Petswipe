//
//  BreedSelectionPage.swift
//  PetSwipe
//
//  Created by 郭家玮 on 6/3/25.
//

import UIKit

class BreedSelectionPage: UITableViewController {

    var allBreeds: [String] = []
    var selectedBreeds: Set<String> = []
    var onSelectionDone: ((Set<String>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breed Selection"
        tableView.allowsMultipleSelection = true
        print("allBreeds =", allBreeds)
        tableView.reloadData()
        
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection: \(allBreeds.count)")
        return allBreeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt: row \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell") ?? UITableViewCell(style: .default, reuseIdentifier: "BreedCell")
        let breed = allBreeds[indexPath.row]
        cell.textLabel?.text = breed
        cell.accessoryType = selectedBreeds.contains(breed) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breed = allBreeds[indexPath.row]

        if selectedBreeds.contains(breed) {
            selectedBreeds.remove(breed)
        } else {
            selectedBreeds.insert(breed)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)

        onSelectionDone?(selectedBreeds)
    }

}
