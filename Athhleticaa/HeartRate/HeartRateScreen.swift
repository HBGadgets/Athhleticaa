//
//  HeartRateScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/10/25.
//

import SwiftUI

struct HeartRateScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Heart Rate Section
                VStack(spacing: 16) {
//                    Image("HeartRateIcon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
                    Image(systemName: "waveform.path.ecg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 0)

                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundColor(.red)

                    Text("\(ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)")
                        .font(.system(size: 44, weight: .bold))

                    Text("BPM")
                        .font(.subheadline)
                }

                // MARK: - Average / Min / Max
                if let day = ringManager.heartRateManager.dayData.first {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "\(day.averageHeartRate)")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "\(day.minHeartRate)")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "\(day.maxHeartRate)")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : .black))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                } else {
                    HStack(spacing: 0) {
                        StatItem(title: "Average", value: "0")
                        Divider().frame(height: 40)
                        StatItem(title: "Minimum", value: "0")
                        Divider().frame(height: 40)
                        StatItem(title: "Maximum", value: "0")
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(colorScheme == .light ? .white : .black))
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
                }
                
                if let day = ringManager.heartRateManager.dayData.first {
                    HeartRateChartView(heartRateData: day)
                } else {
                    Text("No data")
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Heart rate").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

// MARK: - Reusable Components
struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }
}
