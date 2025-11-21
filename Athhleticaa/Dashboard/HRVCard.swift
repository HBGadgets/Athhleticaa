//
//  HRVCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 05/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct HRVCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("HRVCardImage")
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
            VStack(alignment: HorizontalAlignment.leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HRV")
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                HRVChartView(data: ringManager.dashboardHRVData ?? HRVModel(date: "0", values: [0], interval: 0), ringManager: ringManager)
                HStack {
                    if let lastHRV = ringManager.hrvManager.hrvData?.lastNonZeroHRV {
                        Text("\(lastHRV) HRV")
                            .fontWidth(.expanded)
                    }
                    Text({
                        if let data = ringManager.hrvManager.hrvData?.validHRV,
                           let index = ringManager.hrvManager.hrvData?.lastNonZeroHRVIndex,
                           let date = ringManager.hrvManager.hrvData?.timeForHRVRate(at: index) {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "h:mm a"
                            return formatter.string(from: date)
                        } else {
                            return "--:--"
                        }
                    }())
                    .fontWidth(.expanded)
                }
                .font(.headline)
                .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .allowsHitTesting(true)
        }
        .frame(height: 250)
        
    }
}
