//
//  RecorderView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 25.11.25.
//

import SwiftUI

struct RecordingView: View {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var locationManager = LocationManager()
    @State var currentSessionFolder: URL = URL.documentsDirectory

    var body: some View {
        VStack {
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
                
                SampleView(motionManager: motionManager, locationManager: locationManager)
                
                HStack {
                    Button("Start", systemImage: "play.circle") {
                        currentSessionFolder = createFolder()
                        
                        Task {
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask { await motionManager.startMotionCapture(path: currentSessionFolder) }
                                group.addTask { await cameraManager.startRecording(path: currentSessionFolder) }
                                group.addTask { await locationManager.startUpdates(path: currentSessionFolder) }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(!cameraManager.isRunning)
                    
                    Button("Stop", systemImage: "stop.circle") {
                        Task {
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask { await motionManager.stopMotionCapture() }
                                group.addTask { await cameraManager.stopRecording() }
                                group.addTask { await locationManager.stopUpdates() }
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

/// creates a folder for a recording in the documents directory
func createFolder() -> URL {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let directory = formatter.string(from: Date())
    let path = URL.documentsDirectory.appending(component: directory)
    let manager = FileManager.default
    do {
        try manager.createDirectory(at: path, withIntermediateDirectories: true)
    } catch {
        NSLog("Could not create directory: \(error)")
        return URL.documentsDirectory
    }
    return path
}

#Preview {
    RecordingView()
}
