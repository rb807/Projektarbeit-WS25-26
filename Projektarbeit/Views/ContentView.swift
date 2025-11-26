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
            }
            .tabItem {
                Label("Datenerfassung", systemImage: "dot.circle.and.cursorarrow")
                }
            NavigationStack {
                FileView()
            }
            .tabItem {
                Label("Aufnahmen", systemImage: "folder")
            }
        }
    }
}

#Preview {
    ContentView()
}
