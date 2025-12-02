//
//  FileListView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 02.12.25.
//

import SwiftUI

struct FilesListView: View {
    @ObservedObject var filesViewModel = FilesViewModel()
    @State private var multiSelection = Set<URL>()
    
    var body: some View {
        VStack {
            Spacer()
            
            if filesViewModel.files.isEmpty {
                Text("Keine Aufnahmen")
            } else {
                List (selection: $multiSelection){
                    ForEach(filesViewModel.files, id:\.self) { file in
                        // Just show directories not individual files
                        if file.hasDirectoryPath {
                            Text("\(file.lastPathComponent)")
                        }
                    }
                }
                .refreshable { filesViewModel.loadFiles() }
                .listStyle(.plain)
            }
            
            Spacer()
            
            Text("\(multiSelection.count) Selections")
                .padding()
        }
        .toolbar {
            ToolbarItemGroup (placement: .topBarTrailing) {
                EditButton()
                    .disabled(filesViewModel.files.isEmpty)
                Button (action: {
                    if !multiSelection.isEmpty {
                        // If files have been selected delete them
                        filesViewModel.deleteFiles(urls: multiSelection)
                    }
                }, label: {Image(systemName: "trash")})
                .padding()
                .disabled(multiSelection.isEmpty || filesViewModel.files.isEmpty)
            }
        }
        .onAppear() { filesViewModel.loadFiles() }
    }
}

#Preview {
    FilesListView()
}
