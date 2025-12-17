//
//  CameraManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 21.10.25.
//

import Foundation
import AVFoundation
import Combine
import os

/// Manages camera setup, recording and saving of videos with frame timestamps
class CameraManager: NSObject, ObservableObject{

    private let captureSession: AVCaptureSession = AVCaptureSession()
    private let sessionQueue = DispatchSerialQueue(label: "video.preview.session")
    let movieOutput = AVCaptureMovieFileOutput()
    @Published var isRunning = false
    
    // Frame timestamp recording
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var frameTimestampFileHandle: FileHandle?
    private var isRecordingFrames = false
    private let fileWriteQueue = DispatchQueue(label: "com.app.frames.fileWrite", qos: .utility)
    private var frameCount: Int = 0
    
    override init() {
        super.init()
        
        Task {
            await setUpCaptureSession()
        }
    }
    
    var captureSessionIfReady: AVCaptureSession? {
        guard captureSession.isRunning else { return nil }
        return captureSession
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    func setUpCaptureSession() async -> Void {
        guard await isAuthorized else { return }
        guard !captureSession.isRunning else {
            AppLogger.video.warning("Capture session is already running")
            return
        }
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
        
        // Video Data Output für Frame Timestamps
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDataOutputQueue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        
        if self.captureSession.canAddOutput(videoDataOutput) {
            self.captureSession.addOutput(videoDataOutput)
            self.videoDataOutput = videoDataOutput
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
    
    func startRecording(path: URL) -> Void {
        if movieOutput.isRecording {
            AppLogger.video.warning("Already recording.")
            return
        }
        
        // Prepare frame timestamps file
        let timestampFileName = "frame_timestamps.csv"
        let timestampUrl = path.appendingPathComponent(timestampFileName)
        
        frameCount = 0
        
        let header = "frame_number,timestamp\n"
        try? header.write(to: timestampUrl, atomically: true, encoding: .utf8)
        
        frameTimestampFileHandle = try? FileHandle(forWritingTo: timestampUrl)
        frameTimestampFileHandle?.seekToEndOfFile()
        
        isRecordingFrames = true
        
        // Start video recording
        let fileName = "recording.mov"
        let outputUrl = path.appendingPathComponent(fileName)
        movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
        
        AppLogger.video.info("Started recording.")
    }
    
    func stopRecording() -> Void {
        if !movieOutput.isRecording {
            AppLogger.video.info("Not recording.")
            return
        }
        AppLogger.video.info("Stopping Video recording.")
        // Stop video
        movieOutput.stopRecording()
        
        AppLogger.video.info("Stopped Video recording.")
    }
}

// Video recording delegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        
        // stop recording frames
        isRecordingFrames = false
        
        // Warte auf alle pending writes
        fileWriteQueue.sync {
            try? frameTimestampFileHandle?.close()
            frameTimestampFileHandle = nil
        }
        
        AppLogger.video.debug("Total frames recorded: \(self.frameCount)")
        AppLogger.file.debug("Video saved to \(outputFileURL.path)")
        
        // Used for debugging frame counting by calculating an
        // approximation of how many frames should have at least been recorded.
        let asset = AVURLAsset(url: outputFileURL)
        Task {
            do {
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                let expectedFrames = Int(durationSeconds * 30)
                AppLogger.video.debug("Video duration: \(String(format: "%.2f", durationSeconds)) seconds")
                AppLogger.video.debug("Expected frames @ 30 FPS: \(expectedFrames)")
            } catch {
                AppLogger.file.error("Failed to load video duration: \(error.localizedDescription)")
            }
        }
        
        if let error = error {
            AppLogger.video.error("Recording failed. Error: \(error.localizedDescription)")
        }
    }
}

// Frame capture delegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        guard isRecordingFrames else { return }
        
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let timestamp = CMTimeGetSeconds(presentationTime)
        
        // Counts frames
        fileWriteQueue.async {
            self.frameCount += 1
            let line = "\(self.frameCount),\(timestamp)\n"
            
            if let fh = self.frameTimestampFileHandle, let data = line.data(using: .utf8) {
                fh.write(data)
                
                // Periodic sync for crash safety
                if self.frameCount % 100 == 0 {
                    try? fh.synchronize()
                }
            }
        }
    }
}
