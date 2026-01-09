//
//  RecorderView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 25.11.25.
//

import SwiftUI
import os

struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @State private var showFilesView = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Camera Preview
            if let session = viewModel.captureSession {
                CameraPreview(session: session)
                    .ignoresSafeArea(.all)
            } else {
                Color.black
                    .ignoresSafeArea(.all)
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Kamera wird initialisiert…")
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
            }
            
            // UI Overlay
            VStack(spacing: 0) {
                // Top: Timer
                if viewModel.state == .recording {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        TimerView(timer: viewModel.recordingTimer)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.top, 60)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer(minLength: 0)
                
                BottomControls
            }
            .frame(maxHeight: .infinity)
        }
        .statusBarHidden(true)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showFilesView) {
            FilesView()
                .navigationBarBackButtonHidden(false)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(viewModel: viewModel)
                .presentationDetents([.height(300)])  // Compact sheet
        }
        .onDisappear {
            if viewModel.state == .recording {
                viewModel.stopRecording()
            }
        }
    }
    
    // MARK: - Bottom Controls
    
    private var BottomControls: some View {
        HStack(spacing: 0) {
            // Files button (left)
            Button(action: {
                showFilesView = true
            }) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
            .disabled(viewModel.state == .recording)
            .opacity(viewModel.state == .recording ? 0.3 : 1.0)
            .frame(width: 70, height: 70)
            .contentShape(Rectangle())
            
            Spacer()
            
            // Recording button (center)
            RecordingButton(
                isRecording: viewModel.state == .recording,
                isEnabled: isButtonEnabled,
                action: toggleRecording
            )
            .frame(width: 100, height: 100)
            .contentShape(Rectangle())
            
            Spacer()
            
            // Settings button (right) - Opens Sheet
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
            .disabled(viewModel.state == .recording)
            .opacity(viewModel.state == .recording ? 0.3 : 1.0)
            .frame(width: 70, height: 70)
            .contentShape(Rectangle())
        }
        .frame(height: 120)
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
        .background(Color.clear)
    }
    
    // MARK: - Logic
    
    private func toggleRecording() {
        withAnimation {
            if viewModel.state == .idle {
                viewModel.startRecording()
            } else if viewModel.state == .recording {
                viewModel.stopRecording()
            }
        }
    }
    
    private var isButtonEnabled: Bool {
        switch viewModel.state {
        case .idle:
            return viewModel.isCameraReady
        case .recording:
            return true
        case .starting, .stopping, .error:
            return false
        }
    }
}

// MARK: - Settings Sheet (Compact)

struct SettingsSheet: View {
    @ObservedObject var viewModel: RecordingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $viewModel.recordCamera) {
                        Label("Camera", systemImage: "camera.fill")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $viewModel.recordImu) {
                        Label("IMU", systemImage: "gyroscope")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $viewModel.recordLocation) {
                        Label("Location", systemImage: "location.fill")
                    }
                    .tint(.blue)
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecordingView()
    }
}
