//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

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
                        .onAppear {
                            Task {
                                await cameraManager.setUpCaptureSession()
                            }
                        }
                }
            }
            
            VStack {
                
                GroupBox {
                    Text("Number of samples: \(motionManager.motionData.count)")
                }
    
                
                HStack {
                    Button("Start") {
                        motionManager.startMotionCapture()
                        cameraManager.startRecording()
                    }
                        .buttonStyle(.borderedProminent)
                    Button("Stop") {
                        motionManager.stopMotionCapture()
                        cameraManager.stopRecording()
                    }
                        .buttonStyle(.bordered)
                    Button("Save") {
                        motionManager.exportToCsv()
                     
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}

struct valueView: View {
    var body: some View {
        
    }
}

#Preview {
    ContentView()
}
