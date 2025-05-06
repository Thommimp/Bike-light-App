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
                            .contentShape(Rectangle()) // makes the whole row tappable
                            .onTapGesture {
                                selectedBike = bike
                                UserDefaults.standard.set(selectedBike, forKey: "selectedBike")
                                navigateToAppView = true // Trigger the navigation

                            }
                        }
                    }
                }

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
                .navigationDestination(isPresented: $navigateToBLEList) {
                    BLEListView(savedBikes: $savedBikes)
                }
                .navigationDestination(isPresented: $navigateToAppView) {
                    AppView()
                }
                
           
            }
        }
    }
}
