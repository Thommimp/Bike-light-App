//
//  appview.swift
//  IoT
//
//  Created by Thomas Pedersen on 23/04/2025.
//

import SwiftUI

struct AppView: View {
    @State private var savedBikes: [String] = UserDefaults.standard.stringArray(forKey: "savedBikes") ?? []
    @AppStorage("selectedBike") private var selectedBike: String = ""

    var body: some View {
        if savedBikes.isEmpty {
            FrontPage(savedBikes: $savedBikes, selectedBike: $selectedBike)
        } else {
            ContentView(savedBikes: $savedBikes, selectedBike: $selectedBike)
        }
    }
}
