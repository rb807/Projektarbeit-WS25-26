//
//  MotionManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager() // Initializes the CMMotionManager which is used to start the various motion sensors
    @Published var motionData: [MotionData] = [] // A simple array which takes MotionData objects that store our measurements
    let queue = OperationQueue()
    
    // Starts the collecting of motion data
    func startMotionCapture() {
        if motionManager.isDeviceMotionAvailable { // Check if the device can even measure device motion
            if !motionManager.isDeviceMotionActive { // Check if device motion is already active
                
                motionData.removeAll() // removes all of our previous measurements from the array
                
                self.motionManager.deviceMotionUpdateInterval = 0.5 // Defines how often the sensor data is measured currently twice a second
                self.motionManager.showsDeviceMovementDisplay = true
                
                self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue, withHandler: { (data, error) in
                    // unpack to check that data is not nil
                    if let validData = data {
                        let capturedData = MotionData(attitudeData: validData.attitude, userAccelerationData: validData.userAcceleration, gyroscopicData: validData.rotationRate, timestamp: validData.timestamp)
                        // push collected data from queue to main thread and add to motionData array
                        DispatchQueue.main.async {
                            self.motionData.append(capturedData)
                        }
                        // self.motionData.last?.printMeasurements() // Prints the measurements to console for debug purposes
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
    }
    
    // Checks if motion capture is active and stopping it if true
    func stopMotionCapture() -> Void {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
            print("Stopped device motion capture.")
            exportToCsv() // saves data to a .csv file after stopping measurements
        } else {
            print("Motion capture not active.")
        }
    }
    
    // Itterates over captured motion data turning the measurements into strings and writing thme to a csv file in the apps document folder
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
}

