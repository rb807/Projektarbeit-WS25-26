//
//  LocationManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 13.11.25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: ObservableObject {
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var samples: Int = 0
    @Published var authorizationDenied: Bool = false
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    private var updatesTask: Task<Void, Never>? = nil
    
    func startUpdates() {
        // Falls bereits läuft nichts machen
        if let task = updatesTask, !task.isCancelled {
            NSLog("Location updates already running.")
            return
        }
        
        updatesTask = Task {
            // Obtain an asynchronous stream of updates.
            let stream = CLLocationUpdate.liveUpdates()
            NSLog("Started live location updates")
            let filename = generateFilename()
            let url = URL.documentsDirectory.appendingPathComponent(filename)
            currentFileURL = url
            samples = 0

            // Create file and write csv table header
            let header = "timestamp,latitude,longitude,horizontal_accuracy,vertical_accuracy,heading\n"
            try? header.write(to: url, atomically: true, encoding: .utf8)
            
            // Open FileHandle
            fileHandler = try? FileHandle(forWritingTo: url)
            fileHandler?.seekToEndOfFile()

            // Iterate over the stream and handle incoming updates.
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
                    }
                }
            } catch is CancellationError {
                NSLog("Location updates cancelled.")
            } catch {
                NSLog("Error occured: \(error)")
            }
        }
    }
    
    func stopUpdates() -> Void{
        // do nothing if ther are no live updates
        if updatesTask == nil {
            NSLog("Live location updates not running.")
            return
        }
        
        updatesTask?.cancel()
        updatesTask = nil
        
        // Datei schließen
        try? fileHandler?.close()
        fileHandler = nil
        NSLog("Saved file to: \(currentFileURL?.path ?? "")")
        NSLog("Stopped live location updates.")
    }
    
    /// Generates a filename based on the current date and time when the collection started.
    func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "location_data_\(timestamp).csv"
    }
}
