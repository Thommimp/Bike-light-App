//
//  ContentView.swift
//  IoT
//
//  Created by Thomas Pedersen on 26/03/2025.
//
import SwiftUI
import MapKit
import CoreLocation


struct ContentView: View {
    // Bike's fixed location
    let batteri_procentage = 50 // Example battery percentage
    @State private var cityName: String = "Loading..." // Store the city name

    
    // State to keep track of the selected mode
    //@State private var selectedMode: String? = nil
    
    //@State private var batteryLevel: Int = 50 // Use @State for mutable property
    
    @State private var deviceId: String = ""
    @State private var batteryLevel: Int = 0
    @State private var mode: String = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var timestamp: Date?
    @State private var errorMessage: String?
    
    @State private var bikeCoordinates = CLLocationCoordinate2D(latitude: 55.6763, longitude: 12.5681) // Rådhuspladsen, Copenhagen



    @Binding var savedBikes: [String]
    
    @Binding var selectedBike: String
    

    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) { // Added spacing between elements
                    // Current Mode Display
                    Text(selectedBike)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.black)
                    
                    // Battery Percentage View
                    Batteri(batteryPercentage: batteryLevel)
                    
                    
                    // Button to navigate to the map
                    Text("Current location: \(cityName)")
                        .font(.title2)
                        .fontWeight(.bold)
                    NavigationLink(destination: MapView(bikeCoordinates: bikeCoordinates, timestamp: timestamp)) {
                        Text("Go to Map")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Park Mode Button
                    Button(action: {
                        AzureAPI.updateDeviceMode(deviceId: deviceId, mode: "park") { response in
                            guard let response = response else {
                                print("Failed to update mode: No response")
                                return
                            }
                            
                            if response.success {
                                print("Mode updated successfully: \(response.message)") // No need for ?? since message is non-optional
                                mode = "park"  // Update the mode to "storage"
                            } else {
                                print("Failed to update mode: \(response.message)") // No need for ?? here either
                            }
                        }
                        
                        
                        
                    }) {
                        Text("Park Mode")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mode == "park" ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Sleep Mode Button
                    Button(action: {
                        AzureAPI.updateDeviceMode(deviceId: deviceId, mode: "storage") { response in
                            guard let response = response else {
                                print("Failed to update mode: No response")
                                return
                            }
                            
                            if response.success {
                                print("Mode updated successfully: \(response.message)") // No need for ?? since message is non-optional
                                mode = "storage"  // Update the mode to "storage"
                            } else {
                                print("Failed to update mode: \(response.message)") // No need for ?? here either
                            }
                        }
                        
                    }) {
                        Text("Sleep Mode")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mode == "storage" ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Active Mode Button
                    Button(action: {
                        AzureAPI.updateDeviceMode(deviceId: deviceId, mode: "active") { response in
                            guard let response = response else {
                                print("Failed to update mode: No response")
                                return
                            }
                            
                            if response.success {
                                print("Mode updated successfully: \(response.message)") // No need for ?? since message is non-optional
                                mode = "active"  // Update the mode to "storage"
                            } else {
                                print("Failed to update mode: \(response.message)") // No need for ?? here either
                            }
                        }
                        
                    }) {
                        Text("Active Mode")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mode == "active" ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                //.padding() // Add padding to the entire VStack
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading:
                                        NavigationLink(destination: FrontPage(savedBikes: $savedBikes, selectedBike: $selectedBike)) {
                    Text("Bikes")
                }
                )
               
                
            }
            .refreshable {
                fetchBikeData()
                getCityName(from: bikeCoordinates)
            }
            .onAppear {
                fetchBikeData() // Fetch bike data when the view appears
                //bikeCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                getCityName(from: bikeCoordinates)
                
                
                
            }
            }
        }
    
    // Function to get city name from coordinates
private func getCityName(from coordinates: CLLocationCoordinate2D) {
           let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
           let geocoder = CLGeocoder()
           
           geocoder.reverseGeocodeLocation(location) { placemarks, error in
               if let placemark = placemarks?.first, let city = placemark.locality {
                   cityName = city
               } else {
                   cityName = "Unknown Location"
               }
           }
       }
    
    // Function to fetch bike data and update all necessary variables
    private func fetchBikeData() {
        guard !selectedBike.isEmpty else { return }

        AzureAPI.getDeviceData(deviceId: selectedBike) { deviceData in
            if let deviceData = deviceData {
                print("Raw timestamp string: \(deviceData.timestamp)")

                // Update all variables with the fetched data
                deviceId = deviceData.device_id
                batteryLevel = deviceData.battery_level
                mode = deviceData.mode
                latitude = deviceData.latitude
                longitude = deviceData.longitude
                
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                       if let date = isoFormatter.date(from: deviceData.timestamp) {
                           print("Parsed Date object: \(date)")

                           timestamp = date  // Store the Date
                       } else {
                           print("Failed to parse timestamp.")
                       }
                // In fetchBikeData() after updating latitude and longitude
                bikeCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            } else {
                errorMessage = "Failed to fetch data for \(selectedBike)"
            }
        }
    }
    


    

}



