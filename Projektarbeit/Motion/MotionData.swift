//
//  MotionData.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 17.10.25.
//

import Foundation
import CoreMotion

/// Struct for storing motion data collected trough MotionManager
///
/// - Parameters:
///     - id: Universally Unique Identifier for each instance
///     - attitudeData: attitude data of the device (yaw, pitch, roll)
///     - userAccelerationData: acceleration imparted on the device by the user
///     - gyroscopicData: acceleration of the device around its axis
///     - timestamp: exceeded time since last device boot
///     
struct MotionData: Identifiable {
    let id = UUID()
    let attitudeData: CMAttitude
    let userAccelerationData: CMAcceleration
    let gyroscopicData: CMRotationRate
    let timestamp: TimeInterval
    
    func printMeasurements() -> Void {
        print("Beschleunigung: \nx =", self.userAccelerationData.x, "\ny =", self.userAccelerationData.y, "\nz =", self.userAccelerationData.z)
        print("Attitude: \nyaw =", self.attitudeData.yaw, "\nroll =", self.attitudeData.roll, "\npitch =", self.attitudeData.pitch)
        //print("Gyroskop: ", self.gyroscopicData)
        print("Zeitstempel: ", self.timestamp)
    }
}
