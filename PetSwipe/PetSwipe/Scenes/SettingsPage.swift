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
    
    @IBOutlet weak var breedDropdownField: UITextField!
    @IBOutlet weak var breedLabel: UILabel!

    var selectedBreed: String? = nil
    let breedPicker = UIPickerView()
    
    // MARK: - Data
    let ageOptions = Array(1...20)
    var allBreeds: [String] = []
    
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
        
        breedPicker.delegate = self
        breedPicker.dataSource = self
        breedDropdownField.inputView = breedPicker
        breedDropdownField.isHidden = true
        
        self.view.addSubview(breedDropdownField)
        
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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == minAgePicker || pickerView == maxAgePicker {
            updateAgeRangeLabel()
        } else {
            let breed = allBreeds[row]
            selectedBreed = (breed == "Every Pets") ? nil : breed
            updateBreedPreference(breed: selectedBreed)
            updateBreedLabel()
            breedDropdownField.resignFirstResponder()
        }
    }
    
    func updateBreedLabel() {
        breedLabel.text = selectedBreed ?? "Every Pets"
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
    
    
    func updateBreedPreference(breed: String?) {
        let userId = Auth.auth().currentUser?.uid ?? "yourTestUserID"
        let db = Firestore.firestore()

        var updateData: [String: Any]
        if let breed = breed {
            updateData = ["preferences.breed": breed]
        } else {
            updateData = ["preferences.breed": FieldValue.delete()]
        }

        db.collection("users").document(userId).updateData(updateData) { error in
            if let error = error {
                print("Failed to update breed preference: \(error)")
            } else {
                print("Breed preference updated:", breed ?? "All Pets")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            breedDropdownField.becomeFirstResponder()
        }
    }
}


