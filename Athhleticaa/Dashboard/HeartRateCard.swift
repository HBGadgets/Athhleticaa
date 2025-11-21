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
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    Text("No data")
                }
//                Text({
//                    if let data = ringManager.heartRateManager.dayData.first,
//                       let index = data.lastNonZeroHeartRateIndex,
//                       let date = data.timeForHeartRate(at: index) {
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "h:mm a"
//                        return formatter.string(from: date)
//                    } else {
//                        return "--:--"
//                    }
//                }())
//                .font(.headline)
//                .fontWidth(.expanded)
            }
            .padding()
            .foregroundColor(.white)
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .allowsHitTesting(true)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}
