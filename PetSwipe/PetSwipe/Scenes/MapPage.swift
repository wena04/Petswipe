//
//  Map.swift
//  PetSwipe
//
//  Created by Anthony  Wen on 5/21/25.
//

import UIKit
import MapKit
import CoreLocation

class MapPage: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    var pet : matchesPet?

    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var shelterLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupLocationServices()
        setupMap()
        // Do any additional setup after loading the view.
    }
    
    func setupLocationServices() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    
    func setupMap() {
        
        guard let pet = pet else {
                   fatalError("No pet provided")
               }
        
        shelterLocation = CLLocationCoordinate2D(latitude: pet.location[0], longitude: pet.location[1])
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                userLocation = location

                let shelterLoc = CLLocation(latitude: shelterLocation.latitude, longitude: shelterLocation.longitude)
                let distanceInMeters = location.distance(from: shelterLoc)
                let distanceInMiles = distanceInMeters * 0.000621371

                distanceLabel.text = String(format: "Distance to shelter: %.2f miles", distanceInMiles)

                locationManager.stopUpdatingLocation()
            }
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
