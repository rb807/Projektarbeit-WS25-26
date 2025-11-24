//
//  SampleView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 24.11.25.
//

import SwiftUI

struct SampleView: View {
    @ObservedObject var motionManager: MotionManager
    @ObservedObject var locationManager: LocationManager
    var body: some View {
        List {
            Section(header: Text("IMU-Samples")) {
                Text("Samples: \(motionManager.samples)")
            }
            Section(header: Text("Location-Samples")) {
                Text("Samples: \(locationManager.samples)")
            }
        }
    }
}

