//
//  HealthMonitoringScreen.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 11/11/25.
//

import SwiftUI

struct HealthMonitoringScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MonitoringItem(
                    title: "Full day Heart Rate",
                    subtitle: "Monitor once every hour",
                    isEnabled: $ringManager.heartRateMonitoring
                ) {
                    ringManager.setHeartRateSchedule(enabled: ringManager.heartRateMonitoring)
                }
                
                MonitoringItem(
                    title: "SPO2 Detection",
                    subtitle: "Monitor once every hour",
                    isEnabled: $ringManager.spo2Monitoring
                ) {
                    ringManager.setBloodOxygenSchedule(enabled: ringManager.spo2Monitoring)
                }

                MonitoringItem(
                    title: "Full day stress Monitoring",
                    subtitle: "Monitor every 30 minutes",
                    isEnabled: $ringManager.stressMonitoring
                ) {
                    ringManager.setStressSchedule(enabled: ringManager.stressMonitoring)
                }

                MonitoringItem(
                    title: "Scheduled HRV monitoring",
                    subtitle: "Monitor once every hour",
                    isEnabled: $ringManager.HRVMonitoring
                ) {
                    ringManager.setHRVSchedule(enabled: ringManager.HRVMonitoring)
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Health Monitoring").font(.headline)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MonitoringItem: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var subtitle: String
    @Binding var isEnabled: Bool
    var onToggle: () -> Void // 👈 new callback

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
            }
            Spacer()
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { _ in
                    onToggle()
                }
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 0.5)
    }
}
