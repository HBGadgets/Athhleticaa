//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI

import SwiftUI
import Charts

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    
    @MainActor
    func refreshDashboard() async {
        print("Pull to refresh triggered")

        ringManager.dataLoaded = false
        
        DispatchQueue.main.async {
            print("🚀 Device ready — starting data fetch")
            ringManager.heartRateManager.fetchTodayHeartRate() {
                ringManager.pedometerManager.getPedometerData(day: 0) {
                    ringManager.stressManager.fetchStressData() {
                        ringManager.sleepManager.getSleepFromDay(day: 0) {
                            ringManager.readBattery() {
                                ringManager.bloodOxygenManager.fetchBloodOxygenData() {
                                    ringManager.hrvManager.fetchHRV(for: 0) {
                                        ringManager.dataLoaded = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Heart Rate
//                    HStack {
//                        NavigationLink(destination: HeartRateScreenView(ringManager: ringManager)) {
//                            HeartRateCard(bpm: ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)
//                        }
//                        BatteryCard(charge: ringManager.batteryLevel ?? 0)
//                    }
                    NavigationLink(destination: HeartRateScreenView(ringManager: ringManager)) {
                        HeartRateCard(bpm: ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)
                    }

                    // MARK: - Steps
                    NavigationLink(destination: ActivityScreenView(ringManager: ringManager, pedometerManager: ringManager.pedometerManager)) {
                        StepsCard(
                            calories: ringManager.dashboardStepsData?.calories ?? 0,
                            steps: ringManager.dashboardStepsData?.totalSteps ?? 0,
                            distance: Double(ringManager.dashboardStepsData?.distance ?? 0) / 1000
                        )
                    }
                    
                    NavigationLink(destination: SleepsAnalysisScreenView(sleepManager: ringManager.sleepManager)) {
                        SleepCard(sleepManager: ringManager.sleepManager)
                    }

                    NavigationLink(destination: StressAnalysisScreenView(ringManager: ringManager)) {
                        StressCard(
                            lastStress: Double(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0),
                            averageStress: ringManager.stressManager.averageStress,
                            rangeMin: ringManager.stressManager.rangeMin,
                            rangeMax: ringManager.stressManager.rangeMax
                        )
                    }
                    
                    NavigationLink(destination: BloodOxygenScreenView(ringManager: ringManager)) {
                        BloodOxygenCard(bloodOxygenManager: ringManager.bloodOxygenManager)
                    }
                    
                    NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
                        HRVCard(hrvManager: ringManager.hrvManager)
                    }
                }
                .padding()
                .padding(.bottom, 70)
            }.refreshable {
                await refreshDashboard()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                colorScheme == .dark ?
                Image(.athhleticaaLogoDarkMode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                :
                Image(.athhleticaaLogoLightMode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Color(.systemGray6)
                .ignoresSafeArea()
            )
    }
}
