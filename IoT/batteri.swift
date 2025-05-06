//
//  batteri.swift
//  IoT
//
//  Created by Thomas Pedersen on 26/03/2025.
//

import SwiftUI

struct Batteri: View {
    let batteryPercentage: Int
    
    var body: some View {
        Text("Battery")
            .font(.title) // Makes the text larger
            .fontWeight(.bold) // Makes the text bold
            .foregroundColor(.black) // Darker text color
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(Color.gray.opacity(0.3))
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: CGFloat(batteryPercentage) / 100)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(batteryColor(for: batteryPercentage))
                .rotationEffect(.degrees(-90)) // Start the stroke from the top
            
            // Battery Percentage Text
            Text("\(batteryPercentage)%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(batteryColor(for: batteryPercentage))
        }
        .frame(width: 150, height: 150) // Adjust the size of the circle
    }
    
    // Helper function to get color based on battery percentage
    func batteryColor(for percentage: Int) -> Color {
        switch percentage {
        case 0..<20:
            return .red
        case 20..<50:
            return .orange
        case 50..<80:
            return .yellow
        default:
            return .green
        }
    }
}

#Preview {
    Batteri(batteryPercentage: 50)
}
