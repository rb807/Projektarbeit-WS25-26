//
//  LocationManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 13.11.25.
//

import Foundation
import CoreLocation
import Combine

/// Manages starting and stopping of location updates
class LocationManager: ObservableObject {
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var samples: Int = 0
    @Published var authorizationDenied: Bool = false
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    private var updatesTask: Task<Void, Never>? = nil
    
    /// Starts live location updates. Does nothing if they are already active.
    func startUpdates(path: URL) {
        // Do nothing if already running
        if let task = updatesTask, !task.isCancelled {
            NSLog("Location updates already running.")
            return
        }
        
        updatesTask = Task {
            // Obtain an asynchronous stream of updates
            let stream = CLLocationUpdate.liveUpdates()
            NSLog("Started live location updates")
            
            let filename = "location_data.csv"
            let url = path.appendingPathComponent(filename)
            currentFileURL = url
            
            // Create file and write csv table header
            let header = "timestamp,latitude,longitude,horizontal_accuracy,vertical_accuracy,heading\n"
            try? header.write(to: url, atomically: true, encoding: .utf8)
            
            // Open FileHandle
            fileHandler = try? FileHandle(forWritingTo: url)
            fileHandler?.seekToEndOfFile()
            
            samples = 0
            // Iterate over the stream and handle incoming updates
            do {
                for try await update in stream {
                    
                    if let loc = update.location {
                        samples += 1
                        
                        let line = "\(loc.timestamp),\(loc.coordinate.latitude),\(loc.coordinate.longitude),\(loc.horizontalAccuracy),\(loc.verticalAccuracy),\(loc.course)\n"
                        
                        if let fh = fileHandler, let data = line.data(using: .utf8) {
                            fh.write(data)
                        }
                        
                    } else if update.authorizationDenied {
                        authorizationDenied = true
                        return
                    }
                }
            } catch is CancellationError {
                NSLog("Location updates cancelled.")
            } catch {
                NSLog("Error occured: \(error)")
            }
        }
    }
    
    /// Stops live location updates. Does nothing if they are not active.
    func stopUpdates() -> Void{
        // do nothing if ther are no live updates
        if updatesTask == nil {
            NSLog("Live location updates not running.")
            return
        }
        
        updatesTask?.cancel()
        updatesTask = nil
        
        // Close FileHandle
        try? fileHandler?.close()
        fileHandler = nil
        NSLog("Saved file to: \(currentFileURL?.path ?? "")")
        NSLog("Stopped live location updates.")
    }
}
