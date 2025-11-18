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
    
    func setUpLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    // Delegate function for when a new location is recieved
    // Updates user location to last given location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
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
    func startTracking() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func startLiveUpdates() {
        Task {
            let updates = CLLocationUpdate.liveUpdates()
            for try await update in updates {
                 if update.location != nil {
                      // Process the location.
                     userLocation = update.location
                 } else if update.authorizationDenied {
                     // Process the authorization denied state change.
                     return
                 } else {
                     // Process other state changes.
                 }
            }
        }
    }
    
    // Stops location updates
    func stopTracking() {
        manager.stopUpdatingLocation()
    }
    
    func saveData() {
        
    }
}
