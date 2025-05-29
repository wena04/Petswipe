//
//  Settings.swift
//  PetSwipe
//
//  Created by 郭家玮 on 5/29/25.
//



import UIKit

class SettingsPage: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var minAgePicker: UIPickerView!
    @IBOutlet weak var maxAgePicker: UIPickerView!
    
    // MARK: - Data
    let ageOptions = Array(1...20)
    
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
    }

    // MARK: - Slider Action
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        updateDistanceLabel()
    }

    func updateDistanceLabel() {
        let distance = Int(distanceSlider.value)
        distanceLabel.text = "\(distance) mi"
    }

    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(ageOptions[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateAgeRangeLabel()
    }

    func updateAgeRangeLabel() {
        let minAge = ageOptions[minAgePicker.selectedRow(inComponent: 0)]
        let maxAge = ageOptions[maxAgePicker.selectedRow(inComponent: 0)]
        
        let correctedMax = max(maxAge, minAge) // prevent inverted range
        ageLabel.text = "\(minAge)–\(correctedMax)"
    }
}


