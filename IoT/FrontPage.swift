//
//  FrontPage.swift
//  IoT
//
//  Created by Thomas Pedersen on 13/04/2025.
//
// FrontPage.swift
import SwiftUI

struct FrontPage: View {
    @Binding var savedBikes: [String]
    @State private var navigateToBLEList = false
    @Binding var selectedBike: String
    @State private var navigateToAppView = false

    @State private var newBikeID: String = ""
    @State private var showDeleteAlert = false
    @State private var bikeToDelete: String?

    var body: some View {
        NavigationStack {
            VStack {
                if savedBikes.isEmpty {
                    Spacer()

                    Image(systemName: "bicycle")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)

                    Text("Looks like you don't have any bikes")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text("Connect to your bike to get started")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Spacer()
                } else {
                    List {
                        ForEach(savedBikes, id: \.self) { bike in
                            HStack {
                                Text(bike)
                                Spacer()
                                if bike == selectedBike {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedBike = bike
                                UserDefaults.standard.set(selectedBike, forKey: "selectedBike")
                                navigateToAppView = true
                            }
                            .onLongPressGesture {
                                bikeToDelete = bike
                                showDeleteAlert = true
                            }
                        }
                    }
                }

                // Add Bike Manually
                HStack {
                    TextField("Enter bike ID", text: $newBikeID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        let trimmedID = newBikeID.trimmingCharacters(in: .whitespaces)
                        if !trimmedID.isEmpty && !savedBikes.contains(trimmedID) {
                            // Check if the device exists before adding it
                            AzureAPI.getDeviceData(deviceId: trimmedID) { deviceData in
                                // Use DispatchQueue.main because we're updating UI elements from a background thread
                                DispatchQueue.main.async {
                                    if deviceData != nil {
                                        // Device exists, add it to the list
                                        savedBikes.append(trimmedID)
                                        // Save the updated list to UserDefaults
                                        UserDefaults.standard.set(savedBikes, forKey: "savedBikes")
                                        newBikeID = ""
                                    } else {
                                        // Device doesn't exist, show an error message
                                        // You may want to use an @State variable to show an alert here
                                        print("Device \(trimmedID) does not exist")
                                        // If you have an error message state variable, update it here
                                        // errorMessage = "Device \(trimmedID) does not exist"
                                        // showAlert = true
                                    }
                                }
                            }
                        }
                    }){
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding(.trailing)
                }

                // Button to navigate to BLE list
                Button("Add New Bike") {
                    navigateToBLEList = true
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .navigationDestination(isPresented: $navigateToBLEList) {
                BLEListView(savedBikes: $savedBikes)
            }
            .navigationDestination(isPresented: $navigateToAppView) {
                //ContentView(savedBikes: $savedBikes, selectedBike: $selectedBike)
                AppView()
            }
            .alert("Remove bike?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    
                    UserDefaults.standard.set(savedBikes, forKey: "savedBikes")

                    if let bike = bikeToDelete {
                        savedBikes.removeAll { $0 == bike }
                        UserDefaults.standard.set(savedBikes, forKey: "savedBikes")
                        if selectedBike == bike {
                            selectedBike = ""
                            UserDefaults.standard.removeObject(forKey: "selectedBike")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let bike = bikeToDelete {
                    Text("Are you sure you want to remove \"\(bike)\"?")
                }
            }
        }
    }
}
