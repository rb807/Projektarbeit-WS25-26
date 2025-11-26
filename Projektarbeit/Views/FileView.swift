//
//  FileView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 24.11.25.
//

import SwiftUI
import Foundation

import SwiftUI

struct FileView: View {

    @State private var directories: [String] = []

    var body: some View {
        VStack {
            if directories.isEmpty {
                Text("Keine Aufnahmen")
            } else {
                List(directories, id: \.self) { dir in
                    Text(dir)
                }
                .refreshable { loadDirectories() }
            }
        }
        .onAppear() { loadDirectories() }
        .navigationTitle("Aufnahmen")
    }

    private func loadDirectories() {
        let fm = FileManager.default
        let url = URL.documentsDirectory

        do {
            let content = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            directories = content
                .filter{ $0.hasDirectoryPath }
                .map{ $0.lastPathComponent }

        } catch {
            print("Error loading directories: \(error)")
        }
    }
}

#Preview {
    FileView()
}
