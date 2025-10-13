//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
            }
            
            VStack {
                GroupBox {
                    Text("Samples: \(motionManager.motionData.count)")
                }
                
                HStack {
                    Button("Start") {
                        motionManager.startMotionCapture()
                    }
                        .buttonStyle(.borderedProminent)
                    Button("Stop") {
                        motionManager.stopMotionCapture()
                    }
                        .buttonStyle(.bordered)
                    Button("export") {
                        motionManager.exportToCsv()
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
