//
//  StepsView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}


struct StepsCard: View {
    @Environment(\.colorScheme) var colorScheme
    var calories: Double
    var steps: Int
    var distance: Double
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("ActivityCardImage")
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
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activity")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .fontWidth(.expanded)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                HStack() {
                    VStack {
                        Image(systemName: "flame")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        Text(String(format: "%.2f", calories).prefix(2))
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWidth(.expanded)
                        Text("Kcal")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .fontWidth(.expanded)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        Text("\(steps)")
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWidth(.expanded)
                        Text("Steps")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .fontWidth(.expanded)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        Text(String(format: "%.2f", distance))
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWidth(.expanded)
                        Text("Km")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .fontWidth(.expanded)
                    }
                }
//                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
            .padding()
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity)
    }
}
