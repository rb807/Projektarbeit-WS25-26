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
    @StateObject private var recordingTimer = RecordingTimer()
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

            VStack(spacing: 20) {
                // Timer Display
                TimerView(timer: recordingTimer)
                    .padding()
                
                // Sample counts
                /*
                HStack(spacing: 20) {
                    VStack {
                        Text("IMU")
                            .font(.caption)
                        Text("\(motionManager.samples)")
                            .font(.headline)
                    }
                    
                    VStack {
                        Text("GPS")
                            .font(.caption)
                        Text("\(locationManager.samples)")
                            .font(.headline)
                    }
                }
                .foregroundColor(.secondary)
                */
                HStack {
                    Button("Start", systemImage: "play.circle") {
                        currentSessionFolder = createFolder()
                        // Reset Timer
                        recordingTimer.reset()
                        // Start Timer
                        recordingTimer.start()
                        
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
                    .disabled(!cameraManager.isRunning || recordingTimer.isRunning)
                    
                    Button("Stop", systemImage: "stop.circle") {
                        // Stop Timer
                        recordingTimer.stop()
                        
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
                    .disabled(!recordingTimer.isRunning)
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
