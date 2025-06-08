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
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!

    // MARK: - Data
    var selectedBreeds = Set<String>()
    let ageOptions = Array(1...20)
    var allBreeds: [String] = []
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerViews()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadUserInfo()
            self.loadUserPreferences()
        }
        
        fetchBreedsFromPets() 
    }
    
    private func setupPickerViews() {
        minAgePicker.dataSource = self
        minAgePicker.delegate = self
        maxAgePicker.dataSource = self
        maxAgePicker.delegate = self
    }
    
    
    // MARK: - Firebase fetching
    func loadUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? "Unknown"
                let email = data?["email"] as? String ?? "Unknown"
                
                print("Loaded user info from Firestore:")
                print("name =", name)
                print("email =", email)
                
                DispatchQueue.main.async {
                    self.userNameLabel.text = name
                    self.userEmailLabel.text = email
                }
                
            } else {
                print("Failed to load user info: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    
    func loadUserPreferences() {
        FirebaseManager.shared.fetchUserPreferences { [weak self] result in
            switch result {
            case .success(let preferences):
                DispatchQueue.main.async {
                    if let minIndex = self?.ageOptions.firstIndex(of: preferences.minAge) {
                        self?.minAgePicker.selectRow(minIndex, inComponent: 0, animated: false)
                    }
                    if let maxIndex = self?.ageOptions.firstIndex(of: preferences.maxAge) {
                        self?.maxAgePicker.selectRow(maxIndex, inComponent: 0, animated: false)
                    }
                    self?.updateAgeRangeLabel()
                    
                    self?.distanceSlider.value = Float(preferences.distance)
                    self?.updateDistanceLabel()
                    
                    self?.selectedBreeds = Set(preferences.breeds)
                    self?.updateBreedLabel()
                }
            case .failure(let error):
                print("Failed to load user preferences: \(error)")
                DispatchQueue.main.async {
                    self?.minAgePicker.selectRow(2, inComponent: 0, animated: false)
                    self?.maxAgePicker.selectRow(4, inComponent: 0, animated: false)
                    self?.updateAgeRangeLabel()
                    
                    self?.distanceSlider.value = 50
                    self?.updateDistanceLabel()
                    
                    self?.selectedBreeds = Set<String>()
                    self?.updateBreedLabel()
                }
            }
        }
    }
    
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
    

    // MARK: - Distance Slider
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
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
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

    // MARK: - Age Range
    func updateAgeRangeLabel() {
        let minAge = ageOptions[minAgePicker.selectedRow(inComponent: 0)]
        let maxAge = ageOptions[maxAgePicker.selectedRow(inComponent: 0)]
        
        let correctedMin = min(minAge, maxAge)
        let correctedMax = max(minAge, maxAge)
        
        ageLabel.text = "\(correctedMin)–\(correctedMax)"
        updateAgeRangeInFirestore(min: correctedMin, max: correctedMax)
    }
    
    func updateAgeRangeInFirestore(min: Int, max: Int) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user, skip update")
            return
        }
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
    
    // MARK: - Breed
    func updateBreedLabel() {
        if selectedBreeds.isEmpty || selectedBreeds.contains("Every Pets") {
            breedLabel.text = "Every Pets"
        } else {
            let selected = Array(selectedBreeds)
            let displayCount = min(3, selected.count)
            let displayBreeds = selected.prefix(displayCount)

            if selected.count > 3 {
                breedLabel.text = displayBreeds.joined(separator: ", ") + ", ..."
            } else {
                breedLabel.text = displayBreeds.joined(separator: ", ")
            }
        }
    }
    func updateBreedPreference() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No current user, skip update")
            return
        }
        let db = Firestore.firestore()

        var breedMap: [String: Bool] = [:]

        let isEveryPetsSelected = selectedBreeds.contains("Every Pets")

        for breed in allBreeds {
            if breed == "Every Pets" { continue }

            if isEveryPetsSelected {
                breedMap[breed] = true
            } else {
                breedMap[breed] = selectedBreeds.contains(breed)
            }
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
    // MARK: - Nav to
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            if allBreeds.isEmpty {
                print("Breeds not loaded yet.")
                return
            }
            performSegue(withIdentifier: "BreedSelectionSegue", sender: nil)
        }
        else if indexPath.section == 0 && indexPath.row == 5 {
            handleSignOut()
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            openAppSettings()
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
    
    // MARK: - Signout
    func handleSignOut() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure you want to sign out?",
                                      preferredStyle: .alert)

        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                print("User signed out")

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = windowScene.delegate as? UIWindowSceneDelegate,
                   let window = delegate.window as? UIWindow {
                    window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    window.makeKeyAndVisible()
                }

            } catch {
                print("Failed to sign out: \(error)")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(signOutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Setting
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                print("Opened Settings: \(success)")
            }
        }
    }
}

