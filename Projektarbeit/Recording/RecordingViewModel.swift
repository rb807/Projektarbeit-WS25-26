//
//  RecordingViewModel.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 16.12.25.
//

import Foundation
import Combine
import os
import AVFoundation

enum RecordingState: Equatable {
    case idle
    case starting
    case recording
    case stopping
    case error(String)
}

class RecordingViewModel: ObservableObject {
    @Published var state: RecordingState = .idle
    
    private let motionManager: MotionManager
    private let cameraManager: CameraManager
    private let locationManager: LocationManager
    let recordingTimer: RecordingTimer
    
    private var currentSessionFolder: URL = URL.documentsDirectory
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Designated initializer with dependency injection
    init(
        motionManager: MotionManager,
        cameraManager: CameraManager,
        locationManager: LocationManager,
        recordingTimer: RecordingTimer
    ) {
        self.motionManager = motionManager
        self.cameraManager = cameraManager
        self.locationManager = locationManager
        self.recordingTimer = recordingTimer
        
        cameraManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    /// Default initializer - creates all managers
    convenience init() {
        self.init(
            motionManager: MotionManager(),
            cameraManager: CameraManager(),
            locationManager: LocationManager(),
            recordingTimer: RecordingTimer()
        )
    }
    
    // MARK: - Public Properties
    
    /// Camera session for preview (read-only access)
    var captureSession: AVCaptureSession? {
        cameraManager.captureSessionIfReady
    }
    
    /// Camera running status
    var isCameraReady: Bool {
        cameraManager.isRunning
    }
    
    // MARK: - Recording Control
    
    @MainActor
    func startRecording() {
        guard state == .idle else {
            AppLogger.recording.warning("Cannot start - not in idle state")
            return
        }
        
        guard isCameraReady else {
            AppLogger.recording.error("Cannot start - camera not ready")
            state = .error("Camera not ready")
            return
        }
        
        AppLogger.recording.info("Starting recording session")
        state = .starting
        
        // Create folder
        currentSessionFolder = createFolder()
        
        // Reset timer
        recordingTimer.reset()
        recordingTimer.start()
        
        // Start all managers
        motionManager.startMotionCapture(path: currentSessionFolder)
        cameraManager.startRecording(path: currentSessionFolder)
        locationManager.startUpdates(path: currentSessionFolder)
        
        state = .recording
        AppLogger.recording.info("Recording started")
    }
    
    @MainActor
    func stopRecording() {
        guard state == .recording else {
            AppLogger.recording.warning("Cannot stop - not recording")
            return
        }
        
        AppLogger.recording.info("Stopping recording session")
        state = .stopping
        
        // Stop timer
        recordingTimer.stop()
        
        // Stop all managers
        motionManager.stopMotionCapture()
        cameraManager.stopRecording()
        locationManager.stopUpdates()
        
        state = .idle
        AppLogger.recording.info("Recording stopped")
    }
    
    // MARK: - Helper Functions
    
    /// Creates a folder for a recording in the documents directory
    private func createFolder() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let directory = formatter.string(from: Date())
        let path = URL.documentsDirectory.appending(component: directory)
        
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            AppLogger.file.info("Created recording folder: \(directory)")
            return path
        } catch {
            AppLogger.file.error("Could not create directory: \(error)")
            state = .error("Failed to create recording folder")
            return URL.documentsDirectory
        }
    }
}
