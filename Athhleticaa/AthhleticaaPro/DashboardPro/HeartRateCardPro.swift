//
//  HeartRateCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 01/11/25.
//

import SwiftUI

// MARK: - Heart Rate
struct HeartRateCardPro: View {
    @ObservedObject var ringManagerPro: RingManagerPro

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
                    
                if let data = ringManagerPro.dashboardLatestValues {
                    HStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("\(data.heart?.value ?? 0) BPM")
                            .font(.headline)
                            .fontWidth(.expanded)
                        
                        Spacer()
                        
                        Text("Range \(Int(ringManagerPro.dashboardRawHealthDataStats?.heart?.min ?? 0))-\(Int(ringManagerPro.dashboardRawHealthDataStats?.heart?.max ?? 0))")
                            .fontWidth(.expanded)
                    }
                }
                
                if let dataList = ringManagerPro.dashboardDetailsData {
                        HeartRateHealthChartViewPro(
                            data: dataList,
                            ringManagerPro: ringManagerPro
                        )
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    Text("No data")
                }
                Text({
                    if let data = ringManagerPro.dashboardDetailsData,
                       let time = ringManagerPro.dashboardLatestValues?.heart?.time {
                       return time.toAMPM
                    } else {
                        return "--:--"
                    }
                }())
                .font(.headline)
                .fontWidth(.expanded)
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
