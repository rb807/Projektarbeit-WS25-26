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
    @Published var documentToExport: DirectoryDocument?
    @Published var isPreparingExport: Bool = false
    @Published var exportReady: Bool = false
    
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
    
    /// Prepares selected directories for export (works for single or multiple)
    func prepareExport(urls: Set<URL>) async {
        isPreparingExport = true
        
        do {
            let wrapper: FileWrapper
            
            if urls.count == 1, let singleURL = urls.first {
                // Einzelner Ordner - direkt als FileWrapper
                wrapper = try FileWrapper(url: singleURL, options: .immediate)
            } else {
                // Mehrere Ordner - kombiniere sie in einem Parent-Wrapper
                var fileWrappers: [String: FileWrapper] = [:]
                
                for url in urls {
                    let childWrapper = try FileWrapper(url: url, options: .immediate)
                    fileWrappers[url.lastPathComponent] = childWrapper
                }
                
                wrapper = FileWrapper(directoryWithFileWrappers: fileWrappers)
            }
            
            let document = DirectoryDocument(wrapper: wrapper)
            documentToExport = document
            exportReady = true
            
        } catch {
            print("Error preparing export: \(error)")
        }
        
        isPreparingExport = false
    }
}

// Simple FileDocument wrapper that avoids Sendable issues
struct DirectoryDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.folder] }
    
    private let createWrapper: () throws -> FileWrapper
    
    // Initialize with a FileWrapper
    init(wrapper: FileWrapper) {
        self.createWrapper = { wrapper }
    }
    
    // Required for FileDocument protocol
    init(configuration: ReadConfiguration) throws {
        let wrapper = configuration.file
        self.createWrapper = { wrapper }
    }
    
    // This is called when exporting
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try createWrapper()
    }
}
