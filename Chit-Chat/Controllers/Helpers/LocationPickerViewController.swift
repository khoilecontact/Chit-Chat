//
//  LocationPickerViewController.swift
//  Chit-Chat
//
//  Created by Phát Nguyễn on 15/02/2022.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    let locationManager = CLLocationManager()
    
    init(coordinates: CLLocationCoordinate2D?) {
        super.init(nibName: nil, bundle: nil)
        guard coordinates != nil else {
            return
        }

        self.coordinates = coordinates
        self.isPickable = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        locationManager.requestWhenInUseAuthorization()

        // Current location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))

            // Add Gesture to map
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(didTapMap(_:)))

            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            guard let coordinates = coordinates else {
                return
            }
            // drop pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        
        view.addSubview(map)
    }

    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        // clear if have 2 or more annotations
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }

        // drop pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
}

extension LocationPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate as? CLLocationCoordinate2D else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        // drop pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = location
        self.coordinates = pin.coordinate
        self.map.addAnnotation(pin)
    }
}
