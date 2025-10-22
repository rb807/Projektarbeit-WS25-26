//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var motionManager = MotionManager()
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("IMU-Datenerfassung")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
            }
            
            VStack {
                CameraView(image: $viewModel.currentFrame)
            }
            
            VStack {
                GroupBox {
                    Text("Number of samples: \(motionManager.motionData.count)")
                }
                
                HStack {
                    Button("Start") {
                        motionManager.startMotionCapture()
                        viewModel.cameraManager.startRecording()
                    }
                        .buttonStyle(.borderedProminent)
                    Button("Stop") {
                        motionManager.stopMotionCapture()
                        viewModel.cameraManager.stopRecording()
                    }
                        .buttonStyle(.bordered)
                    Button("export") {
                        motionManager.exportToCsv()
                        viewModel.cameraManager.saveRecording()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}

struct valueView: View {
    var body: some View {
        
    }
}

#Preview {
    ContentView()
}
