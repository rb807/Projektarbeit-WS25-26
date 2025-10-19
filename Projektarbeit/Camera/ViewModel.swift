//
//  ViewModel.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 18.10.25.
//

import Foundation

import CoreImage
import Observation

@Observable
class ViewModel {
    var currentFrame: CGImage?
    let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
