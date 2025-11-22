//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManager: QCCentralManager
    @State private var isSyncing = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    
    @MainActor
    func refreshDashboard() async {
        print("Pull to refresh triggered")
        ringManager.callAllFunctions()
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
                    if ((ringManager.connectedPeripheral == nil)) {
                        RingConnectView(ringManager: ringManager)
                    }
                    NavigationLink(destination: HeartRateScreenView(ringManager: ringManager, heartRateManager: ringManager.heartRateManager)) {
                        HeartRateCard(ringManager: ringManager)
                    }

                    // MARK: - Steps
                    NavigationLink(destination: ActivityScreenView(ringManager: ringManager, pedometerManager: ringManager.pedometerManager)) {
                        StepsCard(
                            calories: ringManager.dashboardStepsData?.calories ?? 0,
                            steps: ringManager.dashboardStepsData?.totalSteps ?? 0,
                            distance: Double(ringManager.dashboardStepsData?.distance ?? 0) / 1000
                        )
                    }
                    
                    NavigationLink(destination: SleepsAnalysisScreenView(sleepManager: ringManager.sleepManager, ringManager: ringManager)) {
                        SleepCard(ringManager: ringManager)
                    }

                    NavigationLink(destination: StressAnalysisScreenView(ringManager: ringManager, stressManager: ringManager.stressManager)) {
                        StressCard(
                            averageStress: ringManager.stressManager.averageStress,
                            rangeMin: ringManager.stressManager.rangeMin,
                            rangeMax: ringManager.stressManager.rangeMax,
                            ringManager: ringManager
                        )
                    }
                    
                    NavigationLink(destination: BloodOxygenScreenView(ringManager: ringManager, bloodOxygenManager: ringManager.bloodOxygenManager)) {
                        BloodOxygenCard(ringManager: ringManager)
                    }
                    
                    NavigationLink(destination: HRVScreenView(ringManager: ringManager, hrvManager: ringManager.hrvManager)) {
                        HRVCard(ringManager: ringManager)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if (ringManager.connectedPeripheral != nil) {
                        isSyncing = true
                        ringManager.callAllFunctions() {
                            isSyncing = false
                        }
                    } else {
                        showNavigationError = true
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
            }
        }
        .alert("Ring not connected", isPresented: $showNavigationError) {
            Button("Cancel", role: .cancel) {}
            Button("Scan for ring") {
                goToScanScreen = true
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Connect the app with ring first")
        }
        .onAppear() {
            ringManager.selectedDate = Date()
        }
        .navigationDestination(isPresented: $goToScanScreen) {
            ScanningPage(ringManager: ringManager)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
