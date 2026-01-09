//
//  CameraManager.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 21.10.25.
//

import Foundation
import AVFoundation
import ARKit
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
    
    // Store video device for intrinsics
    private var videoDevice: AVCaptureDevice?
    private var hasExportedIntrinsics = false
    
    override init() {
        super.init()
        
        Task {
            await setUpCaptureSession()
        }
    }
    
    var captureSessionIfReady: AVCaptureSession? {
        guard isRunning else {
            AppLogger.camera.debug("Capture session not ready")
            return nil
        }
        AppLogger.camera.debug("Capture session ready")
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
            AppLogger.camera.warning("Capture session is already running")
            return
        }
        sessionQueue.async {
            self.configureCaptureSession()
            self.startCaptureSession()
        }
    }
    
    private func configureCaptureSession() -> Void {
        AppLogger.camera.debug("Configuring capture session")
        self.captureSession.beginConfiguration()
        
        // Video
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           self.captureSession.canAddInput(videoInput) {
            self.captureSession.addInput(videoInput)
            // Store the video device for intrinsics
            self.videoDevice = videoDevice
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
        AppLogger.camera.debug("Capture session configured.")
    }
    
    private func startCaptureSession() -> Void {
        AppLogger.camera.info("Starting capture session")
        self.captureSession.startRunning()
        AppLogger.camera.info("Capture session started")
        
        DispatchSerialQueue.main.async {
            self.isRunning = true
            AppLogger.camera.info("isRunning set to true")
        }
    }
    
    func startRecording(path: URL) -> Void {
        if movieOutput.isRecording {
            AppLogger.camera.warning("Already recording.")
            return
        }
        
        // Export intrinsics at the start of recording
        hasExportedIntrinsics = false
        
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
        
        AppLogger.camera.info("Started recording.")
    }
    
    func stopRecording() -> Void {
        if !movieOutput.isRecording {
            AppLogger.camera.info("Not recording.")
            return
        }
        
        AppLogger.camera.info("Stopping Video recording.")
        
        // Stop video
        movieOutput.stopRecording()
        
        AppLogger.camera.info("Stopped Video recording.")
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
        
        AppLogger.camera.debug("Total frames recorded: \(self.frameCount)")
        AppLogger.file.debug("Video saved to \(outputFileURL.path)")
        
        // Used for debugging frame counting by calculating an
        // approximation of how many frames should have at least been recorded.
        let asset = AVURLAsset(url: outputFileURL)
        Task {
            do {
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                let expectedFrames = Int(durationSeconds * 30)
                AppLogger.camera.debug("Video duration: \(String(format: "%.2f", durationSeconds)) seconds")
                AppLogger.camera.debug("Expected frames @ 30 FPS: \(expectedFrames)")
            } catch {
                AppLogger.file.error("Failed to load video duration: \(error.localizedDescription)")
            }
        }
        
        if let error = error {
            AppLogger.camera.error("Recording failed. Error: \(error.localizedDescription)")
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
        
        // Export intrinsics on first frame
        if !hasExportedIntrinsics, let device = videoDevice {
            if let outputFileURL = movieOutput.outputFileURL {
                let folder = outputFileURL.deletingLastPathComponent()
                
                // Dispatch to background to avoid any delay
                DispatchQueue.global(qos: .utility).async {
                    self.exportCameraIntrinsics(from: device, to: folder)
                }
                
                hasExportedIntrinsics = true
            }
        }
        
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

// Camera Intrinsics Extension
extension CameraManager {
    
    /// Exports camera intrinsics from AVCaptureDevice
    func exportCameraIntrinsics(from device: AVCaptureDevice, to folder: URL) {
        // Get the active format
        let format = device.activeFormat
        
        // Get intrinsic matrix from format description
        let formatDescription = format.formatDescription
        
        // Get dimensions
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let width = Int(dimensions.width)
        let height = Int(dimensions.height)
        
        // For iOS devices, we need to estimate intrinsics based on field of view
        // This is an approximation since AVCaptureDevice doesn't expose intrinsics directly
        let fovRadians = device.activeFormat.videoFieldOfView * .pi / 180.0
        let focalLengthPixels = Float(width) / (2.0 * tan(fovRadians / 2.0))
        
        let fx = focalLengthPixels
        let fy = focalLengthPixels
        let cx = Float(width) / 2.0
        let cy = Float(height) / 2.0
        
        AppLogger.camera.debug("Camera Intrinsics from AVCaptureDevice:")
        AppLogger.camera.debug("  fx: \(fx), fy: \(fy)")
        AppLogger.camera.debug("  cx: \(cx), cy: \(cy)")
        AppLogger.camera.debug("  Resolution: \(width)x\(height)")
        AppLogger.camera.debug("  FOV: \(device.activeFormat.videoFieldOfView)°")
        
        // Create Kalibr YAML
        let yaml = """
        cam0:
          camera_model: pinhole
          intrinsics: [\(fx), \(fy), \(cx), \(cy)]
          distortion_model: radtan
          distortion_coeffs: [0.0, 0.0, 0.0, 0.0]
          resolution: [\(width), \(height)]
          rostopic: /cam0/image_raw
          timeshift_cam_imu: 0.0
        
        # Camera intrinsics from AVCaptureDevice
        # Note: These are estimated from field of view
        # For more accurate intrinsics, consider using ARKit calibration
        # Device: \(UIDevice.current.model)
        # iOS: \(UIDevice.current.systemVersion)
        # FOV: \(device.activeFormat.videoFieldOfView)°
        # Exported: \(Date())
        """
        
        let yamlURL = folder.appendingPathComponent("camera_intrinsics.yaml")
        
        do {
            try yaml.write(to: yamlURL, atomically: true, encoding: .utf8)
            AppLogger.camera.info("✅ Saved camera intrinsics: \(yamlURL.lastPathComponent)")
        } catch {
            AppLogger.camera.error("Failed to save intrinsics: \(error)")
        }
    }
}
