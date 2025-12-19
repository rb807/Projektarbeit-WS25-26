//
//  TimerView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 28.11.25.
//

import SwiftUI
import Combine

// MARK: - RecordingTimer
class RecordingTimer: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    
    private var timer: Timer?
    
    func start() {
        guard !isRunning else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.01
        }
        isRunning = true
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }
    
    func timeString() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - TimerView (Display Only)
struct TimerView: View {
    @ObservedObject var timer: RecordingTimer
    
    var body: some View {
        Text(timer.timeString())
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(timer.isRunning ? .red : .primary)
    }
}

// MARK: - Preview with Test Controls
#Preview {
    struct TimerPreview: View {
        @StateObject private var timer = RecordingTimer()
        
        var body: some View {
            VStack(spacing: 20) {
                TimerView(timer: timer)
                
                HStack {
                    Button(timer.isRunning ? "Stop" : "Start") {
                        if timer.isRunning {
                            timer.stop()
                        } else {
                            timer.start()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset") {
                        timer.reset()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
    
    return TimerPreview()
}
