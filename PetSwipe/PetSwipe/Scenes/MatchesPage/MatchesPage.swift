//
//  MatchesPage.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit

let pets: [tempPet] = [
    tempPet(name: "Buddy", image: UIImage(named: "dog1") ?? UIImage(), age: 3, location: [47.6062, -122.3321], species: "Dog"),
    tempPet(name: "Whiskers", image: UIImage(named: "cat1") ?? UIImage(), age: 2, location: [34.0522, -118.2437], species: "Cat"),
    tempPet(name: "Chirpy", image: UIImage(named: "bird1") ?? UIImage(), age: 1, location: [40.7128, -74.0060], species: "Bird")
]

class MatchesPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell", for: indexPath) as? MatchesTableViewCell else {
            return UITableViewCell()
        }
        cell.matchImage.image = pets[indexPath.row].image
        cell.contentView.backgroundColor = .red
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
    
    override func viewDidAppear(_ animated: Bool) {
        MatchesTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MatchesTableView.delegate = self
        MatchesTableView.dataSource = self


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
