//
//  FileListView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 02.12.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilesListView: View {
    @ObservedObject var filesViewModel = FilesViewModel()
    @State private var multiSelection = Set<URL>()
    @State private var showExporter = false
    
    var body: some View {
        ZStack {
            mainContent
            
            if filesViewModel.isPreparingExport {
                loadingOverlay
            }
        }
        .fileExporter(
            isPresented: $showExporter,
            document: filesViewModel.documentToExport,
            contentType: .folder,
            defaultFilename: defaultFilename()
        ) { result in
            handleExportResult(result)
        }
        .onChange(of: filesViewModel.exportReady) { oldValue, newValue in
            if newValue == true {
                showExporter = true
            }
        }
        .onAppear() {
            filesViewModel.loadFiles()
        }
    }
    
    // MARK: - Sub-Views
    
    private var mainContent: some View {
        VStack {
            Spacer()
            
            if filesViewModel.files.isEmpty {
                Text("Keine Aufnahmen")
            } else {
                filesList
            }
            
            Spacer()
            
            Text("\(multiSelection.count) Selections")
                .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                toolbarButtons
            }
        }
    }
    
    private var filesList: some View {
        List(selection: $multiSelection) {
            ForEach(filesViewModel.files, id: \.self) { file in
                if file.hasDirectoryPath {
                    Text(file.lastPathComponent)
                }
            }
        }
        .refreshable {
            filesViewModel.loadFiles()
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private var toolbarButtons: some View {
        EditButton()
            .disabled(filesViewModel.files.isEmpty)
        Button(action: {
            Task {
                await filesViewModel.prepareExport(urls: multiSelection)
            }
        }, label: {
            Image(systemName: "square.and.arrow.up")
        })
        .disabled(multiSelection.isEmpty || filesViewModel.files.isEmpty || filesViewModel.isPreparingExport)
        
        Button(action: {
            if !multiSelection.isEmpty {
                filesViewModel.deleteFiles(urls: multiSelection)
            }
        }, label: {
            Image(systemName: "trash")
        })
        .padding()
        .disabled(multiSelection.isEmpty || filesViewModel.files.isEmpty)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Export wird vorbereitet...")
                    .font(.headline)
            }
            .padding(32)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
    
    // MARK: - Helper Functions
    
    private func defaultFilename() -> String {
        if multiSelection.count == 1, let url = multiSelection.first {
            return url.lastPathComponent
        } else {
            return "Aufnahmen_Export"
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Erfolgreich exportiert nach: \(url)")
        case .failure(let error):
            print("Export fehlgeschlagen: \(error.localizedDescription)")
        }
        filesViewModel.documentToExport = nil
        filesViewModel.exportReady = false
    }
}

#Preview {
    FilesListView()
}
