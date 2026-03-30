//
//  ECGHeartRateInfoView.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 28/03/26.
//

import SwiftUI

struct ECGHeartRateInfoCard: View {
    var vpECGTestDataModel: VPECGTestDataModel
    @State private var ecgHeartStats: ECGHeartStats?
    @StateObject var ecgManager = ECGManagerPro()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            HStack(spacing: 10) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 15))
                
                Text("Heart Rate")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.red)
            }
            
            // Top row
            HStack {
                statBlock(value: "\(vpECGTestDataModel.aveHeart ?? "")", unit: "bpm", label: "Avg. HR")
                Spacer()
                statBlock(value: "\(ecgHeartStats?.max ?? 0)", unit: "bpm", label: "Max. HR")
                Spacer()
                statBlock(value: "\(ecgHeartStats?.min ?? 0)", unit: "bpm", label: "Min. HR")
            }
            
            // Bottom row
            HStack {
                percentageBlock(
                    value: "\(ecgHeartStats?.normalPercent ?? 0)%",
                    label: "Normal",
                    sublabel: "(60 ~ 100 bpm)"
                )
                
                Spacer()
                
                percentageBlock(
                    value: "\(ecgHeartStats?.fastPercent ?? 0)%",
                    label: "Fast",
                    sublabel: "(>100 bpm)"
                )
                
                Spacer()
                
                percentageBlock(
                    value: "\(ecgHeartStats?.slowPercent ?? 0)%",
                    label: "Slow",
                    sublabel: "(<60 bpm)"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(colorScheme == .light ? .white : Color(.systemGray2))
                )
        )
        .padding()
        .onAppear() {
            let values = ecgManager.getHeartRatesFromECGData(from: vpECGTestDataModel.muHearts as? [Any])
            ecgHeartStats = ecgManager.computeHeartStats(from: values)
        }
    }
    
    @ViewBuilder
    func statBlock(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(unit)
                    .font(.system(size: 15))
            }
            
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func percentageBlock(value: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            
            Text(sublabel)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
