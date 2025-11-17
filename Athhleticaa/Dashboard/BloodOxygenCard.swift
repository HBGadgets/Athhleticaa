//
//  BloodOxygenCard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 04/11/25.
//

import SwiftUICore
import Charts
import SleepChartKit


// MARK: - Sleep
struct BloodOxygenCard: View {
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
                Image("BloodOxygenCardImage")
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
                        Text("Blood Oxygen")
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                BloodOxygenDotChart(data: ringManager.dashboardBloodOxygenData, ringManager: ringManager)
                if let bloodOxygenLevel = ringManager.dashboardBloodOxygenData.last {
                    HStack {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(.blue)
                        Text("\(Int(bloodOxygenLevel.soa2))%")
                            .fontWidth(.expanded)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Range")
                        Text("\(Int(bloodOxygenLevel.minSoa2))% - \(Int(bloodOxygenLevel.maxSoa2))%")
                            .fontWidth(.expanded)
                            .fontWeight(.bold)
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .cornerRadius(16)
        }
        .frame(height: 250)
    }
}
