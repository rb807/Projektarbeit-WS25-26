//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        VStack {
            HStack {
                Text("IMU-Datenerfassung")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
            }
            
            ZStack {
                if let session = cameraManager.captureSessionIfReady {
                    CameraPreview(session: session)
                } else {
                    ProgressView("Kamera wird initialisiert …")
                }
            }
            .onAppear {
                Task {
                    await cameraManager.setUpCaptureSession()
                }
            }
            
            VStack {
                motionView(motionManager: motionManager)
                
                HStack {
                    Button("Start") {
                        motionManager.startMotionCapture()
                        //cameraManager.startRecording()
                    }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    Button("Stop") {
                        motionManager.stopMotionCapture()
                        //cameraManager.stopRecording()
                    }
                        .buttonStyle(.bordered)
                        .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
