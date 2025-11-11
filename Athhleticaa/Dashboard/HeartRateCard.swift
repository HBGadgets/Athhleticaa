//
//  HeartRateCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUICore

// MARK: - Heart Rate
struct HeartRateCard: View {
    @ObservedObject var ringManager: QCCentralManager

    var body: some View {
        ZStack {
            // Base glossy background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .overlay(
                    // Inner edge shine (white glow around edges)
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white, lineWidth: 0.7)
                        .blur(radius: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.05),
                                            Color.white.opacity(0.4)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 0.5
                                )
                                .blur(radius: 2)
                                .blendMode(.screen)
                        )
                )
                .overlay(
                    // Soft white reflection near top
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .blur(radius: 2)
                )

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Heart rate")
                    .font(.headline)
                    .foregroundColor(Color.white)
                    
                if let day = ringManager.dashboardHeartRateData.first {
                    HStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("\(ringManager.dashboardHeartRateData.last?.lastNonZeroHeartRate ?? 0) BPM")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Range \(day.minHeartRate)-\(day.maxHeartRate)")
                    }
                }
                
                if let day = ringManager.dashboardHeartRateData.first {
                    HeartRateChartView(heartRateData: day)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    Text("No data")
                }
            }
            .padding()
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}
