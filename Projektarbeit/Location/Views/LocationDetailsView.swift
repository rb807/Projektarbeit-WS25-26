//
//  LocationDetailsView.swift
//  Projektarbeit
//
//  Created by Ryan Babcock on 13.11.25.
//

import SwiftUI
import CoreLocation

struct LocationDetailsView: View {
    let location: CLLocation
 
    var body: some View {
        List {
            Section(header: Text("Location Information")) {
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
                Text("Altitude: \(location.altitude) meters")
                Text("Ellipsoidal Altitude: \(location.ellipsoidalAltitude) meters")
                Text("Horizontal Accuracy: \(location.horizontalAccuracy) meters")
                Text("Vertical Accuracy: \(location.verticalAccuracy) meters")
                Text("Heading: \(location.course)°")
                if let floor = location.floor {
                    Text("Floor: \(floor.level)")
                }
                Text("Date: \(location.timestamp)")
            }
        }
    }
}

// Dummy CLLocation für Preview
let testData = CLLocation(
    coordinate: CLLocationCoordinate2D(latitude: 48.137154, longitude: 11.576124),
    altitude: 520,
    horizontalAccuracy: 5,
    verticalAccuracy: 5,
    course: 90,
    speed: 1,
    timestamp: Date()
)

#Preview {
    LocationDetailsView(location: testData)
}
