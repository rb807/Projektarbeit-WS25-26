//
//  AppLogger.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 16.12.25.
//

import OSLog

struct AppLogger {
    
    // Logger for recording
    static let video = Logger(
        subsystem: "com.projektarbeit.video",
        category: "Video")
    
    // Logger for IMU data collection
    static let imu = Logger(
        subsystem: "com.projektarbeit.imu",
        category: "IMU")
    
    // Logger for location data collection
    static let location = Logger(
        subsystem: "com.projektarbeit.location",
        category: "Location")
    
    // Logger for file operations
    static let file = Logger(
        subsystem: "com.projektarbeit.file",
        category: "file")
    
}
