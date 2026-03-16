//
//  Dashboard.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 30/10/25.
//

import SwiftUI
import Charts

struct DashboardViewPro: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ringManagerPro: RingManagerPro
    @State private var isSyncing = false
    @State private var showNavigationError = false
    @State private var goToScanScreen = false
    
    @MainActor
    func refreshDashboard() async {
        print("Pull to refresh triggered")
        ringManagerPro.callAllFunctions()
    }
    
    var body: some View {
        VStack {
            ScrollView {
                
                VStack(spacing: 16) {
                    if ((ringManagerPro.connectedPeripheral == nil)) {
                        RingConnectViewPro(ringManagerPro: ringManagerPro)
                    }
                    NavigationLink(destination: HeartRateScreenViewPro(ringManagerPro: ringManagerPro)) {
                        HeartRateCardPro(ringManagerPro: ringManagerPro)
                    }

                    // MARK: - Steps
                    NavigationLink(destination: ActivityScreenViewPro(ringManagerPro: ringManagerPro)) {
                        ActivityCardPro(
                            calories: ringManagerPro.dashboardStepsData?.calories ?? "0",
                            steps: ringManagerPro.dashboardStepsData?.totalSteps ?? "0",
                            distance: ringManagerPro.dashboardStepsData?.distance ?? "0"
                        )
                    }
                    
                    NavigationLink(destination: SleepScreenViewPro(ringManagerPro: ringManagerPro)) {
                        SleepCardPro(ringManagerPro: ringManagerPro)
                    }

                    NavigationLink(destination: StressAnalysisScreenViewPro(ringManagerPro: ringManagerPro)) {
                        StressCardPro(
                            averageStress: 0,
                            rangeMin: 0,
                            rangeMax: 0,
                            ringManagerPro: ringManagerPro
                        )
                    }
                    
                    NavigationLink(destination: BloodOxygenScreenViewPro(ringManagerPro: ringManagerPro)) {
                        BloodOxygenCardPro(ringManagerPro: ringManagerPro)
                    }
                    
                    NavigationLink(destination: HRVScreenViewPro(ringManagerPro: ringManagerPro)) {
                        HRVCardPro(ringManagerPro: ringManagerPro)
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
                    if (ringManagerPro.connectedPeripheral != nil) {
                        isSyncing = true
                        ringManagerPro.callAllFunctions()
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
        .onChange(of: ringManagerPro.dataLoaded) { loaded in
            if loaded {
//                ringManagerPro.bloodOxygenManager.readBloodOxygenData(day: 0) { boole in
//                    if (boole == true) {
//                        ringManagerPro.hrvManager.readHrvData() { boole in
//                            if (boole == true) {
//                                print("done")
//                            }
//                        }
//                    }
//                }
                ringManagerPro.heartRateManager.readHeartRateDataByDay(day: 0) { data in
                    ringManagerPro.dashboardHeartData = data
                }
            }
        }
        .navigationDestination(isPresented: $goToScanScreen) {
            ScanningScreenPro(ringManager: ringManagerPro)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
