//
//  LocationManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 13.11.25.
//

import Foundation
import CoreLocation
import Combine
import os

/// Manages starting and stopping of location updates with high accuracy
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    var samples: Int = 0
    @Published var authorizationDenied: Bool = false
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    private let locationManager = CLLocationManager()
    private var isRecording: Bool = false
    
    // Dispatch for writing the samples to file
    private let fileWriteQueue = DispatchQueue(label: "com.app.location.fileWrite", qos: .utility)
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        // Set accuracy or how often location updates are triggered
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Alternatives: kCLLocationAccuracyBestForNavigation für höchste Genauigkeit
        
        // Minimum distance (in meters) before location update
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // For Background-Update
        // locationManager.allowsBackgroundLocationUpdates = true
        // locationManager.pausesLocationUpdatesAutomatically = false
        
        // Request authorization
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts location updates with high accuracy
    func startUpdates(path: URL) {
        // Do nothing if already running
        if isRecording {
            AppLogger.location.warning("Location updates already running")
            return
        }
        
        let filename = "location_data.csv"
        let url = path.appendingPathComponent(filename)
        currentFileURL = url
        
        // Create file and write csv table header
        let header = "timestamp,latitude,longitude,horizontal_accuracy,vertical_accuracy,altitude,speed,course\n"
        try? header.write(to: url, atomically: true, encoding: .utf8)
        
        // Open FileHandle
        fileHandler = try? FileHandle(forWritingTo: url)
        fileHandler?.seekToEndOfFile()
        
        samples = 0
        isRecording = true
        
        // Start location updates
        locationManager.startUpdatingLocation()
        AppLogger.location.info("Started location updates.")
    }
    
    /// Stops location updates
    func stopUpdates() {
        if !isRecording {
            AppLogger.location.warning("No location updates running.")
            return
        }
        
        isRecording = false
        locationManager.stopUpdatingLocation()
        AppLogger.location.info("Stopped location updates.")
        
        // Wait till all samples have been written to file
        fileWriteQueue.sync {
            // Close FileHandle
            try? fileHandler?.close()
            fileHandler = nil
        }
        
        AppLogger.file.info("Saved location data to: \(self.currentFileURL?.path ?? "")")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRecording else { return }
        
        // Process all locations (usually just one, but can be multiple)
        for location in locations {
            samples += 1
            
            // Format: timestamp,latitude,longitude,horizontal_accuracy,vertical_accuracy,altitude,speed,course
            let line = "\(location.timestamp.timeIntervalSince1970),\(location.coordinate.latitude),\(location.coordinate.longitude),\(location.horizontalAccuracy),\(location.verticalAccuracy),\(location.altitude),\(location.speed),\(location.course)\n"
            
            // Write asyncronusly to queue as to not block event handler
            self.fileWriteQueue.async {
                self.samples += 1
                if let fh = self.fileHandler, let data = line.data(using: .utf8) {
                    fh.write(data)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLogger.location.error("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            AppLogger.location.debug("Location authorization: Not Determined")
        case .restricted:
            AppLogger.location.debug("Location authorization: Restricted")
            authorizationDenied = true
        case .denied:
            AppLogger.location.debug("Location authorization: Denied")
            authorizationDenied = true
        case .authorizedAlways:
            AppLogger.location.debug("Location authorization: Always")
        case .authorizedWhenInUse:
            AppLogger.location.debug("Location authorization: When in use")
        @unknown default:
            AppLogger.location.debug("Location authorization: Unknown")
        }
    }
}
