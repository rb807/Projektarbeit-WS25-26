//
//  MotionManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import Foundation
import CoreMotion
import Combine

/// Manages starting/stopping and storing of IMU-Data collection.
class MotionManager: ObservableObject {
    let motionManager = CMMotionManager() // Initializes the CMMotionManager which is used to start the various motion sensors
    // @Published var motionData: [MotionData] = [] // A simple array which takes MotionData objects that store our measurements
    let queue = OperationQueue()
    @Published var samples: Int = 0 // Simple indicator to check if anything is being measured
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    
    /// Checks if motion sensors are available and already running.
    /// Sets up the CMMotionManager instance and then starts the collecting of motion data
    func startMotionCapture() {
        let filename = generateFilename()
        let url = URL.documentsDirectory.appendingPathComponent(filename)
        currentFileURL = url
        samples = 0

        // Create file and write csv table header
        let header = "timestamp,yaw,pitch,roll,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"
        try? header.write(to: url, atomically: true, encoding: .utf8)
        
        // Open FileHandle
        fileHandler = try? FileHandle(forWritingTo: url)
        fileHandler?.seekToEndOfFile() // sets pointer to end of file
        
        // Check if motion sensors are available
        if motionManager.isDeviceMotionAvailable == false {
            print("Device motion is not available.")
            return
        }
        // Check if motion sensors are already active
        if motionManager.isDeviceMotionActive {
            print("Device motion capture already active.")
            return
        }
        
        self.motionManager.deviceMotionUpdateInterval = 1/30 // Defines how often the sensor data is updated (1/30 = 30hz)
        self.motionManager.showsDeviceMovementDisplay = true
        
        self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue, withHandler: { (data, error) in
            // unpack to check that data is not nil
            if let validData = data {
                // turn data into a string
                let line = "\(validData.timestamp),\(validData.attitude.yaw),\(validData.attitude.pitch),\(validData.attitude.roll),\(validData.userAcceleration.x),\(validData.userAcceleration.y),\(validData.userAcceleration.z),\(validData.rotationRate.x),\(validData.rotationRate.y),\(validData.rotationRate.z)\n"
                // Write data to file
                if let fh = self.fileHandler, let data = line.data(using: .utf8) {
                    fh.write(data)
                }
                // Update number of samples
                DispatchQueue.main.async {
                    self.samples = self.samples + 1
                }
            }
        })
        /*
        if motionManager.isDeviceMotionAvailable {
            if !motionManager.isDeviceMotionActive {
                
                motionData.removeAll()
                
                self.motionManager.deviceMotionUpdateInterval = 1/30 // Defines how often the sensor data is updated (1/30 = 30hz)
                self.motionManager.showsDeviceMovementDisplay = true
                
                self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue, withHandler: { (data, error) in
                    // unpack to check that data is not nil
                    if let validData = data {
                        // Create new Motion Data struct with new data
                        let capturedData = MotionData(attitudeData: validData.attitude, userAccelerationData: validData.userAcceleration, gyroscopicData: validData.rotationRate, timestamp: validData.timestamp)
                        // push collected data from queue to main thread and add to motionData array
                        DispatchQueue.main.async {
                            self.motionData.append(capturedData)
                        }
                    }
                })
                print("Started device motion capture.")
            } else {
                print("Device motion capture already active.")
            }
        } else {
            print("Device motion is not available.")
            return
        }
         */
    }
    
    /// Stops the ongoing data collection if it is running.
    func stopMotionCapture() -> Void {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates() // Stop new motion updates
            try? fileHandler?.close() // Close the file handler
            print("Stopped device motion capture.")
            print("Saved file to: \(currentFileURL?.path ?? "")")
        } else {
            print("Motion capture not active.")
        }
    }
    
    /*
    /// Itterates over captured motion data turning the measurements into strings and writing them to a csv file in the apps document folder.
    func exportToCsv() -> Void {
        let url = URL.documentsDirectory.appending(path: "measurements.csv")
        var csvText = "timestamp,yaw,pitch,roll,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"
        
        for md in self.motionData {
            csvText += "\(md.timestamp),\(md.attitudeData.yaw),\(md.attitudeData.pitch),\(md.attitudeData.roll),\(md.userAccelerationData.x),\(md.userAccelerationData.y),\(md.userAccelerationData.z),\(md.gyroscopicData.x),\(md.gyroscopicData.y),\(md.gyroscopicData.z)\n"
        }
        
        do {
            try csvText.write(to: url, atomically: true, encoding: .utf8)
            print("CSV file created at \(url.path)")
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    */
    
    /// Generates a filename based on the current date and time when the collection started.
    func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "measurements_\(timestamp).csv"
    }
}
