//
//  MapView.swift
//  IoT
//
//  Created by Thomas Pedersen on 26/03/2025.
//

import SwiftUI
import MapKit


struct MapView: View {
    let bikeCoordinates: CLLocationCoordinate2D
    
    // Map position centered on the bike's location
    @State private var bike_position: MapCameraPosition
    @State private var timestamp: Date?
    @State private var lastseen: Date?
    
    init(bikeCoordinates: CLLocationCoordinate2D, timestamp: Date?) {
        self.bikeCoordinates = bikeCoordinates
        self.timestamp = timestamp
        _bike_position = State(initialValue: .region(
            MKCoordinateRegion(
                center: bikeCoordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ))
    }
    
    var body: some View {
        Map(position: $bike_position) {
            // Marker for bike's location
            
            Marker(coordinate: bikeCoordinates) {
                Label(timeSinceLastSeen(timestamp: timestamp ?? Date()), systemImage: "star")
            }
        }
            
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: openGoogleMaps) {
                    Image("maps")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30) // Adjust icon size
                }
            }
        }
    }
    
    func openGoogleMaps() {
        let urlString = "comgooglemaps://?q=\(bikeCoordinates.latitude),\(bikeCoordinates.longitude)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // If Google Maps app is not installed, open in Safari
            let webURLString = "https://www.google.com/maps?q=\(bikeCoordinates.latitude),\(bikeCoordinates.longitude)"
            if let webURL = URL(string: webURLString) {
                UIApplication.shared.open(webURL)
            }
        }
    }
    
    // Function to calculate the time since the bike was last seen
    func timeSinceLastSeen(timestamp: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(timestamp)
        
        let minutes = Int(timeInterval) / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days) days ago"
        } else if hours > 0 {
            return "\(hours) hours ago"
        } else if minutes > 0 {
            return "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}

// PreviewProvider to display the MapView in the SwiftUI canvas
