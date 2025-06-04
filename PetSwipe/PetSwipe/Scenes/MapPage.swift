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
        addCenterButton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let fakeUserLocation = CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4183)
            let annotation = MKPointAnnotation()
            annotation.coordinate = fakeUserLocation
            annotation.title = "Simulated Location"
            self.mapView.addAnnotation(annotation)
        }

        // Do any additional setup after loading the view.
    }
    
    func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
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
            print("📍 Received user location: \(locations.first?.coordinate)")
            if let location = locations.first {
                userLocation = location

                let shelterLoc = CLLocation(latitude: shelterLocation.latitude, longitude: shelterLocation.longitude)
                let distanceInMeters = location.distance(from: shelterLoc)
                let distanceInMiles = distanceInMeters * 0.000621371

                distanceLabel.text = String(format: "Distance to shelter: %.2f miles", distanceInMiles)

                locationManager.stopUpdatingLocation()
            }
        }
    
    func addCenterButton() {
        let centerButton = UIButton(type: .system)
        centerButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        centerButton.tintColor = .systemBlue
        centerButton.backgroundColor = .systemBackground
        centerButton.layer.cornerRadius = 25
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.2
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        centerButton.layer.shadowRadius = 2
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        centerButton.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)

        view.addSubview(centerButton)

        NSLayoutConstraint.activate([
            centerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            centerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            centerButton.widthAnchor.constraint(equalToConstant: 50),
            centerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func centerOnUserLocation() {
        guard let userCoordinate = userLocation?.coordinate else { return }

        let region = MKCoordinateRegion(
            center: userCoordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location access granted")
            locationManager.startUpdatingLocation()
        case .denied:
            print("❌ Location access denied")
        case .notDetermined:
            print("🕐 Location permission not yet granted")
        case .restricted:
            print("🔒 Location access restricted")
        @unknown default:
            print("❓ Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❗️Failed to get location: \(error.localizedDescription)")
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
