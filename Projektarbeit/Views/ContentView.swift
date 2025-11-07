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
                        Task {
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask { await motionManager.startMotionCapture() }
                                group.addTask { await cameraManager.startRecording() }
                            }
                        }
                    }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        .disabled(!cameraManager.isRunning)
                    
                    Button("Stop") {
                        Task {
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask { await motionManager.stopMotionCapture() }
                                group.addTask { await cameraManager.stopRecording() }
                            }
                        }
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
