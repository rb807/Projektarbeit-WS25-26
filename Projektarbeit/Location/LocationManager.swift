//
//  LocationManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 13.11.25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Our manager to start and stop updates and specifiy settings
    let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var samples: Int = 0
    
    func setUpLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    // Delegate function for when a new location is recieved
    // Updates user location to last given location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        samples = samples + 1
    }
     
    // Delegate function for when User changes authorization
    // Updates authorization status and stops location tracking if permission is denied
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .notDetermined || status == .denied || status == .restricted {
            manager.stopUpdatingLocation()
        }
    }
    
    // Starts location updates if the user has given permission
    func startUpdates() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
            print("Started updating location")
        }
    }
    
    // Stops location updates
    func stopUpdates() {
        manager.stopUpdatingLocation()
        print("Stopped updating location")
    }
    
    func saveData() {
        
    }
}
