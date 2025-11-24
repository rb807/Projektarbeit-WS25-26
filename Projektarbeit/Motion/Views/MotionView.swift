//
//  MotionView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 28.10.25.
//

import SwiftUI
import CoreMotion


struct MotionView: View {
    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        List {
            Section(header: Text("IMU-Samples")) {
                /*
                Text("Samples: \(motionManager.motionData.count)")
                Text("x = \(((motionManager.motionData.last?.userAccelerationData.x ?? 0.0) * 9.8).formatted()) m/s")
                Text("y = \(((motionManager.motionData.last?.userAccelerationData.y ?? 0.0) * 9.8).formatted()) m/s")
                Text("z = \(((motionManager.motionData.last?.userAccelerationData.z ?? 0.0) * 9.8).formatted()) m/s")
                */
                Text("Samples: \(motionManager.samples)")
            }
        }
        /*
        GroupBox {
            Text("Samples: \(motionManager.motionData.count)")
            Text("Acceleration: ")
            Text("x = \(((motionManager.motionData.last?.userAccelerationData.x ?? 0.0) * 9.8).formatted()) m/s")
            Text("y = \(((motionManager.motionData.last?.userAccelerationData.y ?? 0.0) * 9.8).formatted()) m/s")
            Text("z = \(((motionManager.motionData.last?.userAccelerationData.z ?? 0.0) * 9.8).formatted()) m/s")
        }
        */
    }
}
