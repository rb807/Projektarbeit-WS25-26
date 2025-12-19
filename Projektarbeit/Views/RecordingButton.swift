//
//  RecordingButton.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 19.12.25.
//

import SwiftUI

struct RecordingButton: View {
    let isRecording: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: handleTap) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        isEnabled ? Color.white : Color.gray,
                        lineWidth: 4
                    )
                    .frame(width: 75, height: 75)
                
                // Inner shape with smooth transition
                InnerShape(isRecording: isRecording)
                    .fill(isEnabled ? Color.red : Color.gray)
            }
            .scaleEffect(scale)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled)
        .frame(width: 75, height: 75)
        .contentShape(Circle())
        .buttonStyle(PlainButtonStyle()) 
    }
    
    private func handleTap() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 0.9
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
        
        action()
    }
}

// MARK: - Inner Shape with smooth morphing animation

struct InnerShape: Shape {
    var isRecording: Bool
    
    var animatableData: CGFloat {
        get { isRecording ? 1 : 0 }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        let progress = isRecording ? 1.0 : 0.0
        
        let cornerRadius = interpolate(from: 30, to: 8, progress: progress)
        let size = interpolate(from: 60, to: 40, progress: progress)
        
        let frame = CGRect(
            x: (rect.width - size) / 2,
            y: (rect.height - size) / 2,
            width: size,
            height: size
        )
        
        return Path(roundedRect: frame, cornerRadius: cornerRadius)
    }
    
    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 50) {
            // Test idle
            RecordingButton(isRecording: false, isEnabled: true) {
                print("Idle tapped")
            }
            
            // Test recording
            RecordingButton(isRecording: true, isEnabled: true) {
                print("Recording tapped")
            }
            
            // Test disabled
            RecordingButton(isRecording: false, isEnabled: false) {
                print("Disabled")
            }
        }
    }
}
