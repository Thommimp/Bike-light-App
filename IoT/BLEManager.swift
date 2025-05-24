//
//  BLEManager.swift
//  IoT
//
//  Created by Thomas Pedersen on 12/04/2025.
//

import CoreBluetooth
import SwiftUI
    
// Define a struct to represent a peripheral item.
struct PeripheralItem: Identifiable {
    let id = UUID() // Make sure the peripheral item is identifiable
    let peripheral: CBPeripheral // The actual peripheral
}

struct BLEConstants {
    static let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c3319177")
    static let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
}



class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate { 
    var centralManager: CBCentralManager!
    @Published var peripherals: [PeripheralItem] = [] // Change this to store PeripheralItems
    @Published var isConnected = false // New property to track connection status


    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [BLEConstants.serviceUUID], options: nil)
        } else {
            // Handle Bluetooth not available or powered off
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        // Wrap the peripheral in a PeripheralItem
        let peripheralItem = PeripheralItem(peripheral: peripheral)
        
        // Check if the peripheral is already in the list
        if !peripherals.contains(where: { $0.id == peripheralItem.id }) {
            peripherals.append(peripheralItem)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        DispatchQueue.main.async {
                self.isConnected = true // Update the connection status
            }
    }
    
    func connectPeripheral(peripheral: CBPeripheral) {
        centralManager.stopScan()
        centralManager.connect(peripheral)
    }
    
}


struct BLEListView: View {
    @StateObject var bleManager = BLEManager()
    @State private var isConnecting = false // To track the connection state
    @State private var connectedPeripheral: PeripheralItem? // Store the connected peripheral
    @State private var navigateToContentView = false
    @Binding var savedBikes: [String]

    
    var body: some View {
        NavigationStack {
            List(bleManager.peripherals) { item in
                Button(action: {
                    // Start connecting to the selected peripheral
                    isConnecting = true
                    bleManager.connectPeripheral(peripheral: item.peripheral)
                    connectedPeripheral = item
                }) {
                    Text(item.peripheral.name ?? "Unknown Device")
                        .foregroundColor(.blue)
                }
                .disabled(isConnecting) // Disable buttons while connecting
            }
            .navigationTitle("BLE Devices")
            .onAppear {
                // Start scanning when the view appears
                bleManager.centralManager.scanForPeripherals(withServices: [BLEConstants.serviceUUID], options: nil)
          
            }
            .overlay(
                Group {
                    if isConnecting {
                        ProgressView("Connecting...") // Show a loading indicator
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.7))
                    }
                }
            )
            .onChange(of: bleManager.isConnected) {
                if $0 {
                    isConnecting = false
                    navigateToContentView = true
                    
                    if let name = connectedPeripheral?.peripheral.name {
                           savedBikes.append(name)
                        UserDefaults.standard.set(savedBikes, forKey: "savedBikes")

                       } else {
                           savedBikes.append("Unknown Device")
                       }
                    
                }
                
            }
            .navigationDestination(isPresented: $navigateToContentView) {
                AppView()
                }
            
        }
    }
}

