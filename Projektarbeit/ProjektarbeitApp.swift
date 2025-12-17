//
//  ProjektarbeitApp.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

@main
struct ProjektarbeitApp: App {
    
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var recordingTimer = RecordingTimer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionManager)
                .environmentObject(cameraManager)
                .environmentObject(locationManager)
                .environmentObject(recordingTimer)
        }
    }
}
