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
                ringManager.pedometerManager.getPedometerData() {
                    ringManager.stressManager.fetchStressData() {
                        ringManager.sleepManager.getSleepFromDay(day: 0) {
                            ringManager.readBattery() {
                                ringManager.dataLoaded = true
                            }
                        }
//                                self.sleepManager.getSleepFromDay(day: 1) {
//                                    self.readBattery() {
//                                        self.dataLoaded = true
//                                    }
//                                }
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
                    HStack {
                        NavigationLink(destination: HRVScreenView(ringManager: ringManager)) {
                            HeartRateCard(bpm: ringManager.heartRateManager.dayData.last?.lastNonZeroHeartRate ?? 0)
                        }
                        BatteryCard(charge: ringManager.batteryLevel ?? 0)
                    }

                    // MARK: - Steps
                    StepsCard(
                        calories: ringManager.pedometerManager.stepsData?.calories ?? 0,
                        steps: ringManager.pedometerManager.stepsData?.totalSteps ?? 0,
                        distance: Double(ringManager.pedometerManager.stepsData?.distance ?? 0) / 1000
                    )
                    
                    NavigationLink(destination: SleepsAnalysisScreenView(sleepManager: ringManager.sleepManager)) {
                        SleepCard(sleepManager: ringManager.sleepManager)
                    }

                    StressCard(
                        lastStress: Double(ringManager.stressManager.stressData.first?.lastNonZeroStress ?? 0),
                        averageStress: ringManager.stressManager.averageStress,
                        rangeMin: ringManager.stressManager.rangeMin,
                        rangeMax: ringManager.stressManager.rangeMax
                    )
                }
                .padding()
                .padding(.bottom, 70)
            }.refreshable {
                await refreshDashboard()
            }
        }
        .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#e7bd75").opacity(0.7),
//                        Color(.purple).opacity(0.4),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}
