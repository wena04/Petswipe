//
//  Map.swift
//  PetSwipe
//
//  Created by Anthony  Wen on 5/21/25.
//

import UIKit
import MapKit

class MapPage: UIViewController {
    
    var pet : matchesPet?

    @IBOutlet weak var mapView: MKMapView!

    var shelterLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        // Do any additional setup after loading the view.
    }
    
    func setupMap() {
        
        guard let pet = pet else {
                   fatalError("No pet provided")
               }
        
        shelterLocation = CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude)
        let region = MKCoordinateRegion(
        center: shelterLocation,
        latitudinalMeters: 1000, 
        longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = shelterLocation
        annotation.title = "Local Animal Shelter"
        annotation.subtitle = "Find your new best friend here!"
        mapView.addAnnotation(annotation)
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
