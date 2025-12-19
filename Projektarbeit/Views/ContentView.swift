//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            RecordingView()
                .navigationBarHidden(true)  // Hide navigation bar for fullscreen camera
        }
    }
}

#Preview {
    ContentView()
}
