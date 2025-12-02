//
//  FilesViewModel.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 02.12.25.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

class FilesViewModel: ObservableObject {
    @Published var files: [URL] = []
    @Published var documentsToExport: DirectoryDocument?
    
    private let fm = FileManager.default
    private let documentsURL: URL
    
    init() {
        // Get the URL for the Documents directory
        documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadFiles()
    }
    
    /// Loads all files in the documents directory
    func loadFiles() {
        do {
            let content = try fm.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            files = content
        } catch {
            print("Error loading files: \(error)")
        }
    }
    
    func createFile(newFileName: String) {
        
    }
    
    /// Deletes all files at the given urls
    func deleteFiles(urls: Set<URL>) {
        do {
            for url in urls {
                try fm.removeItem(at: url)
                print("File at \(url) deleted successfully")
            }
            loadFiles() // Refresh the list
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    func exportFile(urls: Set<URL>) {
        
    }
}


struct DirectoryDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.directory] }
    static var writableContentTypes: [UTType] { [.directory] }

    init(url: URL) throws {
        //wrapper = try FileWrapper(url: url, options: .immediate)
    }

    init(configuration: ReadConfiguration) throws {
        //wrapper = FileWrapper(directoryWithFileWrappers: [:])
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        //return wrapper
    }
}
