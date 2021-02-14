//
//  LocationService.swift
//  BobchWeather
//
//  Created by Vladimir Barus on 14.02.2021.
//

import CoreLocation

protocol LocationServiceDelegate: class {
    func processingLocation(_ lat: Double, _ long: Double)
    func processingLocationError(_ error: NSError)
}

protocol LocationServiceProtocol: class {
    var delegate: LocationServiceDelegate? { get set }
    func getLocation()
}

class LocationService: NSObject, LocationServiceProtocol {
    var locationManager: CLLocationManager?
    weak var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    func getLocation() {
    
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        delegate?.processingLocation(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.processingLocationError(error as NSError)
    }
}
