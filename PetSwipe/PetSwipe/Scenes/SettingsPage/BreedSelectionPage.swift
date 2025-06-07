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
        print("selectedBreeds BEFORE reload =", selectedBreeds)
        DispatchQueue.main.async {
            self.tableView.reloadData()

            if self.selectedBreeds.isEmpty {
                self.selectedBreeds = ["Every Pets"]
                self.selectEveryPetsRow()
            } else {
                self.selectExistingSelectedBreeds()
            }
        }
    }
    
    private func selectExistingSelectedBreeds() {
        for (index, breed) in allBreeds.enumerated() {
            if selectedBreeds.contains(breed) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBreeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        if breed == "Every Pets" {
            selectedBreeds = ["Every Pets"]

            for row in 1..<allBreeds.count {
                tableView.deselectRow(at: IndexPath(row: row, section: 0), animated: false)
                tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .none
            }
        } else {
            selectedBreeds.remove("Every Pets")
            selectedBreeds.insert(breed)

            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: false)
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = .none
        }

        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        onSelectionDone?(selectedBreeds)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let breed = allBreeds[indexPath.row]
        selectedBreeds.remove(breed)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none

        if selectedBreeds.isEmpty {
            selectedBreeds = ["Every Pets"]
            selectEveryPetsRow()
        }

        onSelectionDone?(selectedBreeds)
    }
    
    private func selectEveryPetsRow() {

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }


}
