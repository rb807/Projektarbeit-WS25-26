//
//  RecordingViewModel.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 16.12.25.
//

import Foundation
import Combine
import SwiftUI
import os


enum RecordingState: Equatable {
    case idle
    case starting
    case recording
    case stopping
    case error(String)
}

class RecordingViewModel: ObservableObject {
    @Published var state: RecordingState = .idle
    
    let motionManager: MotionManager
    let cameraManager: CameraManager
    let locationManager: LocationManager
    let recordingTimer: RecordingTimer
    
    private var currentSessionFolder: URL = URL.documentsDirectory
    
    init(motionManager: MotionManager,
         cameraManager: CameraManager,
         locationManager: LocationManager,
         recordingTimer: RecordingTimer) {
        self.motionManager = motionManager
        self.cameraManager = cameraManager
        self.locationManager = locationManager
        self.recordingTimer = recordingTimer
    }
    
    func startRecording() {
        guard state == .idle else { return }
        state = .starting
        
        currentSessionFolder = createFolder()
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.motionManager.startMotionCapture(path: self.currentSessionFolder) }
                group.addTask { await self.cameraManager.startRecording(path: self.currentSessionFolder) }
                group.addTask { await self.locationManager.startUpdates(path: self.currentSessionFolder) }
            }
            
            await MainActor.run {
                self.recordingTimer.start()
                self.state = .recording
            }
        }
    }
    
    func stopRecording() -> Void {
        guard state == .recording else { return }
        state = .stopping
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.motionManager.stopMotionCapture() }
                group.addTask { await self.cameraManager.stopRecording() }
                group.addTask { await self.locationManager.stopUpdates() }
            }
            
            await MainActor.run {
                self.recordingTimer.stop()
                self.state = .idle
            }
        }
    }
    
    // MARK: -Helper Functions

    /// creates a folder for a recording in the documents directory
    private func createFolder() -> URL {
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
}
