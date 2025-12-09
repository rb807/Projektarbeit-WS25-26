//
//  TimerView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 28.11.25.
//

import SwiftUI

struct TimerView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isRunning = false

    var body: some View {
        VStack {
            Text(timeString(from: elapsedTime))
                .font(.largeTitle)
                .padding()

            HStack {
                Button(isRunning ? "Stop" : "Start") {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
                .padding()

                Button("Reset") {
                    resetTimer()
                }
                .padding()
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
        }
        isRunning = true
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }

    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let hundredths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

#Preview {
    TimerView()
}
