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
    var averageStress: Int
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
                
//                Spacer()
                
                HStack {
                    Spacer()
                    
                    StressRingView(stress: ringManagerPro.dashboardLatestValues?.stress?.value ?? 0)
                    
                    Spacer()
                    
                    VStack {
                        VStack(spacing: 4) {
                            Text("Daily Average")
                                .font(.subheadline)
                            Text("\(Int(averageStress))")
                                .font(.title3.bold())
                                .fontWidth(.expanded)
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Daily Range")
                                .font(.subheadline)
                            Text("\(rangeMin)-\(rangeMax)")
                                .font(.title3.bold())
                                .fontWidth(.expanded)
                            Text(stressLevelText(for: averageStress))
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                Text({
                    if let data = ringManagerPro.dashboardDetailsData,
                       let time = ringManagerPro.dashboardLatestValues?.stress?.time {
                       return time.toAMPM
                    } else {
                        return "--:--"
                    }
                }())
                .font(.headline)
                .fontWidth(.expanded)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .padding()
//            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .foregroundColor(.white)
        }
        
    }
    
    private func stressLevelText(for value: Int) -> String {
        switch value {
        case 0...29: return "Low"
        case 30...59: return "Normal"
        default: return "High"
        }
    }
}
