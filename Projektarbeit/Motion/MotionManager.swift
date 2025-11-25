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
    let queue = OperationQueue()
    @Published var samples: Int = 0 // Simple indicator to check if anything is being measured
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    
    /// Checks if motion sensors are available and already running.
    /// Sets up the CMMotionManager instance and then starts the collecting of motion data
    func startMotionCapture(path: URL) {
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
        
        let filename = "IMU-measurements.csv"
        let url = path.appendingPathComponent(filename)
        currentFileURL = url
        samples = 0

        // Create file and write csv table header
        let header = "timestamp,yaw,pitch,roll,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"
        try? header.write(to: url, atomically: true, encoding: .utf8)
        
        // Open FileHandle
        fileHandler = try? FileHandle(forWritingTo: url)
        fileHandler?.seekToEndOfFile() // sets pointer to end of file
        
        NSLog("Started motion capture")
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
    }
    
    /// Stops the ongoing data collection if it is running.
    func stopMotionCapture() -> Void {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates() // Stop new motion updates
            try? fileHandler?.close() // Close the file handler
            NSLog("Stopped device motion capture.")
            NSLog("Saved file to: \(currentFileURL?.path ?? "")")
        } else {
            NSLog("Motion capture not active.")
        }
    }
}
