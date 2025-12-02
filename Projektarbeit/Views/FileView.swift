//
//  FileView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 24.11.25.
//
/*
import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct FileView: View {

    @State private var directories: [URL] = []
    @State private var multiSelection = Set<URL>()
    @State private var showingExporter = false
    @State private var documentToExport: DirectoryDocument?

    var body: some View {
        VStack {
            Spacer()
            
            if directories.isEmpty {
                Text("Keine Aufnahmen")
            } else {
                List (selection: $multiSelection){
                    ForEach(directories, id:\.self) { directory in
                        Text(directory.lastPathComponent)
                    }
                }
                .refreshable { loadDirectories() }
                .toolbar {
                    ToolbarItemGroup (placement: .topBarTrailing) {
                        
                        EditButton()
                        
                        Button (action: {
                            if let url = multiSelection.first {
                                documentToExport = try? DirectoryDocument(url: url)
                                showingExporter = true
                            }
                        }, label: {Image(systemName: "square.and.arrow.up")})
                            .padding()
                            .disabled(multiSelection.isEmpty)
                        
                    }
                }
                .listStyle(.plain)
            }
            
            Spacer()
            
            Text("\(multiSelection.count) selections")
                .padding()
        }
        .onAppear() { loadDirectories() }
        .fileExporter(
            isPresented: $showingExporter,
            document: documentToExport,
            contentType: .directory,
            defaultFilename: multiSelection.first?.lastPathComponent
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    /// finds all folders in the documents directory and gets their names
    private func loadDirectories() {
        let fm = FileManager.default
        let url = URL.documentsDirectory

        do {
            let content = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            directories = content
                .filter{ $0.hasDirectoryPath }

        } catch {
            print("Error loading directories: \(error)")
        }
    }
}

struct DirectoryDocument: FileDocument, @unchecked Sendable {
    static var readableContentTypes: [UTType] { [.directory] }
    static var writableContentTypes: [UTType] { [.directory] }

    var wrapper: FileWrapper

    init(url: URL) throws {
        wrapper = try FileWrapper(url: url, options: .immediate)
    }

    init(configuration: ReadConfiguration) throws {
        wrapper = FileWrapper(directoryWithFileWrappers: [:])
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return wrapper
    }
}


#Preview {
    FileView()
}
*/
