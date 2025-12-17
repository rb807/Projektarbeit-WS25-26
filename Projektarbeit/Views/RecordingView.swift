//
//  RecorderView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 25.11.25.
//

import SwiftUI
import os


import SwiftUI
import os

struct RecordingView: View {
    // NUR das ViewModel - kein direkter Manager-Zugriff!
    @ObservedObject var viewModel = RecordingViewModel()
    
    var body: some View {
        VStack {
            // Camera Preview
            ZStack {
                // Zugriff auf Camera Session via ViewModel
                if let session = viewModel.captureSession {
                    CameraPreview(session: session)
                } else {
                    ProgressView("Kamera wird initialisiert …")
                }
            }
            .onDisappear {
                // Cleanup wenn View verschwindet
                if viewModel.state == .recording {
                    viewModel.stopRecording()
                }
            }

            VStack(spacing: 20) {
                // Timer Display (via ViewModel)
                TimerView(timer: viewModel.recordingTimer)
                    .padding()
                
                HStack {
                    Button("Start", systemImage: "play.circle") {
                        viewModel.startRecording()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(viewModel.state != .idle || !viewModel.isCameraReady)
                    
                    Button("Stop", systemImage: "stop.circle") {
                        viewModel.stopRecording()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    .disabled(viewModel.state != .recording)
                }
                
                // Optional: Show state
                switch viewModel.state {
                case .starting:
                    ProgressView("Starting...")
                case .stopping:
                    ProgressView("Stopping...")
                case .error(let message):
                    Text(message)
                        .foregroundColor(.red)
                        .padding()
                default:
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    RecordingView()
}

/*
struct RecordingView: View {
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recordingTimer: RecordingTimer
    
    @StateObject private var viewModel = RecordingViewModel()
    
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
            .onDisappear {
                if recordingTimer.isRunning {
                    recordingTimer.stop()
                    motionManager.stopMotionCapture()
                    cameraManager.stopRecording()
                }
            }

            VStack(spacing: 20) {
                // Timer Display
                TimerView(timer: recordingTimer)
                    .padding()
                
                HStack {
                    Button("Start", systemImage: "play.circle") {
                        currentSessionFolder = createFolder()
                        recordingTimer.reset()
                        recordingTimer.start()

                        motionManager.startMotionCapture(path: currentSessionFolder)
                        cameraManager.startRecording(path: currentSessionFolder)
                        // locationManager.startUpdates(path: currentSessionFolder)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(!cameraManager.isRunning || recordingTimer.isRunning)
                    
                    Button("Stop", systemImage: "stop.circle") {
                        recordingTimer.stop()
                        motionManager.stopMotionCapture()
                        cameraManager.stopRecording()
                        // locationManager.stopUpdates()
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

func createFolder() -> URL {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
    let directory = formatter.string(from: Date())
    let path = URL.documentsDirectory.appending(component: directory)
    let manager = FileManager.default
    do {
        try manager.createDirectory(at: path, withIntermediateDirectories: true)
    } catch {
        AppLogger.file.error("Could not create directory: \(error)")
        return URL.documentsDirectory
    }
    return path
}

#Preview {
    RecordingView()
}
*/
