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
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        setupLocationServices()
        addCenterButton()
        addZoomOutButton()
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location

        if let pet = pet {
            shelterLocation = CLLocationCoordinate2D(latitude: pet.location[0], longitude: pet.location[1])
        }

        // Update distance
        let shelterLoc = CLLocation(latitude: shelterLocation.latitude, longitude: shelterLocation.longitude)
        let distanceInMeters = location.distance(from: shelterLoc)
        let distanceInMiles = distanceInMeters * 0.000621371
        distanceLabel.text = String(format: "Distance to shelter: %.2f miles", distanceInMiles)

        // Add annotation
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = shelterLocation
        annotation.title = "Local Animal Shelter"
        mapView.addAnnotation(annotation)

        // Draw route using MKDirections
        drawRoute(from: location.coordinate, to: shelterLocation)
    }
    
    func drawRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        mapView.removeOverlays(mapView.overlays)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile  // Change to .walking or .transit if needed

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(
                    route.polyline.boundingMapRect,
                    edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40),
                    animated: true
                )

                // 👇 Update label to include transport type and time
                let transportLabel = self.labelForTransportType(request.transportType)
                let distanceMiles = route.distance * 0.000621371
                let timeMinutes = route.expectedTravelTime / 60.0

                DispatchQueue.main.async {
                    self.distanceLabel.text = String(
                        format: "%@ • %.2f miles • %.0f min",
                        transportLabel,
                        distanceMiles,
                        timeMinutes
                    )
                }
            }
        }
    }

    func labelForTransportType(_ type: MKDirectionsTransportType) -> String {
        switch type {
        case .automobile: return "🚗 Driving"
        case .walking: return "🚶 Walking"
        case .transit: return "🚌 Transit"
        default: return "❓ Unknown"
        }
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let route = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: route)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("❗️Failed to get location: \(error.localizedDescription)")
        }

        @objc func centerOnUserLocation() {
            guard let userCoordinate = userLocation?.coordinate else { return }
            let region = MKCoordinateRegion(center: userCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }

        @objc func fitMapToRoute() {
            guard let userLocation = userLocation else { return }
            drawRoute(from: userLocation.coordinate, to: shelterLocation)
        }

        func addCenterButton() {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "location.fill"), for: .normal)
            button.tintColor = .systemBlue
            button.backgroundColor = .systemBackground
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        func addZoomOutButton() {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
            button.tintColor = .systemBlue
            button.backgroundColor = .systemBackground
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(fitMapToRoute), for: .touchUpInside)
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
