//
//  ContentView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 10.10.25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RecordingView()
                    .navigationTitle("Datenerfassung")
            }
            .tabItem { Label("Datenerfassung", systemImage: "record.circle") }
            
            NavigationStack {
                FileView()
                    .navigationTitle("Aufnahmen")
            }
            .tabItem { Label("Aufnahmen", systemImage: "folder") }
        }
    }
}

#Preview {
    ContentView()
}
