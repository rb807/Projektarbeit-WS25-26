//
//  File.swift
//  cameraTesting
//
//  Created by Ryan Babcock on 21.10.25.
//

import Foundation
import AVFoundation
import Combine

/// Manages camera setup, recording and saving of videos 
class CameraManager: NSObject, ObservableObject{

    private let captureSession: AVCaptureSession = AVCaptureSession()
    private let sessionQueue = DispatchSerialQueue(label: "video.preview.session")
    let movieOutput = AVCaptureMovieFileOutput()
    @Published var isRunning = false
    
    var captureSessionIfReady: AVCaptureSession? {
        guard captureSession.isRunning else { return nil }
        return captureSession
    }
    
    // determines if user has given acces to the camera
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    /// Sets up capture session configuration and starts it
    func setUpCaptureSession() async -> Void {
        guard await isAuthorized else { return }
        sessionQueue.async {
            self.configureCaptureSession()
            self.startCaptureSession()
        }
    }
    
    /// Configures output and input of the capture session
    private func configureCaptureSession() -> Void {
        self.captureSession.beginConfiguration()
        
        // Video
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           self.captureSession.canAddInput(videoInput) {
            self.captureSession.addInput(videoInput)
        }
        
        // Audio
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           self.captureSession.canAddInput(audioInput) {
            self.captureSession.addInput(audioInput)
        }
        
        // Movie output
        if self.captureSession.canAddOutput(self.movieOutput) {
            self.captureSession.addOutput(self.movieOutput)
        }
        
        self.captureSession.sessionPreset = .high
        self.captureSession.commitConfiguration()

    }
    
    /// Starts stream from input to output
    private func startCaptureSession() -> Void {
        self.captureSession.startRunning()
     
        DispatchSerialQueue.main.async {
            self.isRunning = true
        }
    }
    
    /// Starts video recording if recording is not active
    func startRecording(path: URL) -> Void {
        if movieOutput.isRecording {
            NSLog("Recording is already running.")
            return
        }
        
        let fileName = "recording.mov"
        let outputUrl = path.appendingPathComponent(fileName)
        movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
        NSLog("Started recording")
    }
    
    /// Stops video recording if recording is active
    func stopRecording() -> Void {
        if !movieOutput.isRecording {
            NSLog("Recording is not running.")
            return
        }
        movieOutput.stopRecording()
        NSLog("Stopped recording")
    }
}

// Defines where the stream of data from the capture session is stored
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        NSLog("Video saved to \(outputFileURL.path)")
    }
}
