//
//  File.swift
//  cameraTesting
//
//  Created by Ryan Babcock on 21.10.25.
//

import Foundation
import AVFoundation
import Combine

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
    
    func setUpCaptureSession() async -> Void {
        guard await isAuthorized else { return }
        sessionQueue.async {
            self.configureCaptureSession()
            self.startCaptureSession()
        }
    }
    
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
    
    
    private func startCaptureSession() -> Void {
        self.captureSession.startRunning()
     
        DispatchSerialQueue.main.async {
            self.isRunning = true
        }
    }
    
    
    func startRecording() -> Void {
        let fileName = generateFilename()
        let outputUrl = URL.documentsDirectory.appendingPathComponent(fileName)
        movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
        NSLog("Started recording")
    }

    func stopRecording() -> Void {
        if !movieOutput.isRecording {
            NSLog("Recording is not running.")
            return
        }
        movieOutput.stopRecording()
        NSLog("Stopped recording")
    }
    
    /// Generates a filename based on the current date and time when the collection started.
    func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "movie_\(timestamp).mov"
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
