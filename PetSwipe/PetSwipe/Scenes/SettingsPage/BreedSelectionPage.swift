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

        if selectedBreeds.contains(breed) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breed = allBreeds[indexPath.row]
        selectedBreeds.insert(breed)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        onSelectionDone?(selectedBreeds)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let breed = allBreeds[indexPath.row]
        selectedBreeds.remove(breed)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        onSelectionDone?(selectedBreeds)
    }


}
