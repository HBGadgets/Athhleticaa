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
            GeometryReader { geo in
                Image("HeartRateCardImage")
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Heart Rate")
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .fontWidth(.expanded)
                    
                if let day = ringManager.dashboardHeartRateData.first {
                    HStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("\(ringManager.dashboardHeartRateData.last?.lastNonZeroHeartRate ?? 0) BPM")
                            .font(.headline)
                            .fontWidth(.expanded)
                        
                        Spacer()
                        
                        Text("Range \(day.minHeartRate)-\(day.maxHeartRate)")
                            .fontWidth(.expanded)
                    }
                }
                
                if let day = ringManager.dashboardHeartRateData.first {
                    HeartRateChartView(heartRateData: day, ringManager: ringManager)
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
