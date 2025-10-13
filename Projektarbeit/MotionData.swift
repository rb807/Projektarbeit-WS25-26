//
//  MotionData.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import Foundation
import CoreMotion
internal import Combine

struct MotionData: Identifiable {
    let id = UUID()
    let attitudeData: CMAttitude
    let accelerationData: CMAcceleration
    let gyroscopicData: CMRotationRate
    let timestamp: TimeInterval
    
    func printMeasurements() -> Void {
        print("Beschleunigung: \nx =", self.accelerationData.x, "\ny =", self.accelerationData.y, "\nz =", self.accelerationData.z)
        print("Attitude: \nyaw =", self.attitudeData.yaw, "\nroll =", self.attitudeData.roll, "\npitch =", self.attitudeData.pitch)
        //print("Gyroskop: ", self.gyroscopicData)
        print("Zeitstempel: ", self.timestamp)
    }
}

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    @Published var motionData: [MotionData] = []
    let queue = OperationQueue()
    
    
    func startMotionCapture() {
        if motionManager.isDeviceMotionAvailable {
            if !motionManager.isDeviceMotionActive {
                motionData.removeAll()
                self.motionManager.deviceMotionUpdateInterval = 1.0
                self.motionManager.showsDeviceMovementDisplay = true
                self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.queue, withHandler: { (data, error) in
                    // unpack to check that data is not nil
                    if let validData = data {
                        let capturedData = MotionData(attitudeData: validData.attitude, accelerationData: validData.userAcceleration, gyroscopicData: validData.rotationRate, timestamp: validData.timestamp)
                        DispatchQueue.main.async {
                            self.motionData.append(capturedData)
                        }
                        self.motionData.last?.printMeasurements()
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
    
    
    func stopMotionCapture() -> Void {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
            print("Stopped device motion capture.")
        } else {
            print("Motion capture not active.")
        }
    }
    
    func exportToCsv() -> Void {
        let url = URL.documentsDirectory.appending(path: "measurements.csv")
        var csvText = "timestamp,yaw,pitch,roll,accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"
        
        for md in self.motionData {
            csvText += "\(md.timestamp),\(md.attitudeData.yaw),\(md.attitudeData.pitch),\(md.attitudeData.roll),\(md.accelerationData.x),\(md.accelerationData.y),\(md.accelerationData.z),\(md.gyroscopicData.x),\(md.gyroscopicData.y),\(md.gyroscopicData.z)\n"
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

