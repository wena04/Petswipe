//
//  Settings.swift
//  PetSwipe
//
//  Created by 郭家玮 on 5/29/25.
//



import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsPage: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var minAgePicker: UIPickerView!
    @IBOutlet weak var maxAgePicker: UIPickerView!
    @IBOutlet weak var breedLabel: UILabel!

    // MARK: - Data
    var selectedBreeds = Set<String>()
    let ageOptions = Array(1...20)
    var allBreeds: [String] = []
    
    // MARK: - Firebase fetching
    func fetchBreedsFromPets() {
        let db = Firestore.firestore()

        db.collection("pets").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching breeds: \(error)")
                return
            }

            var breedSet = Set<String>()
            for doc in snapshot?.documents ?? [] {
                if let breed = doc.data()["petBreed"] as? String {
                    breedSet.insert(breed)
                }
            }

            self.allBreeds = ["Every Pets"] + Array(breedSet).sorted()
            print("All breeds loaded:", self.allBreeds)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PickerView setup
        minAgePicker.dataSource = self
        minAgePicker.delegate = self
        maxAgePicker.dataSource = self
        maxAgePicker.delegate = self
        
        // Default age range
        minAgePicker.selectRow(2, inComponent: 0, animated: false) // 3
        maxAgePicker.selectRow(4, inComponent: 0, animated: false) // 5
        updateAgeRangeLabel()
        
        // Default distance
        distanceSlider.value = 50
        updateDistanceLabel()
        
        fetchBreedsFromPets()
        
        
    }

    // MARK: - Slider Action
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        updateDistanceLabel()
        let distance = Int(sender.value)
        updateDistanceInFirestore(distance)
    }

    func updateDistanceLabel() {
        let distance = Int(distanceSlider.value)
        distanceLabel.text = "\(distance) mi"
    }
    
    func updateDistanceInFirestore(_ distance: Int) {
        let userId = Auth.auth().currentUser?.uid ?? "yourTestUserID"
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData([
            "preferences.distance": distance
        ]) { error in
            if let error = error {
                print("Failed to update distance: \(error)")
            } else {
                print("Distance updated to \(distance)")
            }
        }
    }

    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == minAgePicker {
            let minAge = ageOptions[row]

            let maxSelectedAge = ageOptions[maxAgePicker.selectedRow(inComponent: 0)]
            if maxSelectedAge <= minAge {
                if let nextValidIndex = ageOptions.firstIndex(where: { $0 > minAge }) {
                    maxAgePicker.selectRow(nextValidIndex, inComponent: 0, animated: true)
                }
            }
            updateAgeRangeLabel()

        } else if pickerView == maxAgePicker {
            let maxAge = ageOptions[row]
            let minSelectedAge = ageOptions[minAgePicker.selectedRow(inComponent: 0)]
            if maxAge <= minSelectedAge {
                if let previousValidIndex = ageOptions.lastIndex(where: { $0 < maxAge }) {
                    minAgePicker.selectRow(previousValidIndex, inComponent: 0, animated: true)
                }
            }
            updateAgeRangeLabel()
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == minAgePicker || pickerView == maxAgePicker {
            return ageOptions.count
        } else {
            return allBreeds.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == minAgePicker || pickerView == maxAgePicker {
            return "\(ageOptions[row])"
        } else {
            return allBreeds[row]
        }
    }


    func updateAgeRangeLabel() {
        let minAge = ageOptions[minAgePicker.selectedRow(inComponent: 0)]
        let maxAge = ageOptions[maxAgePicker.selectedRow(inComponent: 0)]
        
        let correctedMin = min(minAge, maxAge)
        let correctedMax = max(minAge, maxAge)
        
        ageLabel.text = "\(correctedMin)–\(correctedMax)"
        updateAgeRangeInFirestore(min: correctedMin, max: correctedMax)
    }
    
    func updateAgeRangeInFirestore(min: Int, max: Int) {
        let userId = Auth.auth().currentUser?.uid ?? "yourTestUserID"
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData([
            "preferences.ageRange": [min, max]
        ]) { error in
            if let error = error {
                print("Failed to update age range: \(error)")
            } else {
                print("Age range updated to [\(min), \(max)]")
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            if allBreeds.isEmpty {
                print("Breeds not loaded yet.")
                return
            }
            performSegue(withIdentifier: "BreedSelectionSegue", sender: nil)
        }
    }
    
    func updateBreedLabel() {
        if selectedBreeds.isEmpty {
            breedLabel.text = "Every Pets"
        } else {
            breedLabel.text = selectedBreeds.joined(separator: ", ")
        }
    }

    func updateBreedPreference() {
        let userId = Auth.auth().currentUser?.uid ?? "yourTestUserID"
        let db = Firestore.firestore()

        var breedMap: [String: Bool] = [:]
        for breed in allBreeds {
            if breed == "Every Pets" { continue } 
            breedMap[breed] = selectedBreeds.contains(breed)
        }

        db.collection("users").document(userId).updateData([
            "preferences.breeds": breedMap
        ]) { error in
            if let error = error {
                print("Failed to update breed map:", error)
            } else {
                print("Breed map updated:", breedMap)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreedSelectionSegue" {
            if let vc = segue.destination as? BreedSelectionPage {
                vc.allBreeds = self.allBreeds
                vc.selectedBreeds = self.selectedBreeds
                vc.onSelectionDone = { [weak self] selected in
                    self?.selectedBreeds = selected
                    self?.updateBreedLabel()
                    self?.updateBreedPreference()
                }
            }
        }
    }

}


