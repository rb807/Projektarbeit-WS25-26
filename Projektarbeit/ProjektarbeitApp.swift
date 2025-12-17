//
//  ProjektarbeitApp.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

@main
struct ProjektarbeitApp: App {
    // WICHTIG: Shared Managers für die ganze App
    // Nur EINE Instanz, egal wie oft Views wechseln
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var recordingTimer = RecordingTimer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Teile Manager mit allen Child Views
                .environmentObject(motionManager)
                .environmentObject(cameraManager)
                .environmentObject(locationManager)
                .environmentObject(recordingTimer)
        }
    }
}
