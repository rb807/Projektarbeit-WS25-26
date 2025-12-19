//
//  MotionManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import Foundation
import CoreMotion
import Combine
import os

/// Manages starting/stopping and storing of IMU-Data collection.
class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    var samples: Int = 0
    
    private var fileHandler: FileHandle?
    private var currentFileURL: URL?
    
    // Dispatch for writing the samples to file 
    private let fileWriteQueue = DispatchQueue(label: "com.app.imu.fileWrite", qos: .utility)
    
    func startMotionCapture(path: URL) {
        if motionManager.isDeviceMotionAvailable == false {
            AppLogger.imu.error("Device motion is not available.")
            return
        }
        if motionManager.isDeviceMotionActive {
            AppLogger.imu.warning("Device motion is already active.")
            return
        }
        
        let filename = "IMU-measurements.csv"
        let url = path.appendingPathComponent(filename)
        currentFileURL = url
        samples = 0

        // Create file and write header
        let header = "timestamp,yaw,pitch,roll,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z,mag_x,mag_y,mag_z\n"
        try? header.write(to: url, atomically: true, encoding: .utf8)
        
        // Open FileHandle
        fileHandler = try? FileHandle(forWritingTo: url)
        fileHandler?.seekToEndOfFile()
        
        AppLogger.imu.info("Started device motion updates")
        self.motionManager.deviceMotionUpdateInterval = 0.03
        self.motionManager.showsDeviceMovementDisplay = true
        
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.queue) { (data, error) in
            if let validData = data {
                let magField = validData.magneticField.field
                let line = "\(validData.timestamp),\(validData.attitude.yaw),\(validData.attitude.pitch),\(validData.attitude.roll),\(validData.userAcceleration.x),\(validData.userAcceleration.y),\(validData.userAcceleration.z),\(validData.rotationRate.x),\(validData.rotationRate.y),\(validData.rotationRate.z),\(magField.x),\(magField.y),\(magField.z)\n"
                
                // Write asyncronusly to queue as to not block event handler
                self.fileWriteQueue.async {
                    self.samples += 1
                    if let fh = self.fileHandler, let data = line.data(using: .utf8) {
                        fh.write(data)
                    }
                }
            }
        }
    }
    
    func stopMotionCapture() {
        if motionManager.isDeviceMotionActive {
            AppLogger.imu.info("Stopping device motion capture.")
            motionManager.stopDeviceMotionUpdates()
            
            // Wait till all samples have been written to file
            fileWriteQueue.sync {
                try? fileHandler?.close()
                fileHandler = nil
            }
            
            AppLogger.imu.info("Device motion capture stopped.")
            AppLogger.imu.debug("Nr. of samples: \(self.samples)")
            AppLogger.file.debug("Saved IMU data to: \(self.currentFileURL?.path ?? "")")
        } else {
            AppLogger.imu.info("No need to stop device motion capture as it was not active.")
        }
    }
}
