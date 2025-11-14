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
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HRV")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                HRVChartView(data: ringManager.dashboardHRVData ?? HRVModel(date: "0", values: [0], interval: 0))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        .frame(height: 250)
        
    }
}
