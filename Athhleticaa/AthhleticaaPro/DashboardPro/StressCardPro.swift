//
//  StressCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUI


struct StressCardPro: View {
    @Environment(\.colorScheme) var colorScheme
//    var lastStress: Double
    var averageStress: Double
    var rangeMin: Int
    var rangeMax: Int
    @ObservedObject var ringManagerPro: RingManagerPro
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Example: 01 Nov 2025
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("StressCardImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped() // ✅ crops inside bounds
                    .overlay(
                        Color.black.opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .allowsHitTesting(false) // so image doesn’t block taps
            // Content
            VStack(alignment: HorizontalAlignment.leading, spacing: 10) {
                // Top labels
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stress")
                            .font(.headline)
                            .fontWidth(.expanded)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .padding()
//            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .foregroundColor(.white)
        }
        
    }
    
    private func stressLevelText(for value: Double) -> String {
        switch value {
        case 0...29: return "Low"
        case 30...59: return "Normal"
        default: return "High"
        }
    }
}
